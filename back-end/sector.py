#!/usr/bin/python3


import requests
import json


WAC = False


class Sector():


	def __init__(self, _id, name, init_restriction, coords):

		if WAC:
			self.prefix_http = "http://10.192.36.100:8080"
		else:
			self.prefix_http = "https://www.ucis.ssghosting.net"

		## INIT PARAMS ##
		self.id = _id
		self.uuid = None
		self.name = name
		self.restriction = init_restriction
		self.coords = coords

		## UCIS PARAMS ##
		# general #
		self.type = "customized"
		self.restriction_condition = None # empty unless self.restriction = conditional
		self.region = 31000
		self.country = "FRX"
		self.reason = "air_traffic"
		self.other_reason_info = None
		self.regulation_exemption = "no"
		self.uspace_class = "Z"
		self.message = "EXPERIMENTAL"
		# zone authority #
		self.zone_authority_name = "ANSP"
		self.zone_authority_service = None
		self.zone_authority_contact_name = None
		self.zone_authority_site_url = None
		self.zone_authority_email = None
		self.zone_authority_phone = None
		self.zone_authority_requirements_purpose = "authorization"
		self.zone_authority_requirements_interval_before = None
		# applicability #
		self.permanent = "no"
		self.start_date_time = "2022-06-10T00:00:00.00Z"
		self.end_date_time = "2022-06-11T00:00:00.00Z"
		# geometry #
		self.uom_dimensions = "FT"
		self.lower_limit = 0
		self.lower_vertical_reference = "AGL"
		self.upper_limit = 2000
		self.upper_vertical_reference = "AGL"
		self.geometry_type = "Polygon"
		self.polygon_coordinates = coords



	def post_sector(self, headers):

		url = self.prefix_http+"/v1/geoawareness/uaszones"

		payload = json.dumps({
			"name": self.name,
			"type": self.type,
			"restriction": self.restriction,
			"restriction_conditions": self.restriction_condition,
			"region": self.region,
			"reason": [
				self.reason
			],
			"other_reason_info": self.other_reason_info,
			"regulation_exemption": self.regulation_exemption,
			"uspace_class": [
				self.uspace_class
			],
			"message": self.message,
			"zone_authority": [{
				"name": self.zone_authority_name,
				"service": self.zone_authority_service,
				"contact_name": self.zone_authority_contact_name,
				"site_url": self.zone_authority_site_url,
				"email": self.zone_authority_email,
				"phone": self.zone_authority_phone,
				"authority_requirements": 
				{
					"purpose": self.zone_authority_requirements_purpose,
					"interval_before": self.zone_authority_requirements_interval_before
				}
			}],
			"applicability": 
			[{
				"permanent": self.permanent,
				"start_date_time": self.start_date_time,
				"end_date_time": self.end_date_time,
			}],
			"geometry": [{
				"uom_dimensions": self.uom_dimensions,
				"lower_limit": self.lower_limit,
				"lower_vertical_reference": self.lower_vertical_reference,
				"upper_limit": self.upper_limit,
				"upper_vertical_reference": self.upper_vertical_reference,
				"horizontal_projection": 
					{
						"polygon": {
							"type": "Polygon",
							"coordinates": [self.polygon_coordinates]
						}
					}
				}
			],
			"uas_zone": {
				"identifier": self.id,
				"country": self.country
			}
		})

		response = requests.post(url, headers=headers, data=payload)

		if response.status_code == 201:
			self.uuid = response.json()["uuid"]
			print("SECTOR %s SUCCESSFULLY SUBMITED, ID = %s" % (self.name, self.uuid))
		else:
			print("ERROR IN SUBMISSION OF SECTOR %s" % self.name)
			print(response.status_code)




	def update_with_new_restri(self, new_restri, headers):

		self.restriction = new_restri

		url = self.prefix_http+"/v1/geoawareness/uaszones/%s" % self.uuid

		payload = json.dumps({
			"name": self.name,
			"type": self.type,
			"restriction": new_restri,
			"restriction_conditions": self.restriction_condition,
			"region": self.region,
			"reason": [
				self.reason
			],
			"other_reason_info": self.other_reason_info,
			"regulation_exemption": self.regulation_exemption,
			"uspace_class": [
				self.uspace_class
			],
			"message": self.message,
			"zone_authority": [{
				"name": self.zone_authority_name,
				"service": self.zone_authority_service,
				"contact_name": self.zone_authority_contact_name,
				"site_url": self.zone_authority_site_url,
				"email": self.zone_authority_email,
				"phone": self.zone_authority_phone,
				"authority_requirements": 
				{
					"purpose": self.zone_authority_requirements_purpose,
					"interval_before": self.zone_authority_requirements_interval_before
				}
			}],
			"applicability": 
			[{
				"permanent": self.permanent,
				"start_date_time": self.start_date_time,
				"end_date_time": self.end_date_time,
			}],
			"geometry": [{
				"uom_dimensions": self.uom_dimensions,
				"lower_limit": self.lower_limit,
				"lower_vertical_reference": self.lower_vertical_reference,
				"upper_limit": self.upper_limit,
				"upper_vertical_reference": self.upper_vertical_reference,
				"horizontal_projection": 
					{
						"polygon": {
							"type": "Polygon",
							"coordinates": [self.polygon_coordinates]
						}
					}
				}
			],
			"uas_zone": {
				"identifier": self.id,
				"country": self.country
			}
		})

		response = requests.put(url, headers=headers, data=payload)

		if response.status_code == 204:
			print("SECTOR %s SUCCESSFULLY UPDATED, ID = %s" % (self.name, self.uuid))
		else:
			print("ERROR IN UPDATE OF SECTOR %s" % self.name)
			print(response.text)