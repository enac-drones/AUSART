use core
use base
use gui
use display


import Button

_define_
Dialog (Process frame, Process ivybus, Process flight_plan_manager, Process sector_manager) {

	TextPrinter log 
	TextPrinter log2
	TextPrinter log3

	Double self_width (600)
	Double self_height ($frame.height)

	FillColor fc (Black)
	OutlineColor oc (200, 200, 200)
	OutlineWidth ow (5)
	Rectangle rc ($frame.width - $self_width, 0, $self_width, $self_height, 0, 0)

	Double x0 ($rc.x)
	Double y0 (0)

	Spike back_to_idle_from_show_fp

	AssignmentSequence as_test (1) {
		"VALIDATE FP WITH ID = " + flight_plan_manager.selected_fp_id =: log.input
		"ausart_front_end VALIDATE_FP " + flight_plan_manager.selected_fp_id =: ivybus.out
	}

	FSM repr {
		State idle 
		State show_fp_info {
			FillColor _ (White)
			Text _txt_id (x0 + 50, y0 + 100, "FLIGHT PLAN ID : ")
			Text txt_id (x0 + 50 + _txt_id.width + 10, y0 + 100, "NO FP SELECTED")
			Text _txt_exp_start (x0 + 50, y0 + 130, "EXPECTED START : ")
			Text txt_exp_start (x0 + 50 + _txt_exp_start.width + 10, y0 + 130, "NO FP SELECTED")
			Text _txt_exp_end (x0 + 50, y0 + 160, "EXPECTED END : ")
			Text txt_exp_end (x0 + 50 + _txt_exp_end.width + 10, y0 + 160, "NO FP SELECTED")
			Button validate_button (frame, "ACCEPT FP", x0 + 70, y0 + 220)
/*			validate_button.click -> {"VALIDATE FP WITH ID = " + flight_plan_manager.selected_fp_id =: log.input}
			validate_button.click -> {"ausart_front_end VALIDATE_FP " + flight_plan_manager.selected_fp_id =: ivybus.out}*/
			//validate_button.click -> flight_plan_manager.fp_auth
			validate_button.click -> as_test
			Button reject_button (frame, "REJECT_FP", x0 + 200, y0 + 220)
			reject_button.click -> {"REJECT FP WITH ID = " + flight_plan_manager.selected_fp_id =: log2.input}
			reject_button.click -> {"ausart_front_end REJECT_FP " + flight_plan_manager.selected_fp_id =: ivybus.out}
			reject_button.click -> back_to_idle_from_show_fp
			validate_button.click -> back_to_idle_from_show_fp
		}
		idle -> show_fp_info (flight_plan_manager.show_fp_info)
		show_fp_info -> idle (back_to_idle_from_show_fp)
	}

	txt_fp_id aka repr.show_fp_info.txt_id.text
	txt_fp_exp_start aka repr.show_fp_info.txt_exp_start.text
	txt_fp_exp_end aka repr.show_fp_info.txt_exp_end.text

	AssignmentSequence assign_and_show_fp_info (1) {
		"show_fp_info" =: repr.state
		flight_plan_manager.selected_fp_id =: txt_fp_id
		flight_plan_manager.selected_fp_exp_start =: txt_fp_exp_start
		flight_plan_manager.selected_fp_exp_end =: txt_fp_exp_end
	}

	flight_plan_manager.show_fp_info -> assign_and_show_fp_info

}