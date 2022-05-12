use core
use base
use gui
use display

import Sector
import Button


_define_
SectorManager(Process _frame, Process set_no_restriction, Process set_req_authorisation, Process set_prohibited, Process set_conditional, Process _ivybus) {

	TextPrinter log
	TextPrinter log2

	List sector_list

	Ref ivybus (_ivybus)
	Ref frame (_frame)

	String new_sector_id ("")
	String new_sector_restriction ("")

	_ivybus.in.area_init[1] => new_sector_id
	_ivybus.in.area_init[2] => new_sector_restriction

	//"FROM SECT MANAGER " + _ivybus.in.point_area_init[1] => log.input
	
	new_sector_id -> add_new_area:(this){
		addChildrenTo this.sector_list {
			Sector s (this, toString(this.new_sector_id), toString(this.new_sector_restriction), getRef(this.ivybus), getRef(this.frame))
		}
	}
	add_new_area~>_ivybus.in.point_area_init[1] // je sais pas trop pourquoi mais c'est necessaire


	// SELECTION & DESELECTION MANAGEMENT //
	Ref selection_request (null)
	Ref deselection_request (null)

	Spike deselect_all

	List selected_sectors

	selected_sectors.size -> {"LIST SELECTED SECTORS SIZE = " + selected_sectors.size =: log2.input}

	selection_request -> l_sel_req:(this){
		selected = getRef(&this.selection_request)
		if (&selected != null){
			addChildrenTo this.selected_sectors {
				Ref new_ref (selected)
			}
		}
	}

	deselection_request -> l_desel_req:(this){
		item = getRef(&this.deselection_request)
		if (&item != null){
			for (int i = 1; i <= $this.selected_sectors.size; i++){
				sel_item = getRef(&this.selected_sectors.[i])
				if (&sel_item == & item){
					delete this.selected_sectors.[i]
				}
			}
		}
	}

	// RESTRICTION MANAGEMENT //
/*	Spike set_no_restriction
	Spike set_req_authorisation
	Spike set_prohibited
	Spike set_conditional*/

	// UPDATE RESTRICTION //
	set_no_restriction -> change_to_no_restriction:(this){
		for (int i = 1; i <= $this.selected_sectors.size; i++){
			sect = getRef(&this.selected_sectors.[i])
			if (&sect != null){
				sect.restriction = "no_restriction"
			}
		}
		for (int i = 1; i <= $this.selected_sectors.size; i++){
			delete this.selected_sectors.[1]
		}
	}
	set_no_restriction -> deselect_all

	set_req_authorisation -> change_to_req_authorisation:(this){
		for (int i = 1; i <= $this.selected_sectors.size; i++){
			sect = getRef(&this.selected_sectors.[i])
			if (&sect != null){
				sect.restriction = "req_authorisation"
			}
		}
		for (int i = 1; i <= $this.selected_sectors.size; i++){
			delete this.selected_sectors.[1]
		}
	}
	set_req_authorisation -> deselect_all

	set_prohibited -> change_to_prohibited:(this){
		for (int i = 1; i <= $this.selected_sectors.size; i++){
			sect = getRef(&this.selected_sectors.[i])
			if (&sect != null){
				sect.restriction = "prohibited"
			}
		}
		for (int i = 1; i <= $this.selected_sectors.size; i++){
			delete this.selected_sectors.[1]
		}
	}
	set_prohibited -> deselect_all

	set_conditional -> change_to_conditional:(this){
		for (int i = 1; i <= $this.selected_sectors.size; i++){
			sect = getRef(&this.selected_sectors.[i])
			if (&sect != null){
				sect.restriction = "conditional"
			}
		}
		for (int i = 1; i <= $this.selected_sectors.size; i++){
			delete this.selected_sectors.[1]
		}
	}
	set_conditional-> deselect_all


}