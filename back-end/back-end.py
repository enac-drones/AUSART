#!/usr/bin/python3

import time
import requests
import json
import threading
import asyncio
import websockets

from ivy.std_api import *

# from shapely.section import Point
# from shapely.section import shape
# from shapely.section.polygon import Polygon

from sector import Sector
from flight_plan import FlightPlan
from geometry import Geometry
from trajectory import Trajectory


class BackEnd():


	def __init__(self):

		self.client_id = 'd7d08988-97ba-44af-a7e1-afab0524510b'
		# self.client_id = 'enac'
		self.prefix_http = "https://www.ucis.ssghosting.net" 
		# self.prefix_http = "http://10.192.36.100:8080"
		self.prefix_http_token = "https://www.ucis.ssghosting.net"
		# self.prefix_http_token = "http://10.192.36.100:8090"
		self.prefix_wss = "wss://wss.ucis.ssghosting.net"
		# self.prefix_wss = "ws://10.192.36.100:8080/wss"
		self.username = 'cconan'
		self.password = 'wac_2022'
		self.token = None
		self.refresh_token = None
		self.headers = None

		self.sectors = []
		self.flight_plans = []

		## IVY ##
		IvyInit("AUSART_BACK_END")
		IvyStart()
		IvyBindMsg(self.send_sectors_to_front, "FRONT_END_READY")
		IvyBindMsg(self.validate_flight_plan, "ausart_front_end VALIDATE_FP (\\S*)")
		# ausart_front_end VALIDATE_FP fp_id
		IvyBindMsg(self.reject_flight_plan, "ausart_front_end REJECT_FP (\\S*)")
		# ausart_front_end REJECT_FP fp_id
		IvyBindMsg(self.update_sector, "ausart_front_end SECT_RESTRICT_CHANGED (\\S*) (\\S*)")
		# ausart_front_end SECT_RESTRICT_CHANGED sect_id new_restri

		## INIT FUNCTIONS ##
		self.load_sectors('../conf/areas/geojson_areas_v2.json')
		self.log_in_to_UCIS()
		self.post_sectors_to_ucis()

		## SOCKETS ##
		asyncio.run(self.thread_listen_dops())

		thread_notif_dops = threading.Thread(target=self.thread_listen_dops, daemon=True)
		thread_notif_dops.start()




	## SOCKET FUNCS ##
	async def process_dops(self, _message):
		print("NEW DOP : ", _message)
		message = json.loads(_message)
		dop_id = message["dop_uuid"]
		if message["notification_type"] == "filed":
			print("NEW FP RECEIVED : ", dop_id)
			self.add_new_fp(dop_id)
			self.send_fp_to_front(dop_id)
		elif message["notification_type"] == "closed":
			print("FP CLOSED ", dop_id)
			self.close_fp(dop_id)
		elif message["notification_type"] == "activated":
			print("FP ACTIVATED", dop_id)
			self.activate_fp(dop_id)
		else:
			pass


	async def listen_dops(self):
		headers = {
			"Authorization":"Bearer " + self.token
		}
		async with websockets.connect("%s/dops" % self.prefix_wss, extra_headers=headers) as websocket:
			async for message in websocket:
				await self.process_dops(message)


	def thread_listen_dops(self):
		asyncio.run(self.listen_dops())



	def log_in_to_UCIS(self):
		## Log in as ANSP into UCIS system ##
		url = self.prefix_http_token+'/auth/realms/UCIS/protocol/openid-connect/token'

		headers = {
			'Content-Type': 'application/x-www-form-urlencoded',
		}

		data = {
			'client_id': self.client_id,
			'username': self.username,
			'password': self.password,
			'grant_type': 'password',
			'scope': 'flight-planning.dops.read flight-planning.dops.write ' + \
			'flight-planning.dops.activate.write flight-planning.dops.approve.write ' + \
			'flight-planning.dops.cancel.write flight-planning.dops.close.write ' + \
			'flight-planning.dops.reject.write flight-planning.dops.submit.write ' + \
			'geoawareness.uaszones.read geoawareness.uaszones.write ' + \
			'geoawareness.uaszones.submit.write notification.flight-planning.read ' + \
			'notification.geoawareness.read'
		}

		response = requests.post(url, headers=headers, data=data)
		#print("\nAuthentifying")

		if response.status_code == 200:
			print("\nAuthentified successfully")
			#print(response.text)
			self.token = response.json()["access_token"]
			self.refresh_token = response.json()["refresh_token"]

			self.headers = {
				'Content-Type': 'application/json',
				'Authorization': 'Bearer ' + self.token
			}

			expires_in = response.json()["expires_in"]

			refresh_thread = threading.Thread(target=self.thread_refresh,
				args=(expires_in,), daemon=False)
			refresh_thread.start()


		else:
			print("\nLog in failed:", response.text)




	def thread_refresh(self, expires_in):
		## Creates a new thread to auto refresh the access token ##

		url = self.prefix_http_token+'/auth/realms/UCIS/protocol/openid-connect/token'
		
		while True:

			time.sleep(expires_in - 50)

			data = {
				'grant_type': 'refresh_token',
				'client_id': self.client_id,
				'refresh_token': self.refresh_token
			}

			response = requests.post(url, data=data)

			if response.status_code == 200:

				print("\nAutomatic token refresh success")
				self.refresh_token = response.json()["refresh_token"]
				self.token = response.json()["access_token"]

			else:

				print("\nFailed to refresh token")




	def load_sectors(self, path):
		# loads sectors from json file #

		with open(path) as json_file:

			data = json.load(json_file)

			for json_sector in data['features'][1:]:

				sect_name = json_sector['id']
				coordinates = json_sector['coordinates']
				init_restriction = json_sector['restriction']

				sect = Sector ("XXXXXXX", sect_name, init_restriction, coordinates[0])
				self.sectors.append(sect)




	def send_sectors_to_front(self, agent):
		# reads and sends sectors to front #

		for sect in self.sectors:

			msg = "ausart_back_end AREA_INIT %s %s" % (sect.name, sect.restriction)
			IvySendMsg(msg)

			for point in sect.coords:
				point_lat = point[1]
				point_lon = point[0]
				msg_point = 'ausart_back_end POINT_AREA_INIT %s %s %s' % (sect.name, point_lat, point_lon)
				IvySendMsg(msg_point)




	def post_sectors_to_ucis(self):

		for sect in self.sectors:

			sect.post_sector(self.headers)




	def add_new_fp(self, fp_id):
		# adds new fp from UCIS to local database #

		url = self.prefix_http+"/v1/dops"

		params = {
			"dop_uuids": [fp_id]
			}

		response = requests.get(url, headers=self.headers, params=params)

		print(response.text)

		flight_plan = FlightPlan(response.json()[0])

		self.flight_plans.append(flight_plan)



	def send_fp_to_front(self, fp_id):

		flight_plan = next(fp for fp in self.flight_plans if fp.uuid == fp_id)

		msg = "ausart_back_end NEW_FP %s %s %s" % (fp_id, flight_plan.expected_start.replace(" ", "_"), flight_plan.expected_end.replace(" ", "_"))
		print(msg)
		IvySendMsg(msg)

		for section in flight_plan.sections:
			if isinstance(section, Geometry):
				if section.type == "circle":
					msg = "ausart_back_end NEW_FP_SECTION_CIRCLE %s %s %s %s %s" \
						% (fp_id, section.id, section.center_lat, section.center_lon, section.radius)
					IvySendMsg(msg)
				elif section.type == "polygon":
					msg = "ausart_back_end NEW_FP_SECTION_POLYGON %s %s" % (fp_id, section.id)
					IvySendMsg(msg)
					for coord in section.coords:
						time.sleep(0.001)
						msg = "ausart_back_end NEW_FP_SECTION_POLYGON_POINT %s %s %s %s" \
							% (fp_id, section.id, coord[0], coord[1]) 
						IvySendMsg(msg)
			elif isinstance(section, Trajectory):
				msg = "ausart_back_end NEW_FP_SECTION_TRAJ %s %s" % (fp_id, section.id)
				IvySendMsg(msg)
				for i in range(len(section.points[1:])):
					time.sleep(0.001)
					msg = "ausart_back_end NEW_FP_SECTION_TRAJ_LINE %s %s %s %s %s %s" \
						% (fp_id, section.id, section.points[i-1].lon, section.points[i-1].lat, section.points[i].lon, section.points[i].lat)
					IvySendMsg(msg)


	def validate_flight_plan(self, agent, fp_id):
		print("VALIDATING FP WITH ID = " + fp_id)

		url = self.prefix_http+"/v1/dops/approve/%s" % fp_id

		payload = json.dumps({"authority_comments": "no comments"})

		response = requests.put(url, headers=self.headers, data=payload)

		print(response)



	def reject_flight_plan(self, agent, fp_id):
		print("REJECTING FP WITH ID = " + fp_id)

		url = self.prefix_http+"/v1/dops/reject/%s" % fp_id

		payload = json.dumps({"reason": "not supported yet"})

		response = requests.put(url, headers=self.headers, data=payload)

		print(response)



	def update_sector(self, agent, sector_id, new_restri):
		print("UPDATING SECTOR WITH ID " + sector_id + " / NEW RESTRICTION = " + new_restri)
		sect = next(sect for sect in self.sectors if sect.name == sector_id)

		sect.update_with_new_restri(new_restri, self.headers)

		return



	def close_fp(self, fp_id):

		try:
			flight_plan = next(fp for fp in self.flight_plans if fp.uuid == fp_id)
		except StopIteration:
			print("ATTEMPTING TO CLOSE UNKNOWN FP")
			return

		flight_plan.status = "closed"

		msg = "ausart_back_end CLOSE_FP %s" % flight_plan.uuid

		IvySendMsg(msg)



	def activate_fp(self, fp_id):

		try:
			flight_plan = next(fp for fp in self.flight_plans if fp.uuid == fp_id)
		except StopIteration:
			print("ATTEMPTING TO ACTIVATE UNKNOWN FP")
			return

		flight_plan.status = "activated"

		msg = "ausart_back_end ACTIVATE_FP %s" % flight_plan.uuid

		IvySendMsg(msg)




def main():

	s = BackEnd()



if __name__ == '__main__':

	main()