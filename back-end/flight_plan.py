class FlightPlan():


	def __init__(self, json):

		self.uuid = json["uuid"]
		self.expected_start = json["expected_start"]
		self.expected_end = json["expected_end"]
		self.effective_start = json["effective_start"]
		self.effective_end = json["effective_end"]
		self.drone = json["drone"]
		self.swarm = json["swarm"]
		self.pilots = json["pilots"]
		self.operation_type = json["operation_type"]
		self.operaton_domain = json["operation_domain"]
		self.additional_info_for_atc = json["additional_info_for_atc"]
		self.geospatial_occupancy = json["geospatial_occupancy"]
		self.status = json["status"]
		self.status_detail = json["status_detail"]
		self.contingency_plan = json["contingency_plan"]
		self.metadata = json["metadata"]