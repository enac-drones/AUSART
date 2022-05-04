#!/usr/bin/python3

import time

from ivy.std_api import *

import requests
import json

import threading

from shapely.geometry import Point
from shapely.geometry import shape
from shapely.geometry.polygon import Polygon


class BackEnd():


	def __init__(self):

		self.client_id = 'd7d08988-97ba-44af-a7e1-afab0524510b'
		self.username = 'cconan'
		self.password = 'wac_2022'
		self.token = None
		self.refresh_token = None
		self.headers = None

		self.sectors = []

		IvyInit("AUSART_BACK_END")
		IvyStart()
		IvyBindMsg(self.send_sectors, "FRONT_END_READY")

		self.log_in_to_UCIS()




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
			'geoawareness.uaszones.submit.write'
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
		while True:
			#print("\nRefresh thread started")
			time.sleep(expires_in - 50)
			#print("\nAutomatic token refresh")

			url = 'https://www.ucis.ssghosting.net/auth/realms/UCIS/protocol/openid-connect/token'

			data = {
				'grant_type': 'refresh_token',
				'client_id': self.client_id,
				'refresh_token': self.refresh_token
			}

			response = requests.post(url, data=data)

			if response.status_code == 200:
				print("\nAutomatic token refresh success")
				#print(response.text)
				self.refresh_token = response.json()["refresh_token"]
				self.token = response.json()["refresh_token"]

			else:
				print("\nFailed to refresh token")




	def send_sectors(self, agent):
		# reads and send sectors defined in json file #

		with open('geojson_areas.json') as json_file:

			data = json.load(json_file)

			for json_sector in data['features'][1:]:

				sect_id = json_sector['id']
				coordinates = json_sector['coordinates']
				sect = Sector (sect_id, coordinates, None, json_sector)
				self.sectors.append(sect)

				msg = "ausart_back_end AREA_INIT %s" % sect_id
				IvySendMsg(msg)

				for point in coordinates[0][:-1]:
					point_lat = point[1]
					point_lon = point[0]
					msg_point = 'ausart_back_end POINT_AREA_INIT %s %s %s' % (sect_id, point_lat, point_lon)
					IvySendMsg(msg_point)





class Sector():

	def __init__(self, _id, _geometry, _param, _json_coords):
		self.id = _id
		self.geometry = _geometry
		self.param = _param
		self.json_coords = _json_coords


def main():

	s = BackEnd()



if __name__ == '__main__':

	main()