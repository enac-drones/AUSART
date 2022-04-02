use core
use gui
use base
use display


import PanAndZoom
import AircraftManager
import SectorManager
import Dialog


_native_code_
%{
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <iostream>

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
%}



_main_
Component root {

	TextPrinter log

	// FRAME //

	Frame f ("AUSART", 100, 100, 2000, 2000)
	Exit ex (0, 1)
	f.close -> ex
	mouseTracking = 1

	// BACKGROUND //

	FillColor _ (60, 60, 60)
	Rectangle bg (0, 0, 0, 0)

	f.width =:> bg.width
	f.height =:> bg.height

	// IVY ACCESS //

	IvyAccess ivybus ("127.255.255.255:2010", "AUSART_FRONT_END", "FRONT_END_READY") {
		String area_init ("ausart_back_end AREA_INIT (\\S*)")
		// ausart_back_end AREA_INIT area_id 
		String point_area_init ("ausart_back_end POINT_AREA_INIT (\\S*) (\\S*) (\\S*)")
		// ausart_back_end POINT_AREA_INIT area_id point_lat point_lon
		String new_ac ("ausart_back_end NEW_AC (\\S*)")
		// ausart_back_end NEW_AC ac_id
		String update_ac ("ausart_back_end UPDATE_AC (\\S*) (\\S*) (\\S*) (\\S*)")
		// ausart_back_end UPDATE_AC ac_id lat lon current_sector
		String delete_ac ("ausart_back_end DELETE_AC (\\S*)")
		// ausart_back_end DELETE_AC ac_id
	}

	// STUFF ABOVE PAN AND ZOOM

	Dialog dialog (20, 20)

	// PAN AND ZOOM //

	FillColor _ (255, 255, 255)
	Text zoom_val (50, 50, "no zoom val")
	Text pan_val (50, 70, "no pan val")
	Text mouse_val (50, 90, "no mouse val")

	PanAndZoom pz (f.move, f.press, f.release, f.wheel.dy, 2444.579709, -0.940657, 43.841653)

	Scaling zoom_tr (1, 1, 0, 0)
	Translation pan_tr (0, 0)

	// test circle for mouse tracking calibration //
/*	FillColor _ (0, 0, 200)
	Circle c (-1.4502, 43.70, 0.001) // supposed to repr and object at 1.4502 43.70 */

	pz.zoom =:> zoom_tr.sx, zoom_tr.sy
	pz.{xpan, ypan} =:> pan_tr.{tx, ty}

	Double mouse_x (0)
	Double mouse_y (0)
	f.move.x / pz.zoom - pz.xpan => mouse_x
	-(f.move.y / pz.zoom - pz.ypan) => mouse_y

	"ZOOM = " + pz.zoom =:> zoom_val.text
	"PAN : X = " + pz.xpan + " / Y = " + pz.ypan =:> pan_val.text
	"MOUSE : X = " + mouse_x + " / Y = " + mouse_y =:> mouse_val.text

	// AIRCRAFT MANAGER //

	AircraftManager aircraft_manager (ivybus)

	// SECTOR MANAGER //

	SectorManager sector_manager (f, ivybus, dialog)

	// DEBUG //

	//"FROM MAIN, IVYBUS UPDATE AC " + ivybus.in.update_ac[1] => log.input

	//"FROM MAIN, POINT FOR AREA ID : " + ivybus.in.point_area_init[1] => log.input
}

run root
