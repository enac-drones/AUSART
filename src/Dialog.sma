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
	TextPrinter log4

	Double self_width (600)
	Double self_height ($frame.height)

	FillColor fc (Black)
	OutlineColor oc (200, 200, 200)
	OutlineWidth ow (5)
	Rectangle rc ($frame.width - $self_width, 0, $self_width, $self_height, 0, 0)

	Double x0 ($rc.x)
	Double y0 (0)

	FillColor _ (Red)
	Rectangle quit_rect (x0 + 10, y0 + 10, 10, 10, 0, 0)

	Spike back_to_idle

	AssignmentSequence as_validate (1) {
		"VALIDATE FP WITH ID = " + flight_plan_manager.selected_fp_id =: log.input
		"ausart_front_end VALIDATE_FP " + flight_plan_manager.selected_fp_id =: ivybus.out
	}

	AssignmentSequence as_reject (1) {
		"REJECT FP WITH ID = " + flight_plan_manager.selected_fp_id =: log2.input
		"ausart_front_end REJECT_FP " + flight_plan_manager.selected_fp_id =: ivybus.out
	}

	AssignmentSequece as_interrupt (1) {
		"INTERRUPT FP WITH ID = " + flight_plan_manager.selected_fp_id =: log4.input
		"ausart_front_end INTERRUPT_FP " + flight_plan_manager.selected_fp_id =: ivybus.out
	}

	FSM repr {
		State idle 
		State show_fp_info_req_auth {
			FillColor _ (White)
			Text _txt_id (x0 + 50, y0 + 100, "FLIGHT PLAN ID : ")
			Text txt_id (x0 + 50 + _txt_id.width + 10, y0 + 100, "NO")
			Text _txt_exp_start (x0 + 50, y0 + 130, "EXPECTED START : ")
			Text txt_exp_start (x0 + 50 + _txt_exp_start.width + 10, y0 + 130, "NO")
			Text _txt_exp_end (x0 + 50, y0 + 160, "EXPECTED END : ")
			Text txt_exp_end (x0 + 50 + _txt_exp_end.width + 10, y0 + 160, "NO")
			Text _txt_max_alt (x0 + 50, y0 + 190, "MAX ALT : ")
			Text txt_max_alt (x0 + 50 + _txt_max_alt.width + 10, y0 + 190, "NO")
			Text _txt_ft (txt_max_alt.x + txt_max_alt.width + 15, y0 + 190, "ft")
			Text _txt_operation_type (x0 + 50, y0 + 220, "OP TYPE : ")
			Text txt_operation_type (x0 + 50 + _txt_operation_type.width + 10, y0 + 220, "NO")
			Text _txt_operation_domain (x0 + 50, y0 + 250, "OP DOMAIN : ")
			Text txt_operation_domain (x0 + 50 + _txt_operation_domain.width + 10, y0 + 250, "NO")
			Text _txt_drone_class (x0 + 50, y0 + 280, "DRONE CLASS : ")
			Text txt_drone_class (x0 + 50 + _txt_drone_class.width + 10, y0 + 280, "NO")
			Text _txt_drone_type (x0 + 50, y0 + 310, "DRONE TYPE : ")
			Text txt_drone_type (x0 + 50 + _txt_drone_type.width + 10, y0 + 310, "NO")
			Text _txt_status (x0 + 50, y0 + 340, "STATUS : ")
			Text txt_status (x0 + 50 + _txt_status.width + 10, y0 + 340, "NO")
			Button validate_button (frame, "ACCEPT FP", x0 + 70, y0 + 370)
			validate_button.click -> flight_plan_manager.fp_auth
			validate_button.click -> as_validate
			Button reject_button (frame, "REJECT_FP", x0 + 200, y0 + 370)
			reject_button.click -> flight_plan_manager.fp_reject
			reject_button.click -> as_reject
			reject_button.click -> back_to_idle
			validate_button.click -> back_to_idle
		}
		State show_fp_info_req_activate {
			FillColor _ (White)
			Text _txt_id (x0 + 50, y0 + 100, "FLIGHT PLAN ID : ")
			Text txt_id (x0 + 50 + _txt_id.width + 10, y0 + 100, "NO")
			Text _txt_exp_start (x0 + 50, y0 + 130, "EXPECTED START : ")
			Text txt_exp_start (x0 + 50 + _txt_exp_start.width + 10, y0 + 130, "NO")
			Text _txt_exp_end (x0 + 50, y0 + 160, "EXPECTED END : ")
			Text txt_exp_end (x0 + 50 + _txt_exp_end.width + 10, y0 + 160, "NO")
			Text _txt_max_alt (x0 + 50, y0 + 190, "MAX ALT : ")
			Text txt_max_alt (x0 + 50 + _txt_max_alt.width + 10, y0 + 190, "NO")
			Text _txt_ft (txt_max_alt.x + txt_max_alt.width + 15, y0 + 190, "ft")
			Text _txt_operation_type (x0 + 50, y0 + 220, "OP TYPE : ")
			Text txt_operation_type (x0 + 50 + _txt_operation_type.width + 10, y0 + 220, "NO")
			Text _txt_operation_domain (x0 + 50, y0 + 250, "OP DOMAIN : ")
			Text txt_operation_domain (x0 + 50 + _txt_operation_domain.width + 10, y0 + 250, "NO")
			Text _txt_drone_class (x0 + 50, y0 + 280, "DRONE CLASS : ")
			Text txt_drone_class (x0 + 50 + _txt_drone_class.width + 10, y0 + 280, "NO")
			Text _txt_drone_type (x0 + 50, y0 + 310, "DRONE TYPE : ")
			Text txt_drone_type (x0 + 50 + _txt_drone_type.width + 10, y0 + 310, "NO")
			Text _txt_status (x0 + 50, y0 + 340, "STATUS : ")
			Text txt_status (x0 + 50 + _txt_status.width + 10, y0 + 340, "NO")
			Button validate_button (frame, "ALLOW", x0 + 70, y0 + 370)
			validate_button -> flight_plan_manager.fp_activate
			Button reject_button (frame, "DENY", x0 + 200, y0 + 370)
			reject_button.click -> back_to_idle
			validate_button.click -> back_to_idle
		}
		State show_fp_info_activated {
			FillColor _ (White)
			Text _txt_id (x0 + 50, y0 + 100, "FLIGHT PLAN ID : ")
			Text txt_id (x0 + 50 + _txt_id.width + 10, y0 + 100, "NO")
			Text _txt_exp_start (x0 + 50, y0 + 130, "EXPECTED START : ")
			Text txt_exp_start (x0 + 50 + _txt_exp_start.width + 10, y0 + 130, "NO")
			Text _txt_exp_end (x0 + 50, y0 + 160, "EXPECTED END : ")
			Text txt_exp_end (x0 + 50 + _txt_exp_end.width + 10, y0 + 160, "NO")
			Text _txt_max_alt (x0 + 50, y0 + 190, "MAX ALT : ")
			Text txt_max_alt (x0 + 50 + _txt_max_alt.width + 10, y0 + 190, "NO")
			Text _txt_ft (txt_max_alt.x + txt_max_alt.width + 15, y0 + 190, "ft")
			Text _txt_operation_type (x0 + 50, y0 + 220, "OP TYPE : ")
			Text txt_operation_type (x0 + 50 + _txt_operation_type.width + 10, y0 + 220, "NO")
			Text _txt_operation_domain (x0 + 50, y0 + 250, "OP DOMAIN : ")
			Text txt_operation_domain (x0 + 50 + _txt_operation_domain.width + 10, y0 + 250, "NO")
			Text _txt_drone_class (x0 + 50, y0 + 280, "DRONE CLASS : ")
			Text txt_drone_class (x0 + 50 + _txt_drone_class.width + 10, y0 + 280, "NO")
			Text _txt_drone_type (x0 + 50, y0 + 310, "DRONE TYPE : ")
			Text txt_drone_type (x0 + 50 + _txt_drone_type.width + 10, y0 + 310, "NO")
			Text _txt_status (x0 + 50, y0 + 340, "STATUS : ")
			Text txt_status (x0 + 50 + _txt_status.width + 10, y0 + 340, "NO")
			Button interrupt_button (frame, "INTERRUPT", x0 + 70, y0 + 370)
			interrupt_button.click -> flight_plan_manager.fp_interrupt
			interrupt_button.click -> as_interrupt
			interrupt_button.click -> back_to_idle
		}
		State show_fp_info {
			FillColor _ (White)
			Text _txt_id (x0 + 50, y0 + 100, "FLIGHT PLAN ID : ")
			Text txt_id (x0 + 50 + _txt_id.width + 10, y0 + 100, "NO")
			Text _txt_exp_start (x0 + 50, y0 + 130, "EXPECTED START : ")
			Text txt_exp_start (x0 + 50 + _txt_exp_start.width + 10, y0 + 130, "NO")
			Text _txt_exp_end (x0 + 50, y0 + 160, "EXPECTED END : ")
			Text txt_exp_end (x0 + 50 + _txt_exp_end.width + 10, y0 + 160, "NO")
			Text _txt_max_alt (x0 + 50, y0 + 190, "MAX ALT : ")
			Text txt_max_alt (x0 + 50 + _txt_max_alt.width + 10, y0 + 190, "NO")
			Text _txt_ft (txt_max_alt.x + txt_max_alt.width + 15, y0 + 190, "ft")
			Text _txt_operation_type (x0 + 50, y0 + 220, "OP TYPE : ")
			Text txt_operation_type (x0 + 50 + _txt_operation_type.width + 10, y0 + 220, "NO")
			Text _txt_operation_domain (x0 + 50, y0 + 250, "OP DOMAIN : ")
			Text txt_operation_domain (x0 + 50 + _txt_operation_domain.width + 10, y0 + 250, "NO")
			Text _txt_drone_class (x0 + 50, y0 + 280, "DRONE CLASS : ")
			Text txt_drone_class (x0 + 50 + _txt_drone_class.width + 10, y0 + 280, "NO")
			Text _txt_drone_type (x0 + 50, y0 + 310, "DRONE TYPE : ")
			Text txt_drone_type (x0 + 50 + _txt_drone_type.width + 10, y0 + 310, "NO")
			Text _txt_status (x0 + 50, y0 + 340, "STATUS : ")
			Text txt_status (x0 + 50 + _txt_status.width + 10, y0 + 340, "NO")
		}
		idle -> show_fp_info_req_auth (flight_plan_manager.show_dialog_req_auth)
		idle -> show_fp_info (flight_plan_manager.show_dialog)
		idle -> show_fp_info_req_activate (flight_plan_manager.show_dialog_req_activate)
		idle -> show_fp_info_activated (flight_plan_manager.show_dialog_activated)
		show_fp_info_req_auth -> show_fp_info (flight_plan_manager.show_dialog)
		show_fp_info -> show_fp_info_req_auth (flight_plan_manager.show_dialog_req_auth)
		show_fp_info_req_auth -> idle (back_to_idle)
		show_fp_info_req_activate -> idle (back_to_idle)
		show_fp_info_req_auth -> idle (quit_rect.press)
		show_fp_info -> idle (quit_rect.press)
		show_fp_info_req_activate -> idle (quit_rect.press)
		show_fp_info_activated -> idle (back_to_idle)
		show_fp_info_activated -> idle (quit_rect.press)
	}

	flight_plan_manager.selected_fp_id => repr.show_fp_info_req_auth.txt_id.text
	flight_plan_manager.selected_fp_exp_start => repr.show_fp_info_req_auth.txt_exp_start.text
	flight_plan_manager.selected_fp_exp_end => repr.show_fp_info_req_auth.txt_exp_end.text
	flight_plan_manager.selected_fp_max_alt => repr.show_fp_info_req_auth.txt_max_alt.text
	flight_plan_manager.selected_fp_operation_type => repr.show_fp_info_req_auth.txt_operation_type.text
	flight_plan_manager.selected_fp_operation_domain => repr.show_fp_info_req_auth.txt_operation_domain.text
	flight_plan_manager.selected_fp_drone_class => repr.show_fp_info_req_auth.txt_drone_class.text
	flight_plan_manager.selected_fp_drone_type => repr.show_fp_info_req_auth.txt_drone_type.text
	flight_plan_manager.selected_fp_status => repr.show_fp_info_req_auth.txt_status.text

	flight_plan_manager.selected_fp_id => repr.show_fp_info.txt_id.text
	flight_plan_manager.selected_fp_exp_start => repr.show_fp_info.txt_exp_start.text
	flight_plan_manager.selected_fp_exp_end => repr.show_fp_info.txt_exp_end.text
	flight_plan_manager.selected_fp_max_alt => repr.show_fp_info.txt_max_alt.text
	flight_plan_manager.selected_fp_operation_type => repr.show_fp_info.txt_operation_type.text
	flight_plan_manager.selected_fp_operation_domain => repr.show_fp_info.txt_operation_domain.text
	flight_plan_manager.selected_fp_drone_class => repr.show_fp_info.txt_drone_class.text
	flight_plan_manager.selected_fp_drone_type => repr.show_fp_info.txt_drone_type.text
	flight_plan_manager.selected_fp_status => repr.show_fp_info.txt_status.text

	flight_plan_manager.selected_fp_id => repr.show_fp_info_req_activate.txt_id.text
	flight_plan_manager.selected_fp_exp_start => repr.show_fp_info_req_activate.txt_exp_start.text
	flight_plan_manager.selected_fp_exp_end => repr.show_fp_info_req_activate.txt_exp_end.text
	flight_plan_manager.selected_fp_max_alt => repr.show_fp_info_req_activate.txt_max_alt.text
	flight_plan_manager.selected_fp_operation_type => repr.show_fp_info_req_activate.txt_operation_type.text
	flight_plan_manager.selected_fp_operation_domain => repr.show_fp_info_req_activate.txt_operation_domain.text
	flight_plan_manager.selected_fp_drone_class => repr.show_fp_info_req_activate.txt_drone_class.text
	flight_plan_manager.selected_fp_drone_type => repr.show_fp_info_req_activate.txt_drone_type.text
	flight_plan_manager.selected_fp_status => repr.show_fp_info_req_activate.txt_status.text

	flight_plan_manager.selected_fp_id => repr.show_fp_info_activated.txt_id.text
	flight_plan_manager.selected_fp_exp_start => repr.show_fp_info_activated.txt_exp_start.text
	flight_plan_manager.selected_fp_exp_end => repr.show_fp_info_activated.txt_exp_end.text
	flight_plan_manager.selected_fp_max_alt => repr.show_fp_info_activated.txt_max_alt.text
	flight_plan_manager.selected_fp_operation_type => repr.show_fp_info_activated.txt_operation_type.text
	flight_plan_manager.selected_fp_operation_domain => repr.show_fp_info_activated.txt_operation_domain.text
	flight_plan_manager.selected_fp_drone_class => repr.show_fp_info_activated.txt_drone_class.text
	flight_plan_manager.selected_fp_drone_type => repr.show_fp_info_activated.txt_drone_type.text
	flight_plan_manager.selected_fp_status => repr.show_fp_info_activated.txt_status.text
}