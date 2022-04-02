use core
use base
use gui
use display

import Sector


_define_
SectorManager(Process _root, Process _ivybus, Process _dialog) {

	TextPrinter log

	List sector_list

	Ref ivybus (_ivybus)
	Ref root (_root)
	Ref dialog (_dialog)

	String new_sector_id ("")

	_ivybus.in.area_init[1] => new_sector_id

	//"FROM SECT MANAGER " + _ivybus.in.point_area_init[1] => log.input
	
	new_sector_id -> add_new_area:(this){
		addChildrenTo this.sector_list {
			Sector _ (this.new_sector_id, getRef(this.ivybus), getRef(this.root), getRef(this.dialog))
		}
	}
	add_new_area~>_ivybus.in.point_area_init[1] // je sais pas trop pourquoi mais c'est necessaire


}