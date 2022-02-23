#!/usr/bin/python3

# to manage what pprz sends to USSP


from ivy.std_api import *
import threading
import time



class NetworkID():


	def __init__(self):

		IvyInit("NETWORK_ID")
		IvyStart()

		IvyBindMsg(self.on_network_id_received, "pprzuspaceconnect NETWORK_ID (\\S*) (\\S*) (\\S*)")

		self.ac_list = []

		out_thread = threading.Thread(target=self.send_all_tele)
		out_thread.start()


	def on_network_id_received(self, agent, ac_id_msg, lat_msg, lon_msg):

		is_new_ac = True
		for ac in self.ac_list:
			if str(ac.ac_id) == str(ac_id_msg):
				ac.lat = lat_msg
				ac.lon = lon_msg
				is_new_ac = False

		if is_new_ac:
			msg = "network_id NEW_AC " + ac_id_msg
			new_ac = Aircraft(ac_id_msg)
			self.ac_list.append(new_ac)
			IvySendMsg(msg)

			


	def send_all_tele(self):

		while True:
			for ac in self.ac_list:
				msg = "network_id TELEMETRY " + str(ac.ac_id) + " " + str(ac.lat) + " " + str(ac.lon)
				IvySendMsg(msg)
			time.sleep(1)



class Aircraft():


	def __init__(self, _ac_id):

		self.ac_id = _ac_id
		self.lat = 0
		self.lon = 0



def main():

	s = NetworkID()



if __name__ == '__main__':

	main()



