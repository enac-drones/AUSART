use core
use base
use gui
use display


import FlightPlan


_define_
FlightPlanManager(Process _ivybus){

	TextPrinter log

	Ref ivybus (_ivybus)

	List flight_plan_list

	Spike fp_auth
	Spike fp_reject

	Spike show_dialog
	Spike show_dialog_req_auth

	String selected_fp_id ("")
	String selected_fp_exp_start ("")
	String selected_fp_exp_end ("") 
	String selected_fp_status ("")

	String new_flight_plan_id ("")
	String new_flight_plan_exp_start ("")
	String new_flight_plan_exp_end ("")

	_ivybus.in.new_flight_plan[1] => new_flight_plan_id
	_ivybus.in.new_flight_plan[2] => new_flight_plan_exp_start
	_ivybus.in.new_flight_plan[3] => new_flight_plan_exp_end

	new_flight_plan_id -> add_new_flight_plan:(this){
		addChildrenTo this.flight_plan_list {
			FlightPlan fp (toString(this.new_flight_plan_id), toString(this.new_flight_plan_exp_start), toString(this.new_flight_plan_exp_end), getRef(this.ivybus), this)
		}
	}
	add_new_flight_plan~>_ivybus.in.new_flight_plan_section_polygon[1]
	add_new_flight_plan~>_ivybus.in.new_flight_plan_section_circle[1]
	add_new_flight_plan~>_ivybus.in.new_flight_plan_section_traj[1]
	add_new_flight_plan~>_ivybus.in.activate_fp[1]
	add_new_flight_plan~>_ivybus.in.close_fp[1]
}