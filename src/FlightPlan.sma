use core
use base
use gui
use display


import PolygonGeometry


 _define_
 FlightPlan(string id, Process _ivybus){

 	TextPrinter log
 	TextPrinter log3 

 	Ref ivybus (_ivybus)

 	String fp_id (id)
 	"NEW FLIGHT PLAN CREATED WITH ID = " + fp_id =: log.input

 	// RECEIVE NEW FP POLY //
 	String new_poly_section_fp_id ("")
 	String new_poly_section_id ("")
 	_ivybus.in.new_flight_plan_section_polygon[1] => new_poly_section_fp_id
 	_ivybus.in.new_flight_plan_section_polygon[2] => new_poly_section_id

 	// RECEIVE NEW FP CIRCLES //
  	String new_circle_section_fp_id ("")
 	String new_circle_section_id ("")
 	Double new_circle_section_center_lat (0)
 	Double new_circle_section_center_lon (0)
 	Double new_circle_section_radius (0) // 1 km =~ 0.036  

 	_ivybus.in.new_flight_plan_section_circle[1] => new_circle_section_fp_id
 	_ivybus.in.new_flight_plan_section_circle[2] => new_circle_section_id
 	_ivybus.in.new_flight_plan_section_circle[3] => new_circle_section_center_lat
 	_ivybus.in.new_flight_plan_section_circle[4] => new_circle_section_center_lon
 	_ivybus.in.new_flight_plan_section_circle[5] => new_circle_section_radius

	////////////////////
	// REPRESENTATION //
	////////////////////

	FillColor fc (Yellow)
	List geometries

	// KEEP ONLY MESSAGES ADRESSED TO THIS FLIGHT PLAN //
	TextComparator tc_fp_id_poly (id, "")
	new_poly_section_fp_id => tc_fp_id_poly.right

	TextComparator tc_fp_id_circle (id, "")
	new_circle_section_fp_id => tc_fp_id_circle.right

	// ADD POLYGON_GEOMETRY TO GEOMETRIES //
	tc_fp_id_poly.output.true -> add_new_polygon_geometry:(this){
		addChildrenTo this.geometries {
			PolygonGeometry _ (toString(this.new_poly_section_id), toString(this.fp_id), getRef(this.ivybus))
		}
	}
	add_new_polygon_geometry~>_ivybus.in.new_flight_plan_section_polygon_point[1]

	// ADD CIRCLE TO GEOMETRIES //
	tc_fp_id_circle.output.true -> add_new_circle_geometry:(this){
		addChildrenTo this.geometries {
			Circle _ ($this.new_circle_section_center_lon, - $this.new_circle_section_center_lat, $this.new_circle_section_radius * 0.000036)
		}
	}
 }