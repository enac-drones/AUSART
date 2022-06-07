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

	Spike back_to_idle_from_show_fp_req_auth

	AssignmentSequence as_validate (1) {
		"VALIDATE FP WITH ID = " + flight_plan_manager.selected_fp_id =: log.input
		"ausart_front_end VALIDATE_FP " + flight_plan_manager.selected_fp_id =: ivybus.out
	}

	AssignmentSequence as_reject (1) {
		"REJECT FP WITH ID = " + flight_plan_manager.selected_fp_id =: log2.input
		"ausart_front_end REJECT_FP " + flight_plan_manager.selected_fp_id =: ivybus.out
	}

	FSM repr {
		State idle 
		State show_fp_info_req_auth {
			FillColor _ (White)
			Text _txt_id (x0 + 50, y0 + 100, "FLIGHT PLAN ID : ")
			Text txt_id (x0 + 50 + _txt_id.width + 10, y0 + 100, "NO FP SELECTED")
			Text _txt_exp_start (x0 + 50, y0 + 130, "EXPECTED START : ")
			Text txt_exp_start (x0 + 50 + _txt_exp_start.width + 10, y0 + 130, "NO FP SELECTED")
			Text _txt_exp_end (x0 + 50, y0 + 160, "EXPECTED END : ")
			Text txt_exp_end (x0 + 50 + _txt_exp_end.width + 10, y0 + 160, "NO FP SELECTED")
			Button validate_button (frame, "ACCEPT FP", x0 + 70, y0 + 220)
			validate_button.click -> flight_plan_manager.fp_auth
			validate_button.click -> as_validate
			Button reject_button (frame, "REJECT_FP", x0 + 200, y0 + 220)
			reject_button.click -> flight_plan_manager.fp_reject
			reject_button.click -> as_reject
			reject_button.click -> back_to_idle_from_show_fp_req_auth
			validate_button.click -> back_to_idle_from_show_fp_req_auth
		}
		State show_fp_info {
			FillColor _ (White)
			Text _txt_id (x0 + 50, y0 + 100, "FLIGHT PLAN ID : ")
			Text txt_id (x0 + 50 + _txt_id.width + 10, y0 + 100, "NO FP SELECTED")
			Text _txt_exp_start (x0 + 50, y0 + 130, "EXPECTED START : ")
			Text txt_exp_start (x0 + 50 + _txt_exp_start.width + 10, y0 + 130, "NO FP SELECTED")
			Text _txt_exp_end (x0 + 50, y0 + 160, "EXPECTED END : ")
			Text txt_exp_end (x0 + 50 + _txt_exp_end.width + 10, y0 + 160, "NO FP SELECTED")
		}
		idle -> show_fp_info_req_auth (flight_plan_manager.show_fp_info_req_auth)
		idle -> show_fp_info (flight_plan_manager.show_fp_info)
		show_fp_info_req_auth -> idle (back_to_idle_from_show_fp_req_auth)
		show_fp_info -> idle (frame.press)
	}

	txt_fp_id aka repr.show_fp_info.txt_id.text
	txt_fp_id_2 aka repr.show_fp_info_req_auth.txt_id.text
	txt_fp_exp_start aka repr.show_fp_info.txt_exp_start.text
	txt_fp_exp_start_2 aka repr.show_fp_info_req_auth.txt_exp_start.text
	txt_fp_exp_end aka repr.show_fp_info.txt_exp_end.text
	txt_fp_exp_end_2 aka repr.show_fp_info_req_auth.txt_exp_end.text

	AssignmentSequence assign_fp_info (1) {
		//"show_fp_info" =: repr.state
		flight_plan_manager.selected_fp_id =: txt_fp_id, txt_fp_id_2
		flight_plan_manager.selected_fp_exp_start =: txt_fp_exp_start, txt_fp_exp_start_2
		flight_plan_manager.selected_fp_exp_end =: txt_fp_exp_end, txt_fp_exp_end_2
	}

	flight_plan_manager.show_fp_info -> assign_fp_info
	flight_plan_manager.show_fp_info_req_auth -> assign_fp_info

}