use core
use base
use gui
use display



_define_
Dialog (double f_width, double f_height) {

	Spike show
	Spike hide

	Double self_width (600)
	Double self_height (f_height)

	FillColor fc (Black)
	Rectangle rc (f_width - $self_width, 0, $self_width, $self_height, 0, 0)

	Switch repr (idle) {
		Component idle 
		Component show 
	}

	show -> {"show" =: repr.state}
	hide -> {"idle" =: repr.state}

}