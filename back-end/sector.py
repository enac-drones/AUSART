#!/usr/bin/python3


import requests
import json




class Sector():


	def __init__(self, id, name, init_restriction, coords):

		## INIT PARAMS ##
		self.id = id
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
		self.permanent = "YES"
		# geometry #
		self.uom_dimensions = "FT"
		self.lower_limit = 0
		self.lower_vertical_reference = "AGL"
		self.upper_limit = 2000
		self.upper_vertical_reference = "AGL"
		self.geometry_type = "Polygon"
		self.polygon_coordinates = coords



	def post_sector(self, headers):

		url = "https://www.ucis.ssghosting.net/v1/geoawareness/uaszones"

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
							"type": self.geometry_type,
							"coordinates": 
							[
								[self.coords]
							]
						},
					}
				}
			],
			"uas_zone": {
				"identifier": self.id,
				"country": self.country
			}
		})

		response = requests.post(url, headers=headers, data=payload)

		print(response.text)




	def post_sector_min_info(self, headers):

		url = "https://www.ucis.ssghosting.net/v1/geoawareness/uaszones"

		payload = json.dumps({
			"type": self.type,
			"restriction": self.restriction,
			"zone_authority": [{
				"authority_requirements": 
				{
					"purpose": self.zone_authority_requirements_purpose
				}
			}],
			"geometry": [{
				"uom_dimensions": self.uom_dimensions,
				#"lower_limit": self.lower_limit,
				"lower_vertical_reference": self.lower_vertical_reference,
				#"upper_limit": self.upper_limit,
				"upper_vertical_reference": self.upper_vertical_reference,
				"horizontal_projection": 
					{
						"polygon": None, 
						"circle": {
							"type": "Feature",
							"geometry": {
								"type": "Point", 
								"coordinates": [1.44372, 43,601940]
							},
							"properties": {
								"radius": {
									"value": 2000.0,
									"units": "M"
								}
							}
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

		print(response.status_code)
		print(response.text)

