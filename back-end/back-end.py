#!/usr/bin/python3


from ivy.std_api import *
from enum import Enum
import json

from shapely.geometry import Point
from shapely.geometry import shape
from shapely.geometry.polygon import Polygon



class BackEnd():

	def __init__(self):

		IvyInit("AUSART_BACK_END")
		IvyStart()

		self.sectors = []

		## Ivy bindings to communicate with front end
		IvyBindMsg(self.send_sectors, "FRONT_END_READY")

		## Log in as ANSP into UCIS system ##



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