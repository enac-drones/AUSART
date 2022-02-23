#!/usr/bin/python3

# network identification service


from ivy.std_api import *



class PprzUspaceConnect():


	def __init__(self):

		IvyInit("PPRZ_USPACE_CONNECT")
		IvyStart()

		IvyBindMsg(self.on_flight_param, "ground FLIGHT_PARAM (\\S*) (\\S*) (\\S*) (\\S*) (\\S*) (\\S*) (\\S*) (\\S*) (\\S*) (\\S*) (\\S*) (\\S*) (\\S*) (\\S*)")


	def on_flight_param(self, agent, ac_id, roll, pitch, heading, 
		lat, lon, speed, course, alt, climb, agl, unix_time, itow, airspeed):

		msg = "pprzuspaceconnect NETWORK_ID " + ac_id + " " + lat + " " + lon
		
		IvySendMsg(msg)



def main():

	s = PprzUspaceConnect()



if __name__ == '__main__':

	main()



