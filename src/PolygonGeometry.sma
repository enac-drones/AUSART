use core
use base
use gui
use display



_define_
PolygonGeometry(string id, string fp_id, int _max_alt, Process _ivybus, Process assign_info, Process show_info) {

	TextPrinter log
	TextPrinter log2

	Int max_alt (_max_alt)

	Component buffer {
		FillColor repr_color (255, 255, 0)
		FillOpacity fill_opacity (0.8)
		OutlineColor outline_color (255, 255, 255)
		OutlineOpacity outline_opacity (1)
		OutlineWidth outline_width (0)
		Polygon poly 
	}

	Component max_alt_repr {
		FillColor _ (White)
		Double repr_size (0)
		1 / 2000.0 =: repr_size
		Scaling size (1, 1, 0, 0)
		repr_size =: size.sx, size.sy
		Double x_text (0)
		Double y_text (0)
		buffer.poly.bounding_box.x + buffer.poly.bounding_box.width / 2 => max_alt_repr.x_text
		buffer.poly.bounding_box.y + buffer.poly.bounding_box.height / 2 => max_alt_repr.y_text
		Text txt_max_alt (0, 0, "")
		x_text => size.cx, txt_max_alt.x
		y_text => size.cy, txt_max_alt.y
		toString(max_alt) + "ft" =: txt_max_alt.text
	}

	buffer.poly.press -> assign_info
	buffer.poly.press -> show_info

	"NEW POLYGON GEOMETRY WITH FP ID = " + fp_id + " AND ID = " + id =: log.input

	String new_section_fp_id ("")
	String new_section_id ("")
	Double new_point_lat (0)
	Double new_point_lon (0)
	_ivybus.in.new_flight_plan_section_polygon_point[1] => new_section_fp_id
	_ivybus.in.new_flight_plan_section_polygon_point[2] => new_section_id
	_ivybus.in.new_flight_plan_section_polygon_point[3] => new_point_lat
	_ivybus.in.new_flight_plan_section_polygon_point[4] => new_point_lon

	TextComparator tc_fp_id (fp_id, "")
	new_section_fp_id => tc_fp_id.right

	TextComparator tc_section_id (id, "")
	new_section_id => tc_section_id.right

	Bool add_point (0)

	tc_fp_id.output && tc_section_id.output => add_point

	//add_point.true -> {"ADDING POINT TO FLIGHT PLAN ; X = " + new_point_lat + " / Y = " + new_point_lon =: log2.input}

	add_point.true -> add_new_point:(this){
		addChildrenTo this.buffer.poly {
			Point _ ($this.new_point_lon, - $this.new_point_lat)
		}
	}

}