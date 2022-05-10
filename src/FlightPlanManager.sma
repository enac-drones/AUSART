use core
use base
use gui
use display


import FlightPlan


_define_
FlightPlanManager(Process _ivybus){

	TextPrinter log

	List flight_plan_list 

	Ref ivybus (_ivybus)

	String new_flight_plan_id ("")

	_ivybus.in.new_flight_plan[1] => new_flight_plan_id

	new_flight_plan_id -> add_new_flight_plan:(this){
		addChildrenTo this.flight_plan_list {
			FlightPlan _ (toString(this.new_flight_plan_id), getRef(this.ivybus))
		}
	}
	add_new_flight_plan~>_ivybus.in.new_flight_plan_section_polygon[1]
	add_new_flight_plan~>_ivybus.in.new_flight_plan_section_circle[1]

}