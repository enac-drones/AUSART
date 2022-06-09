use core
use base
use gui
use display



_define_
Sector (Process sect_manager, string _sector_id, string _init_restriction, Process _ivybus, Process frame){

	TextPrinter log 
	TextPrinter log2
	TextPrinter log3
	TextPrinter log4
	TextPrinter log5
	TextPrinter log6
	TextPrinter log7

	Spike back_to_normal_conf

	String sector_id (_sector_id)
	String restriction (_init_restriction)
	String init_restriction (_init_restriction)
	"NEW SECTOR CREATED : " + sector_id + " WITH RESTRICTION " + restriction =: log.input

	back_to_normal_conf -> {init_restriction =: restriction}
	restriction -> {"CHANGING RESTRICTION OF SECTOR " + sector_id + " TO " + restriction =: log6.input}

	// STORE INFORMATION OF POINTS TO ADD TO SECTOR POLYGON //
	String new_point_sect_id ("")
	Double new_point_lat (0)
	Double new_point_lon (0)
	_ivybus.in.point_area_init[1] => new_point_sect_id
	_ivybus.in.point_area_init[2] => new_point_lat
	_ivybus.in.point_area_init[3] => new_point_lon

	////////////////////
	// REPRESENTATION //
	////////////////////

	Component poly {
		FillOpacity fo (0)
		FillColor fc (DarkSlateGrey)
		OutlineColor out_color (210, 210, 210)
		OutlineWidth out_width (0.0001)

		Polygon sector_poly 
	}

	// KEEP ONLY THE MESSAGES ADRESSED TO THIS SECTOR //
	TextComparator tc_sect_id ("a", "b")
	sector_id =: tc_sect_id.left
	new_point_sect_id => tc_sect_id.right

	// ADD POINTS TO POLYGON //
	tc_sect_id.output.true -> add_new_point:(this){
		addChildrenTo this.poly.sector_poly {
			Point _ ($this.new_point_lon, - $this.new_point_lat)
		}
		notify this.poly.sector_poly
	}

	////////////////////////
	// FSM REPRESENTATION //
	////////////////////////

	// COLOR CHOICE //
	Int no_restriction_r (255)
	Int no_restriction_g (0)
	Int no_restriction_b (0)

	Int conditional_r (255)
	Int conditional_g (0)
	Int conditional_b (0)

	Int req_authorisation_r (255)
	Int req_authorisation_g (0)
	Int req_authorisation_b (0)

	Int prohibited_r (0)
	Int prohibited_g (0)
	Int prohibited_b (0)

	// WIDTH AND OPACITY //
	Double fill_opacity_no_restriction (0.45)
	Double fill_opacity_conditional (0.3)
	Double fill_opacity_req_authorisation (0.15)
	Double fill_opacity_prohibited (0)
	Double fill_opacity_selected (0.5)

	Double out_width_selected (0.0008)
	Double out_width_not_selected (0.0001)

	// TRANSITION MANAGEMENT //
	Spike start_transition
	Spike start_transition_to_no_restrict

	Int former_state_r (0)
	Int former_state_g (0)
	Int former_state_b (0)

	Int new_state_r (0)
	Int new_state_g (0)
	Int new_state_b (0)

	Double transi_r (0)
	Double transi_g (0)
	Double transi_b (0)

	Double step_r (0)
	Double step_g (0)
	Double step_b (0)

	Int steps (11)

	Switch future_repr_color (no_restriction) {
		Component no_restriction {
			no_restriction_r =: new_state_r
			no_restriction_g =: new_state_g
			no_restriction_b =: new_state_b
		}
		Component conditional {
			conditional_r =: new_state_r
			conditional_g =: new_state_g
			conditional_b =: new_state_b
		}
		Component req_authorisation {
			req_authorisation_r =: new_state_r
			req_authorisation_g =: new_state_g
			req_authorisation_b =: new_state_b
		}
		Component prohibited {
			prohibited_r =: new_state_r
			prohibited_g =: new_state_g
			prohibited_b =: new_state_b
		}
	}

	restriction =:> future_repr_color.state

	FSM sect_repr {
		State not_selected {
			this =: sect_manager.deselection_request
			Switch repr_auth (no_restriction) {
				Component no_restriction {
					out_width_not_selected =: poly.out_width.width
					fill_opacity_no_restriction =: poly.fo.a
					no_restriction_r =: poly.fc.r, former_state_r, transi_r
					no_restriction_g =: poly.fc.g, former_state_g, transi_g
					no_restriction_b =: poly.fc.b, former_state_b, transi_b
				}
				Component conditional {
					out_width_not_selected =: poly.out_width.width
					fill_opacity_conditional =: poly.fo.a
					no_restriction_r =: poly.fc.r, former_state_r, transi_r
					no_restriction_g =: poly.fc.g, former_state_g, transi_g
					no_restriction_b =: poly.fc.b, former_state_b, transi_b
				}
				Component req_authorisation {
					out_width_not_selected =: poly.out_width.width
					fill_opacity_req_authorisation =: poly.fo.a
					req_authorisation_r =: poly.fc.r, former_state_r, transi_r
					req_authorisation_g =: poly.fc.g, former_state_g, transi_g
					req_authorisation_b =: poly.fc.b, former_state_b, transi_b
				}
				Component prohibited {
					out_width_not_selected =: poly.out_width.width
					fill_opacity_prohibited =: poly.fo.a
					prohibited_r =: poly.fc.r, former_state_r, transi_r
					prohibited_g =: poly.fc.g, former_state_g, transi_g
					prohibited_b =: poly.fc.b, former_state_b, transi_b
				}
			}
		}
		State selected {
			out_width_selected =: poly.out_width.width
			//fill_opacity_selected =: fo.a
			this =: sect_manager.selection_request
		}
		State before_transition {
			Timer t (0.1) // need some time to do some assignements, not the cleanest way but it works
			// to be changed someday
		}
		State transition {
			out_width_not_selected =: poly.out_width.width

			Int transi_time (20 * 1000)
			Timer timer_transition ($transi_time)

			Int elapsed_time (0)
			Clock cl_elapsed_time (1000)
			cl_elapsed_time.tick -> {elapsed_time + 1 =: elapsed_time}
			Clock cl (100)
			Int iter (0)

			0.4 =: poly.fo.a

			(new_state_r - former_state_r) / steps =: step_r
			(new_state_g - former_state_g) / steps =: step_g
			(new_state_b - former_state_b) / steps =: step_b

			Bool iter_gt_steps (0)

			AssignmentSequence transi_step (1) {
				// store color values in double
				transi_r + step_r =: transi_r 
				transi_g + step_g =: transi_g
				transi_b + step_b =: transi_b
				// and use double value for real color, avoids repetitive rounding errors that cause the color to change
				transi_r =: poly.fc.r 
				transi_g =: poly.fc.g
				transi_b =: poly.fc.b
				iter + 1 =: iter
				iter >= (steps-1) => iter_gt_steps
			}

			AssignmentSequence on_iter_gt_steps (1) {
				- step_r =: step_r
				- step_g =: step_g
				- step_b =: step_b
				0 =: iter
			}

			iter_gt_steps.true -> on_iter_gt_steps
			cl.tick -> transi_step

			Scaling size (1, 1, 0, 0)
			// 1 / 2444.579709 =: size.sx, size.sy
			FillColor _ (White)
			TextAnchor _ (1)
			Text text_timer (0, 0, "")
			Int remaining_time (0)
			poly.sector_poly.bounding_box.x + poly.sector_poly.bounding_box.width / 2 =:> text_timer.x
			poly.sector_poly.bounding_box.y + poly.sector_poly.bounding_box.height / 2 =:> text_timer.y
			transi_time / 1000 - elapsed_time => remaining_time
			remaining_time => text_timer.text
			text_timer.x =: size.cx
			text_timer.y =: size.cy
			1 / 2000.0 =: size.sx, size.sy
		} 
		not_selected -> selected (poly.sector_poly.press)
		selected -> before_transition (start_transition)
		before_transition -> transition (before_transition.t.end)
		transition -> not_selected (transition.timer_transition.end)
		selected -> not_selected (poly.sector_poly.press)
		selected -> not_selected (sect_manager.deselect_all)
	}

	repr_auth aka sect_repr.not_selected.repr_auth
	restriction =:> repr_auth.state

	sect_repr.state -> {"STATE CHANGED FOR " + sector_id + ", NEW STATE : " + sect_repr.state =: log2.input}

	restriction -> {"ausart_front_end SECT_RESTRICT_CHANGED " + sector_id + " " + restriction =: _ivybus.out}
}