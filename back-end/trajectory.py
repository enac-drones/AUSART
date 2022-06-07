from shapely.geometry import Point, LineString, MultiLineString, Polygon



class Trajectory():

	def __init__(self, id, json):

		self.id = id
		self.points = []
		self.coords_raw = []

		for point in json["points4D"]:
			pt = Point(point["point3D"][1], point["point3D"][0], point["crossing_datetime"])
			self.points.append(pt)
			self.coords_raw.append((point["point3D"][1], point["point3D"][0]))

		self.buffer = LineString(self.coords_raw).buffer(0.003)




class Point():

	def __init__(self, lat, lon, estimated_time):

		self.lat = lat
		self.lon = lon
		self.estimated_time = estimated_time
