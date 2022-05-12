use core
use base
use gui
use display



_define_
Sector (string _sector_id, string _init_restriction, Process _ivybus, Process frame){

	TextPrinter log 
	TextPrinter log2
	TextPrinter log3
	TextPrinter log4
	TextPrinter log5

	String sector_id (_sector_id)
	String restriction (_init_restriction)
	"NEW SECTOR CREATED : " + sector_id + " WITH RESTRICTION " + restriction =: log.input

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

	// tc_sect_id.output.true -> {"NEW POINT FOR SECT " + sector_id + " WITH COORD : LAT = " + new_point_lat + ", LON = " + new_point_lon =: log.input}

	// MANAGE USER INTERACTIONS ON SECTOR //
	// sector_poly.press -> {"CLICK ON SECTOR " + sector_id =: log2.input}

	
	FSM sect_repr {
		State not_selected {
			0.0001 =: out_width.width
			0 =: fo.a
		}
		State selected {
			0.0008 =: out_width.width
			1 =: fo.a
		}
		not_selected -> selected (sector_poly.press)
		selected -> not_selected (sector_poly.press)
	}

	sect_repr.state -> {"STATE CHANGED FOR " + sector_id + ", NEW STATE : " + sect_repr.state =: log2.input}

	



}