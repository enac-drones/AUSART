use core
use base
use gui
use display

import Sector


_define_
SectorManager(Process _root, Process _ivybus) {

	TextPrinter log

	List sector_list

	Ref ivybus (_ivybus)
	Ref root (_root)

	String new_sector_id ("")
	String new_sector_restriction ("")

	_ivybus.in.area_init[1] => new_sector_id
	_ivybus.in.area_init[2] => new_sector_restriction

	//"FROM SECT MANAGER " + _ivybus.in.point_area_init[1] => log.input
	
	new_sector_id -> add_new_area:(this){
		addChildrenTo this.sector_list {
			Sector _ (toString(this.new_sector_id), toString(this.new_sector_restriction), getRef(this.ivybus), getRef(this.root))
		}
	}
	add_new_area~>_ivybus.in.point_area_init[1] // je sais pas trop pourquoi mais c'est necessaire


}