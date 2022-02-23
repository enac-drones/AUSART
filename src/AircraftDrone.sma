use core
use base
use gui
use display


_define_
AircraftDrone (int _id, Process _callsign, Process _ivybus) {

	TextPrinter log
	TextPrinter log2

	Int id (_id)

	"AC " + id + " CREATED" =: log.input
 
	String callsign ("no_callsign")
	_callsign =: callsign

	Double lat(0)
	Double lon(0)

	Double repr_size (0)
	1 / 2444.579709 =: repr_size

	String current_sector ("no_sect")

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
		id =:> txt_id.text
		Text txt_current_sector(0, 35, "TEST TEXT")
		current_sector =:> txt_current_sector.text
	}


	// UPDATE ACCORDING TO FLIGHT PARAMS //
	TextComparator tc_ac_id ("a", "b")
	id =: tc_ac_id.left
	_ivybus.in.update_ac[1] => tc_ac_id.right

	//_ivybus.in.update_ac[1] => log2.input

	AssignmentSequence assign_ac_params (1){
		_ivybus.in.update_ac[2] =: lat
		_ivybus.in.update_ac[3] =: lon
		_ivybus.in.update_ac[4] =: current_sector
	}

	tc_ac_id.output.true -> assign_ac_params

	"AC " + id + " UPDATED WITH LAT = " + lat + " LON " + lon => log2.input

	// DELETION //
	TextComparator tc_ac_id_delete ("a", "b")
	id =: tc_ac_id_delete.left
	_ivybus.in.delete_ac[1] => tc_ac_id_delete.right

	tc_ac_id_delete.output.true -> del_this:(this) {
		delete this
	}


}