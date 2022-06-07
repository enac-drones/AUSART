use core
use base
use gui
use display



_define_
Trajectory(string id, string fp_id, Process _ivybus, Process show_info, Process assign_info) {

	TextPrinter log

	OutlineColor repr_color (255, 255, 0)
	OutlineWidth ow (0.01)
	List line_list

	Spike pressed

	pressed -> show_info
	pressed -> assign_info

	"NEW TRAJ WITH FP ID = " + fp_id + " AND ID = " + id =: log.input

	String new_section_fp_id ("")
	String new_section_id ("")
	Double new_point1_lat (0)
	Double new_point1_lon (0) 
	Double new_point2_lat (0)
	Double new_point2_lon (0)

	_ivybus.in.new_flight_plan_section_traj_line[1] => new_section_fp_id
	_ivybus.in.new_flight_plan_section_traj_line[2] => new_section_id
	_ivybus.in.new_flight_plan_section_traj_line[3] => new_point1_lon
	_ivybus.in.new_flight_plan_section_traj_line[4] => new_point1_lat
	_ivybus.in.new_flight_plan_section_traj_line[5] => new_point2_lon
	_ivybus.in.new_flight_plan_section_traj_line[6] => new_point2_lat

	TextComparator tc_fp_id (fp_id, "")
	new_section_fp_id => tc_fp_id.right

	TextComparator tc_section_id (id, "")
	new_section_id => tc_section_id.right

	Bool add_line (0)

	tc_fp_id.output && tc_section_id.output => add_line

	add_line.true -> add_new_line:(this){
		addChildrenTo this.line_list {
			Line l ($this.new_point1_lon, - $this.new_point1_lat, $this.new_point2_lon, - $this.new_point2_lat)
			l.press -> this.pressed
		}
	}
}