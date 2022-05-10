class Geometry():


	def __init__(self, _id, json):

		self.id = _id
		self.type = ""
		try:
			altitude_lower = json["volume"]["altitude_lower"]
			if altitude_lower is not None:
				self.altitude_lower = altitude_lower["value"]
		except KeyError:
			self.altitude_lower = 0
		self.altitude_upper = json["volume"]["altitude_upper"]["value"]
		# if circle #
		self.center_lon = None
		self.center_lat = None
		self.radius = None
		# if polygon #
		self.coords = []

		if json["geospatialOccupancyType"] == "Volume4D":
			if json["volume"]["outline_circle"] is not None:
				print("CREATING A CIRCLE GEOMETRY")
				self.type = "circle"
				self.center_lon = json["volume"]["outline_circle"]["geometry"]["coordinates"][0]
				self.center_lat = json["volume"]["outline_circle"]["geometry"]["coordinates"][1]
				self.radius = json["volume"]["outline_circle"]["properties"]["radius"]["value"]
			elif json["outline_polygon"] is not None:
				print("CREATING A POLYGON GEOMETRY")
				if json["volume"]["outline_polygon"]["type"] == "Polygon":
					self.type = "polygon"
					for coords in json["outline_polygon"]["coordinates"]:
						self.coords.append([coords[1], coords[0]])
				else:
					print("UNSUPPORTED POLYGON TYPE")
		elif json["geospatialOccupancyType"] == "Trajectory4D":
			print("DOES NOT SUPPORT TRAJECTORY 4D TYPE YET")
		else:
			print("UNSUPPORTED GEOMETRY TYPE FOR GEOMETRY ID : ", self.id)