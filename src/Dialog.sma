use core
use base
use gui
use display



_define_
Dialog (double x, double y) {

	Spike show
	Spike hide

	FillColor fc (Blue)

	Switch repr (idle) {
		Component idle
		Component show {
			Rectangle rc (x, y, 10, 10, 0, 0)
		}
	}

	show -> {"show" =: repr.state}
	hide -> {"idle" =: repr.state}

}