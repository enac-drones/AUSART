use core
use base
use gui
use display

_native_code_
%{
#include <math.h>
%}


_define_
PanAndZoom(Process move, Process press, Process release, Process dw, double init_zoom, double init_pan_x, double init_pan_y){

	// output
	Double zoom (init_zoom)
	Double xpan (init_pan_x)
	Double ypan (init_pan_y)

	Double mouseX (0)
	Double mouseY (0)

	// zoom management
	Double adw (0)
	Double transf_adw (0)
	Double dzoom (0)

	fabs($dw) =:> adw
	(0.0303 * adw + 0.00482) * adw +1.001 =:> transf_adw
	dw >= 0 ? transf_adw : 1/transf_adw =:> dzoom

	mouseTracking = 1

	Double last_move_x (0)
	Double last_move_y (0)
	move.x =:> last_move_x
	move.y =:> last_move_y

	Double new_zoom (1)
	Double new_xpan (0)
	Double new_ypan (0)

	AssignmentSequence zseq (1){
		dzoom * zoom =: new_zoom
		xpan + last_move_x / new_zoom - last_move_x / zoom =: new_xpan
		ypan + last_move_y / new_zoom - last_move_y / zoom =: new_ypan

		new_zoom =: zoom
		new_xpan =: xpan
		new_ypan =: ypan

		move.x =: mouseX
		move.y =: mouseY 
	}
	dzoom -> zseq

	// pan management
	Double xlast (0)
	Double ylast (0)

	FSM pan_control {
		State idle
		State pressing {
			press.x =: xlast
			press.y =: ylast
		}
		State panning {
			Double dx (0)
			Double dy (0)
			AssignmentSequence seq (1) {
				move.x - xlast =: dx
				move.y - ylast =: dy
				xpan + dx / zoom =: xpan
				ypan + dy / zoom =: ypan
				move.x =: xlast
				move.y =: ylast
			}
			move -> seq
		}
		idle -> pressing (press)
		pressing -> idle (release)
		pressing -> panning (move)
		panning -> idle (release)
	}

}