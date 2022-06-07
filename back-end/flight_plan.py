from geometry import Geometry
from trajectory import Trajectory



class FlightPlan():


	def __init__(self, json):

		self.uuid = json["uuid"]
		self.expected_start = json["expected_start"]
		self.expected_end = json["expected_end"]
		try:
			self.effective_start = json["effective_start"]
		except KeyError:
			self.effective_start = None
		try:
			self.effective_end = json["effective_end"]
		except KeyError:
			self.effective_end = None
		try:
			self.drone = json["drone"]
		except KeyError:
			self.drone = None
		try:
			self.swarm = json["swarm"]
		except KeyError:
			self.swarm = None
		try:
			self.pilots = json["pilots"]
		except KeyError:
			self.operation_type = None
		try:
			self.operaton_domain = json["operation_domain"]
		except KeyError:
			self.operaton_domain = None
		try:
			self.additional_info_for_atc = json["additional_info_for_atc"]
		except KeyError:
			self.additional_info_for_atc = None
		self.geospatial_occupancy = json["geospatial_occupancy"]
		self.status = json["status"]
		self.status_detail = json["status_detail"]
		try:
			self.contingency_plan = json["contingency_plan"]
		except KeyError:
			self.contingency_plan = None
		self.metadata = json["metadata"]

		self.sections = []

		section_id = 0
		for section in self.geospatial_occupancy:
			if section["geospatialOccupancyType"] == "Volume4D":
				geometry = Geometry(section_id, section)
				self.sections.append(geometry)
			elif section["geospatialOccupancyType"] == "Trajectory4D":
				trajectory = Trajectory(section_id, section)
				self.sections.append(trajectory)
			section_id += 1