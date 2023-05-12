from ivy.std_api import *
import time 

IvyInit("fake intruder")
IvyStart(ivybus="10.192.36.255:6060")

lat = 437000000

while True:
	time.sleep(2)
	msg = "TOTO INTRUDER 3249021 NAK283 %s 12500000 5000000 180.32 200 10 1" % lat
	IvySendMsg(msg)
	lat += 100000
