use core
use gui
use base
use display


import PanAndZoom
import AircraftManager
import SectorManager
import FlightPlanManager
import Dialog
import VFRPoint
import Heliport


_native_code_
%{
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <iostream>
#include <proj.h>

char* buildPath (const char* file)
{
  char* prefix = getcwd (NULL, 0);
  int sz = strlen (prefix) + strlen (file) + 9;
  char* path = (char*) malloc (sz * sizeof (char));
  sprintf (path, "file://%s/%s", prefix, file);
  path[sz-1] = '\0';
  free (prefix);
  return path;
}

void test(const double lat, const double lon, djnn::DoubleProperty* x, djnn::DoubleProperty* y)
{
	PJ_CONTEXT* pj_context;
	pj_context = proj_context_create();
  auto proj_4326_3857 = proj_create_crs_to_crs (pj_context,
    "EPSG:4326",
    "+proj=ortho +lat_0=43.64381 +lon_0=1.3723",
    nullptr);
  	auto plop = proj_trans (proj_4326_3857, PJ_FWD, proj_coord(lat, lon, 0, 0));
    x->set_value(plop.xy.x, 1);
    y->set_value(plop.xy.y, 1);
}
%}



_main_
Component root {

	TextPrinter log
	TextPrinter log2

	///////////
	// FRAME //
	///////////

	Frame f ("AUSART", 100, 100, 2000, 2000)
	Exit ex (0, 1)
	f.close -> ex
	mouseTracking = 1

	////////////////
	// BACKGROUND //
	////////////////

	FillColor _ (20, 20, 20)
	Rectangle bg (0, 0, 0, 0)

	f.width =:> bg.width
	f.height =:> bg.height

	Double lat_test (43.646236)
	Double lon_test (1.380367)
	Double x_test (0)
	Double y_test (0)

	Ref x_test_ref (x_test)
	Ref y_test_ref (y_test)

	test($lat_test, $lon_test, x_test, y_test)

	"X Y :" + x_test + " " + y_test =: log2.input

	////////////////
	// IVY ACCESS //
	////////////////

	IvyAccess ivybus ("127.255.255.255:2010", "AUSART_FRONT_END", "FRONT_END_READY") {
		String area_init ("ausart_back_end AREA_INIT (\\S*)")
		// ausart_back_end AREA_INIT area_id 
		String point_area_init ("ausart_back_end POINT_AREA_INIT (\\S*) (\\S*) (\\S*)")
		// ausart_back_end POINT_AREA_INIT area_id point_lat point_lon
		// String new_ac ("ausart_back_end NEW_AC (\\S*)")
		// ausart_back_end NEW_AC ac_id
		// String update_ac ("ausart_back_end UPDATE_AC (\\S*) (\\S*) (\\S*) (\\S*)")
		// ausart_back_end UPDATE_AC ac_id lat lon current_sector
		// String delete_ac ("ausart_back_end DELETE_AC (\\S*)")
		// ausart_back_end DELETE_AC ac_id
		String new_flight_plan ("ausart_back_end NEW_FP (\\S*) (\\S*) (\\S*)")
		// ausart_back_end NEW_FP fp_id exp_start exp_end
		String new_flight_plan_section_polygon ("ausart_back_end NEW_FP_SECTION_POLYGON (\\S*) (\\S*)")
		// ausart_back_end NEW_FP_SECTION_POLYGON fp_id section_id
		String new_flight_plan_section_circle ("ausart_back_end NEW_FP_SECTION_CIRCLE (\\S*) (\\S*) (\\S*) (\\S*) (\\S*)")
		// ausart_back_end NEW_FP_SECTION_CIRCLE fp_id section_id center_lat center_lon radius
		String new_flight_plan_section_polygon_point ("ausart_back_end NEW_FP_SECTION_POLYGON_POINT (\\S*) (\\S*) (\\S*) (\\S*)")
		// ausart_back_end NEW_FP_POLY_POINT fp_id section_id point_lat point_lon
	}


	//////////////////
	// PAN AND ZOOM //
	//////////////////

	FillColor _ (255, 255, 255)
	Text zoom_val (50, 50, "no zoom val")
	Text pan_val (50, 70, "no pan val")
	Text mouse_val (50, 90, "no mouse val")

	Component pan_and_zoom_layer {

		PanAndZoom pz (f.move, f.press, f.release, f.wheel.dy, 1882.996071, -0.978489, 43.926698)

		Scaling zoom_tr (1, 1, 0, 0)
		Translation pan_tr (0, 0)

		pz.zoom =:> zoom_tr.sx, zoom_tr.sy
		pz.{xpan, ypan} =:> pan_tr.{tx, ty}

		Double mouse_x (0)
		Double mouse_y (0)
		f.move.x / pz.zoom - pz.xpan => mouse_x
		-(f.move.y / pz.zoom - pz.ypan) => mouse_y

		"ZOOM = " + pz.zoom =:> zoom_val.text
		"PAN : X = " + pz.xpan + " / Y = " + pz.ypan =:> pan_val.text
		"MOUSE : X = " + mouse_x + " / Y = " + mouse_y =:> mouse_val.text

		//////////////////
		// MAP FEATURES //
		//////////////////
		Scaling correct_widthening (0.8, 1, 1.36389, -43.62896)

		Component map_features {
			// TOULOUSE 1.2 TMA //
			Component toulouse_1_2_tma {
				FillColor _ (250, 250, 250)
				FillOpacity _ (0.02)
				OutlineColor _ (210, 210, 210)
				OutlineWidth _ (0.0001)
				Polygon _ {
					Point _ (0.949160, -43.576940)
					Point _ (0.872220, -43.766110)
					Point _ (1.091660, -43.932220)
					Point _ (1.418880, -43.986110)
					Point _ (1.566110, -43.735270)
					Point _ (1.647220, -43.604160)
					Point _ (1.919160, -43.502770)
					Point _ (1.618880, -43.269160)
					Point _ (1.323610, -43.285830)
					Point _ (1.026660, -43.383610)
				}
			}

			// TOULOUSE 1.1 TMA //
			Component toulouse_1_1_tma {
				FillColor _ (250, 250, 250)
				FillOpacity _ (0.02)
				OutlineColor _ (210, 210, 210)
				OutlineWidth _ (0.0001)
				Polygon _ {
					Point _ (1.540278, -43.703611)
					Point _ (1.477778, -43.635000)
					Point _ (1.456667, -43.601389)
					Point _ (1.493889, -43.558056)
					Point _ (1.515278, -43.545278)
					Point _ (1.632222, -43.499722)
					Point _ (1.743330, -43.455830)
					Point _ (1.666380, -43.341940)
					Point _ (1.330270, -43.339160)
					Point _ (1.341660, -43.449440)
					Point _ (1.172220, -43.504440)
					Point _ (0.949160, -43.576940)
					Point _ (0.872220, -43.766110)
					Point _ (1.091660, -43.932220)
					Point _ (1.418880, -43.986110)
					Point _ (1.566110, -43.735270)
				}
			}

			// CTR BLAGNAC //
			Component ctr_blagnac {
				FillColor _ (250, 250, 250)
				FillOpacity _ (0.04)
				OutlineColor ctr_oc (210, 210, 210)
				OutlineWidth ctr_ow (0.0001)
				Polygon blagnac_ctr {
					Point _ (1.067778, -43.782500)
					Point _ (1.301667, -43.836111)
					Point _ (1.350000, -43.783333)
					Point _ (1.540278, -43.703611)
					Point _ (1.477778, -43.635000)
					Point _ (1.456667, -43.601389)
					Point _ (1.493889, -43.558056)
					Point _ (1.515278, -43.545278)
					Point _ (1.632222, -43.499722)
					Point _ (1.407778, -43.428056)
					Point _ (1.341667, -43.449444)
					Point _ (1.172222, -43.504444)
				}
			}

			// ZRT FRANCAZAL //
			Component r_23_francazal {
				NoFill _
				OutlineWidth _ (0.0005)
				OutlineColor _ (255, 30, 30)
				Polygon r_23_francazal_poly {
					Point _ (1.33777, -43.58055)
					Point _ (1.40083, -43.55999)
					Point _ (1.47794, -43.45071)
					Point _ (1.40777, -43.42805)
					Point _ (1.34166, -43.44944)
					Point _ (1.24477, -43.48128)
				}
			}

			// ZRT FONSORBES //
			Component r_112_fonsorbes {
				NoFill _
				OutlineWidth _ (0.0005)
				OutlineColor _ (255, 30, 30)
				Polygon r_112_fonsorbes_poly {
					Point _ (1.24477, -43.48128)
					Point _ (1.21222, -43.49194)
					Point _ (1.17500, -43.44222)
					Point _ (1.10194, -43.46972)
					Point _ (1.15777, -43.54111)
					Point _ (1.13973, -43.58986)
					Point _ (1.26861, -43.60361)
					Point _ (1.33777, -43.58055)
				}
			}

			// TOULOUSE URBAN AREA //
			Component toulouse_urban_area {
				OutlineWidth _ (0.0001)
				FillColor _ (LightGreen)
				FillOpacity _ (0.2)
				Polygon toulouse_urban_area_poly {
					Point _ (1.42473, -43.65270)
					Point _ (1.43314, -43.64884)
					Point _ (1.44421, -43.64673)
					Point _ (1.46515, -43.64617)
					Point _ (1.47664, -43.63853)
					Point _ (1.48499, -43.60569)
					Point _ (1.49297, -43.59661)
					Point _ (1.49838, -43.57964)
					Point _ (1.49374, -43.56911)
					Point _ (1.49486, -43.55219)
					Point _ (1.48868, -43.56196)
					Point _ (1.46851, -43.57470)
					Point _ (1.45887, -43.57217)
					Point _ (1.44265, -43.57583)
					Point _ (1.43438, -43.57117)
					Point _ (1.41997, -43.56850)
					Point _ (1.41019, -43.55457)
					Point _ (1.37494, -43.56890)
					Point _ (1.36033, -43.58931)
					Point _ (1.36943, -43.60873)
					Point _ (1.38076, -43.61178)
					Point _ (1.39417, -43.62105)
					Point _ (1.41725, -43.62449)
				}
			}

			// VFR POINTS //
			Component vfr_points {
				VFRPoint VFR_EN (1.59166, -43.74027, "EN")
				VFRPoint VFR_AE (1.66138, -43.69388, "AE")
				VFRPoint VFR_NA (1.39194, -43.70388, "NA")
				VFRPoint VFR_N (1.35, -43.78333, "N")
				VFRPoint VFR_EA (1.42527, -43.65833, "EA")
				VFRPoint VFR_EB (1.38333, -43.64527, "EB")
				VFRPoint VFR_AS (1.4975, -43.56388, "	AS")
				VFRPoint VFR_PI (1.55277, -43.53333, "PI")
				VFRPoint VFR_DS (1.60833, -43.54805, "DS")
				VFRPoint VFR_SL (1.66666, -43.48333, "SL")
				VFRPoint VFR_SB (1.62916, -43.44972, "SB")
				VFRPoint VFR_SA (1.44166, -43.4, "SA")
				VFRPoint VFR_SE (1.4425, -43.43333, "SE")
				VFRPoint VFR_SEA (1.3875, -43.51166, "SEA")
				VFRPoint VFR_WD (1.30694, -43.60638, "WD")
				VFRPoint VFR_WF (1.22805, -43.64027, "WF")
				VFRPoint VFR_WH (1.10277, -43.68555, "WH")
				VFRPoint VFR_SN (1.27499, 43.35833, "SN")
			}

			// HELIPORTS //
			Component Heliports {
				Heliport heli_purpan (1.4, -43.61305, "PURPAN")
				Heliport heli_rangueil (1.44861, -43.56111, "RANGUEIL")
			}

			// BLAGNAC RUNWAY AND AXIS //
			Component runways {
				OutlineWidth _ (0.0001)
				OutlineColor _ (250, 250, 250)
				Line runway_14R_32L (1.34587, -43.64381, 1.3723, -43.61891)
				Line runway_14L_32R (1.35784, -43.63723, 1.38016, -43.61592)
				Line south_axis (1.39247, -43.60092, 1.61803, -43.37802)
				Line mile10_south_left_arrow (1.5088, -43.48614, 1.5028, -43.46947)
				Line mile10_south_right_arrow (1.5088, -43.48614, 1.53246, -43.48457)
				Line north_axis (1.33267, -43.65962, 0.92613, -44.05539)
				Line mile10_north_left_arrow (1.20995, -43.77981, 1.18541, -43.78215)
				Line mile10_north_right_arrow (1.20995, -43.77981, 1.21421, -43.79602)
			}

			// 2 MILES COCENTRIC CIRCLES //
			Component circles {
				Scaling no_correct_wdithening (1.25, 1, 1.36389, -43.62896)
				OutlineColor _ (250, 250, 250)
				OutlineOpacity _ (0.5)
				OutlineWidth _ (0.0001)
				NoFill _ 
				Circle _ (1.36389, -43.62896, 0.036 * 1)
				Circle _ (1.36389, -43.62896, 0.036 * 2)
				Circle _ (1.36389, -43.62896, 0.036 * 3)
				Circle _ (1.36389, -43.62896, 0.036 * 4)
				Circle _ (1.36389, -43.62896, 0.036 * 5)
				Circle _ (1.36389, -43.62896, 0.036 * 6)
				Circle _ (1.36389, -43.62896, 0.036 * 7)
				Circle _ (1.36389, -43.62896, 0.036 * 8)
				Circle _ (1.36389, -43.62896, 0.036 * 9)
				Circle _ (1.36389, -43.62896, 0.036 * 10)
			}

			// GARONNE //
			Component Garonne {
				OutlineWidth _ (0.0003)
				OutlineColor _ (Blue)
				Line _ (1.31114, -43.74589, 1.32281, -43.73845)
				Line _ (1.32281, -43.73845, 1.33071, -43.72877)
				Line _ (1.33071, -43.72877, 1.34273, -43.72381)
				Line _ (1.34273, -43.72381, 1.34172, -43.71685)
				Line _ (1.34172, -43.71685, 1.35013, -43.70903)
				Line _ (1.35013, -43.70903, 1.36455, -43.70556)
				Line _ (1.36455, -43.70556, 1.36833, -43.69873)
				Line _ (1.36833, -43.69873, 1.36799, -43.68644)
				Line _ (1.36799, -43.68644, 1.38360, -43.66779)
				Line _ (1.38360, -43.66779, 1.40116, -43.66602)
				Line _ (1.40116, -43.66602, 1.40665, -43.65596)
				Line _ (1.40665, -43.65596, 1.40150, -43.64826)
				Line _ (1.40150, -43.64826, 1.40331, -43.63436)
				Line _ (1.40331, -43.63436, 1.40210, -43.61874)
				Line _ (1.40210, -43.61874, 1.41377, -43.60719)
				Line _ (1.41377, -43.60719, 1.43729, -43.60056)
				Line _ (1.43729, -43.60056, 1.43849, -43.59156)
				Line _ (1.43849, -43.59156, 1.42785, -43.57987)
				Line _ (1.42785, -43.57987, 1.43223, -43.56246)
				Line _ (1.43223, -43.56246, 1.43913, -43.55798)
				Line _ (1.43913, -43.55798, 1.43724, -43.54546)
				Line _ (1.43724, -43.54546, 1.42769, -43.52949)
				Line _ (1.42769, -43.52949, 1.41551, -43.52650)
				Line _ (1.41551, -43.52650, 1.40949, -43.51798)
				Line _ (1.40949, -43.51798, 1.38515, -43.51100)
				Line _ (1.38515, -43.51100, 1.36541, -43.50278)

				// MAIN ROADS //
				Component main_roads {
					OutlineWidth _ (0.0002)
					OutlineColor _ (Orange)
					// NORTH AXIS //
					Line _ (1.42467, -43.65309, 1.41557, -43.67608)
					Line _ (1.41557, -43.67608, 1.39603, -43.73406)
					Line _ (1.39603, -43.73406, 1.38167, -43.78781)
					Line _ (1.38167, -43.78781, 1.32055, -43.84800)
					Line _ (1.32055, -43.84800, 1.31815, -43.91840)
					Line _ (1.31815, -43.91840, 1.25532, -43.98039)
					// EAST AXIS //
					Line _ (1.47664, -43.63853, 1.52557, -43.65422)
					Line _ (1.52557, -43.65422, 1.54261, -43.65618)
					Line _ (1.54261, -43.65618, 1.56784, -43.69105)
					Line _ (1.56784, -43.69105, 1.56492, -43.71463)
					Line _ (1.56492, -43.71463, 1.58792, -43.73882)
					Line _ (1.58792, -43.73882, 1.63170, -43.74676)
					Line _ (1.63170, -43.74676, 1.66946, -43.75556)
					Line _ (1.66946, -43.75556, 1.69641, -43.75290)
					Line _ (1.69641, -43.75290, 1.74568, -43.78977)
					Line _ (1.74568, -43.78977, 1.81057, -43.81715)
					Line _ (1.81057, -43.81715, 1.89022, -43.85506)
					// SOUTH EAST AXIS //
					Line _ (1.49486, -43.55219, 1.56082, -43.47385)
					Line _ (1.56082, -43.47385, 1.59881, -43.45260)
					Line _ (1.59881, -43.45260, 1.62799, -43.43042)
					Line _ (1.62799, -43.43042, 1.72227, -43.38852)
					Line _ (1.72227, -43.38852, 1.83797, -43.33685)
					// SOUTH WEST AXIS //
					Line _ (1.41019, -43.55457, 1.37651, -43.51972)
					Line _ (1.37651, -43.51972, 1.33744, -43.49732)
					Line _ (1.33744, -43.49732, 1.30552, -43.45397)
					Line _ (1.30552, -43.45397, 1.30964, -43.43590)
					Line _ (1.30964, -43.43590, 1.26723, -43.35127)
					// WEST AXIS //
					Line _ (1.36943, -43.60873, 1.28336, -43.60422)
					Line _ (1.28336, -43.60422, 1.26791, -43.58620)
					Line _ (1.26791, -43.58620, 1.19375, -43.58110)
					Line _ (1.19375, -43.58110, 1.16903, -43.58918)
					Line _ (1.16903, -43.58918, 1.13161, -43.58160)
					Line _ (1.13161, -43.58160, 1.12371, -43.59391)
					Line _ (1.12371, -43.59391, 1.07685, -43.60509)
					Line _ (1.07685, -43.60509, 0.91372, -43.61776)
					Line _ (0.91372, -43.61776, 0.89174, -43.60683)
					Line _ (0.89174, -43.60683, 0.84711, -43.62124)
					Line _ (0.84711, -43.62124, 0.83990, -43.63392)
					Line _ (0.83990, -43.63392, 0.76459, -43.66023)
				}
			}



		}

		//////////////////////
		// AIRCRAFT MANAGER //
		//////////////////////

		AircraftManager aircraft_manager (ivybus)

		////////////////////
		// SECTOR MANAGER //
		////////////////////

		SectorManager sector_manager (f, ivybus)
		
		/////////////////////////
		// FLIGHT PLAN MANAGER //
		/////////////////////////

		FlightPlanManager flight_plan_manager (ivybus)
	}

	////////////////////////
	// FIXED LAYER ON TOP //
	////////////////////////

	Dialog dialog (f, ivybus, pan_and_zoom_layer.flight_plan_manager)

	// DEBUG //

	//"FROM MAIN, IVYBUS UPDATE AC " + ivybus.in.update_ac[1] => log.input

	//"FROM MAIN, POINT FOR AREA ID : " + ivybus.in.point_area_init[1] => log.input
}

run root
