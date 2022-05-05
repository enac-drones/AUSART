#!/usr/bin/python3


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
		self.country = "FRA"
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
