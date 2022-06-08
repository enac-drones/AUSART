use core
use base
use gui
use display


import FlightPlan


_define_
FlightPlanManager(Process _frame, Process _ivybus){

	TextPrinter log

	Ref ivybus (_ivybus)
	Ref frame (_frame)

	List flight_plan_list

	Spike fp_auth
	Spike fp_reject

	Spike show_dialog
	Spike show_dialog_req_auth

	Spike deselect_all_but_selected

	// INTERFACE FOR OTHER PROCESSES TO GET SELECTED FP INFO // TODO LATER WITH A REF THAT SETS ITSELF TO SELECTED FP
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
			FlightPlan fp (toString(this.new_flight_plan_id), toString(this.new_flight_plan_exp_start), toString(this.new_flight_plan_exp_end), getRef(this.ivybus), getRef(this.frame), this)
		}
	}
	add_new_flight_plan~>_ivybus.in.new_flight_plan_section_polygon[1]
	add_new_flight_plan~>_ivybus.in.new_flight_plan_section_circle[1]
	add_new_flight_plan~>_ivybus.in.new_flight_plan_section_traj[1]
	add_new_flight_plan~>_ivybus.in.activate_fp[1]
	add_new_flight_plan~>_ivybus.in.close_fp[1]
	add_new_flight_plan~>_ivybus.in.update_flight_plan[1]
	add_new_flight_plan~>_ivybus.in.update_flight_plan_section_circle[1]
	add_new_flight_plan~>_ivybus.in.update_flight_plan_section_polygon[1]
	add_new_flight_plan~>_ivybus.in.update_flight_plan_section_polygon_point[1]

/*	deselect_all_but_selected -> deselect:(this){
		for (int i = 1; i <= $this.flight_plan_list.size; i++){
			if ($this.flight_plan_list.[i].fp_id != $this.selected_fp_id){
				notify this.flight_plan_list.[i].deselect
			}
		}
	}*/


}