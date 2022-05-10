#!/usr/bin/python3

import time
import requests
import json
import threading
import asyncio
import websockets

from ivy.std_api import *

from shapely.geometry import Point
from shapely.geometry import shape
from shapely.geometry.polygon import Polygon

from sector import Sector
from flight_plan import FlightPlan


class BackEnd():


	def __init__(self):

		self.client_id = 'd7d08988-97ba-44af-a7e1-afab0524510b'
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

		## INIT FUNCTIONS ##
		self.load_sectors('../conf/areas/geojson_areas_v2.json')
		self.log_in_to_UCIS()
		self.post_sectors_to_ucis()

		## SOCKETS ##
		#asyncio.run(self.main())

		thread_notif_dops = threading.Thread(target=self.thread_listen_dops, daemon=True)
		thread_notif_dops.start()




	## SOCKET FUNCS ##
	async def process_dops(self, _message):
		print(_message)
		message = json.loads(_message)
		dop_id = message["dop_uuid"]
		if message["notification_type"] == "filed":
			print("NEW FP RECEIVED : ", dop_id)
			self.add_new_fp(dop_id)
		else:
			pass


	async def listen_dops(self):
		headers = {
			"Authorization":"Bearer " + self.token
		}
		print ("\n headers ", headers)
		async with websockets.connect("wss://wss.ucis.ssghosting.net/dops", extra_headers=headers) as websocket:
			async for message in websocket:
				await self.process_dops(message)


	def thread_listen_dops(self):
		asyncio.run(self.listen_dops())



	def log_in_to_UCIS(self):
		## Log in as ANSP into UCIS system ##
		url = 'https://www.ucis.ssghosting.net/auth/realms/UCIS/protocol/openid-connect/token'

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
		print("\nAuthentifying")

		if response.status_code == 200:
			print("\nAuthentified successfully")
			print(response.text)
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

		url = 'https://www.ucis.ssghosting.net/auth/realms/UCIS/protocol/openid-connect/token'
		
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
				self.token = response.json()["refresh_token"]

			else:

				print("\nFailed to refresh token")




	def load_sectors(self, path):
		# loads sectors from json file #

		with open(path) as json_file:

			data = json.load(json_file)

			for json_sector in data['features'][1:]:

				sect_name = json_sector['id']
				coordinates = json_sector['coordinates']

				sect = Sector ("XXXXXXX", sect_name, "no_restriction", coordinates[0])
				self.sectors.append(sect)




	def send_sectors_to_front(self, agent):
		# reads and sends sectors to front #

		for sect in self.sectors:

			msg = "ausart_back_end AREA_INIT %s" % sect.name
			IvySendMsg(msg)

			for point in sect.coords[0]:
				point_lat = point[1]
				point_lon = point[0]
				msg_point = 'ausart_back_end POINT_AREA_INIT %s %s %s' % (sect.name, point_lat, point_lon)
				IvySendMsg(msg_point)




	def post_sectors_to_ucis(self):

		# for sect in self.sectors:

		# 	sect.post_sector_min_info(self.headers)

		## FOR EXPE ONLY SEND 1st SECTOR ##
		sect = self.sectors[0]
		sect.post_sector_min_info(self.headers)




	def add_new_fp(self, fp_id):
		# adds new fp from UCIS to local database #

		url = "https://www.ucis.ssghosting.net/v1/dops/"

		params = {
			"dop_uuids": [fp_id]
			}

		response = requests.get(url, headers=self.headers, params=params)

		print(response.text)

		flight_plan = FlightPlan(response.json()[0])

		self.flight_plans.append(flight_plan)





def main():

	s = BackEnd()



if __name__ == '__main__':

	main()