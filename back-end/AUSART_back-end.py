#!/usr/bin/python3


from ivy.std_api import *
from enum import Enum
import json

from shapely.geometry import Point
from shapely.geometry import shape
from shapely.geometry.polygon import Polygon

# different representation for each aircraft
class REPR(Enum):
	FULL = 1
	PARTIAL = 2
	NONE = 3


class AUSARTBackEnd():

	def __init__(self):

		IvyInit("AUSART_BACK_END")
		IvyStart(ivybus="10.192.36.255:6060")

		# at init, no aircrafts, they will be received from PPRZ
		self.ac_list = []

		# at init, define the params of each sectors
		self.sectors = []

		IvyBindMsg(self.on_telemetry_received, "network_id TELEMETRY (\\S*) (\\S*) (\\S*)")
		IvyBindMsg(self.on_new_aircraft_received, "network_id NEW_AC (\\S*)")
		IvyBindMsg(self.send_sectors, "FRONT_END_READY")
		IvyBindMsg(self.on_ac_end_received, "network_id AC_END (\\S*)")


	def on_new_aircraft_received(self, agent, ac_id_msg):

		new_ac = Aircraft(ac_id_msg)

		self.ac_list.append(new_ac)

		print("FROM AUSART BACK END, CREATING NEW AC %s" % ac_id_msg)

		msg = "ausart_back_end NEW_AC %s" % ac_id_msg

		IvySendMsg(msg)


	def on_telemetry_received(self, agent, ac_id_msg, lat_msg, lon_msg):

		current_sector = None

		for ac in self.ac_list:
			if str(ac.ac_id) == (str(ac_id_msg)):
				ac.lat = lat_msg
				ac.lon = lon_msg


				for sector in self.sectors:

					point = Point(float(lon_msg), float(lat_msg))
					polygon = shape(sector.json_coords)

					if polygon.contains(point):

						sect_id = sector.id
						print("AC %s IN SECT %s" % (ac_id_msg, sect_id))
						ac.current_sector = sect_id
						current_sector = sect_id


				print("FROM AUSART BACK END, UPDATING AC %s WITH_: %s %s IN SECTOR %s" 
					% (ac.ac_id, ac.lat, ac.lon, ac.current_sector))

				msg = "ausart_back_end UPDATE_AC %s %s %s %s" % (ac.ac_id, ac.lat, ac.lon, ac.current_sector)

				IvySendMsg(msg)


	def send_sectors(self, agent):

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


	def on_ac_end_received(self, agent, _ac_id):

		for ac in self.ac_list:

			if ac.ac_id == _ac_id:

				self.ac_list.remove(ac)
				print("FROM AUSART BACK END, REMOVED AC %s" % ac.ac_id)

		msg = "ausart_back_end DELETE_AC %s" % _ac_id

		IvySendMsg(msg)

class Aircraft():

	def __init__(self, _ac_id):

		self.ac_id = _ac_id
		self.lat = 0
		self.lon = 0

		self.repr = None

		self.current_sector = None



class Sector():

	def __init__(self, _id, _geometry, _param, _json_coords):
		self.id = _id
		self.geometry = _geometry
		self.param = _param
		self.json_coords = _json_coords



def main():

	s = AUSARTBackEnd()



if __name__ == '__main__':

	main()