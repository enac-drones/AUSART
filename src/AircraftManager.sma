use core
use base
use gui
use display

import AircraftDrone

/*_action_
delete_ac(Process src, Process data){

}
*/

_define_
AircraftManager (Process _ivybus) {

	TextPrinter log

	List aircraft_list

	Ref ivybus (_ivybus)

	Int ac_to_delete_id (0)

	Int new_ac_id (0)
	String new_ac_callsign ("no_callsign_yet")

	_ivybus.in.new_ac[1] => new_ac_id

	//_ivybus.in.update_ac[1] => log.input

	new_ac_id -> add_new_ac:(this){
		addChildrenTo this.aircraft_list {
			AircraftDrone _ ($this.new_ac_id, this.new_ac_callsign, getRef(this.ivybus))
		}
	}
	add_new_ac~>_ivybus.in.update_ac[1] // je sais pas trop pourquoi mais c'est necessaire

/*	NativeAction del_ac (delete_ac, 1)
	ListIterator list_iter (aircraft_list, del_ac, 0)*/


}

