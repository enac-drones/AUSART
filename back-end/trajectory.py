class Trajectory():

	def __init__(self, id, json):

		self.id = id
		self.points = []

		for point in json["points4D"]:
			pt = Point(point["point3D"][1], point["point3D"][0], point["crossing_datetime"])
			self.points.append(pt)






class Point():

	def __init__(self, lat, lon, estimated_time):

		self.lat = lat
		self.lon = lon
		self.estimated_time = estimated_time
