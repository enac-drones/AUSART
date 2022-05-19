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


	String sector_id (_sector_id)
	String restriction (_init_restriction)
	"NEW SECTOR CREATED : " + sector_id + " WITH RESTRICTION " + restriction =: log.input

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

	FillOpacity fo (0)
	FillColor fc (DarkSlateGrey)
	OutlineColor out_color (210, 210, 210)
	OutlineWidth out_width (0.0001)

	Polygon sector_poly 

	// KEEP ONLY THE MESSAGES ADRESSED TO THIS SECTOR //
	TextComparator tc_sect_id ("a", "b")
	sector_id =: tc_sect_id.left
	new_point_sect_id => tc_sect_id.right

	// ADD POINTS TO POLYGON //
	tc_sect_id.output.true -> add_new_point:(this){
		addChildrenTo this.sector_poly {
			Point _ ($this.new_point_lon, - $this.new_point_lat)
		}
		notify this.sector_poly
	}

	////////////////////////
	// FSM REPRESENTATION //
	////////////////////////

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
		Component no_restriction 
		Component conditional {
			0.0001 =: out_width.width
			244 =: new_state_r
			208 =: new_state_g
			63 =: new_state_b
		}
		Component req_authorisation {
			0.0001 =: out_width.width
			230 =: new_state_r
			126 =: new_state_g
			34 =: new_state_b
		}
		Component prohibited {
			0.0001 =: out_width.width
			231 =: new_state_r
			76 =: new_state_g
			60 =: new_state_b
		}
	}

	restriction =:> future_repr_color.state

	FSM sect_repr {
		State not_selected {
			0.0001 =: out_width.width
			this =: sect_manager.deselection_request
			Switch repr_auth (no_restriction) {
				Component no_restriction {
					0.0001 =: out_width.width
					0 =: fo.a
				}
				Component conditional {
					0.0001 =: out_width.width
					0.15 =: fo.a
					244 =: fc.r, former_state_r, transi_r
					208 =: fc.g, former_state_g, transi_g
					63 =: fc.b, former_state_b, transi_b
				}
				Component req_authorisation {
					0.0001 =: out_width.width
					0.3 =: fo.a
					230 =: fc.r, former_state_r, transi_r
					126 =: fc.g, former_state_g, transi_g
					34 =: fc.b, former_state_b, transi_b
				}
				Component prohibited {
					0.0001 =: out_width.width
					0.4 =: fo.a
					231 =: fc.r, former_state_r, transi_r
					76 =: fc.g, former_state_g, transi_g
					60 =: fc.b, former_state_b, transi_b
				}
			}
		}
		State selected {
			0.0008 =: out_width.width
			0.5 =: fo.a
			this =: sect_manager.selection_request
		}
		State before_transition {
			Timer t (0.1) // need some time to do some assignements, not the cleanest way but it works
			// to be changed someday
		}
		State transition {
			Timer timer_transition (2 * 60 * 1000)
			Clock cl (100)
			Int iter (0)

			0.4 =: fo.a

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
				transi_r =: fc.r 
				transi_g =: fc.g
				transi_b =: fc.b
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
			//cl.tick -> {"BOOL = " + iter_gt_steps + " / STEP R = " + step_r + " / ITER = " + iter + + " / TRANSI R = " + transi_r + " / R = " + fc.r =: log4.input}
		}
		not_selected -> selected (sector_poly.press)
		selected -> before_transition (start_transition)
		before_transition -> transition (before_transition.t.end)
		transition -> not_selected (transition.timer_transition.end)
		selected -> not_selected (sector_poly.press)
		selected -> not_selected (sect_manager.deselect_all)
	}

	repr_auth aka sect_repr.not_selected.repr_auth
	restriction =:> repr_auth.state

	sect_repr.state -> {"STATE CHANGED FOR " + sector_id + ", NEW STATE : " + sect_repr.state =: log2.input}

	restriction -> {"ausart_front_end SECT_RESTRICT_CHANGED " + sector_id + " " + restriction =: _ivybus.out}
}