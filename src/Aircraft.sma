use core
use base
use gui
use display


_define_
Aircraft(int _id, string _callsign, Process _ivybus) {

	TextPrinter log
	TextPrinter log2
	TextPrinter log3

	Int id (_id)
	String callsign (_callsign)

	"AC " + id + " CREATED" =: log.input

	Double lat(0)
	Double lon(0)
	Int alt(0)

	//lon -> {"UPDATE POSITION " + lat + " " + lon =: log2.input}

	Double repr_size (0)
	1 / 2444.579709 =: repr_size

	Component radarRepr {
		Translation t (0, 0)
		lon => t.tx
		0 - lat => t.ty

		Scaling size (1, 1, 0, 0)
		repr_size =:> size.sx, size.sy

		FillColor fc (250, 250, 250)
		Circle c (0, 0, 2)

		Scaling text_size (0.7, 0.7, 0, 0)
		TextAnchor _ (1)
		Text txt_id (0, 18, "NO ID")
		callsign =:> txt_id.text
		Text txt_alt (0, 31, "")
		alt =:> txt_alt.text
	}

	// UPDATE ACCORDING TO FLIGHT PARAMS //
	TextComparator tc_ac_id ("a", "b")
	id =: tc_ac_id.left
	_ivybus.in.update_ac[1] => tc_ac_id.right

	AssignmentSequence assign_ac_params (1){
		_ivybus.in.update_ac[2] / 10000000 =: lat
		_ivybus.in.update_ac[3] / 10000000 =: lon
		(_ivybus.in.update_ac[4] / 1000) / 0.3031=: alt
	}

	tc_ac_id.output.true -> assign_ac_params

	// DELETION //
	TextComparator tc_ac_id_delete ("a", "b")
	id =: tc_ac_id_delete.left
	_ivybus.in.delete_ac[1] => tc_ac_id_delete.right

	tc_ac_id_delete.output.true -> del_this:(this) {
		delete this
	}

	//"AC " + id + " UPDATED WITH LAT = " + lat + " LON " + lon => log2.input

}