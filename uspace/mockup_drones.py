#!/usr/bin/python3



from ivy.std_api import *
import time




IvyInit("FAKE_DRONES")
IvyStart(ivybus="10.192.36.255:6060")

lat0_1 = 43.6373444
lon0_1 = 1.3631441

lat_1 = lat0_1
lon_1 = lon0_1

lat0_2 = 43.6313444
lon0_2= 1.3691441

lat_2 = lat0_2
lon_2 = lon0_2

iter = 0

while True:

	time.sleep(1)

	if iter == 0:
		msg1 = "network_id NEW_AC 102"
		msg2 = "network_id NEW_AC 103"
		IvySendMsg(msg1)
		IvySendMsg(msg2)

	msg11 = "network_id TELEMETRY 102 " + str(lat_1) + " " + str(lon_1)
	msg22 = "network_id TELEMETRY 103 " + str(lat_2) + " " + str(lon_2)

	IvySendMsg(msg11)
	IvySendMsg(msg22)

	lat_1 += 0.001
	lon_1 += 0.0001

	lat_2 += 0.0007
	lon_2 += 0.002

	iter += 1

	if iter == 60:
		lat_1 = lat0_1
		lon_1 = lon0_1
		lat_2 = lat0_2
		lon_2 = lon0_2

		msg111 = "network_id AC_END 102"
		msg222 = "network_id AC_END 103"

		IvySendMsg(msg111)
		IvySendMsg(msg222)
		
		time.sleep(5)
		iter = 0
