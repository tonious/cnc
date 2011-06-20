include <MCAD/units.scad>
include <MCAD/stepper.scad>
include <MCAD/materials.scad>
include <MCAD/screw.scad>
include <MCAD/nuts_and_bolts.scad>
include <MCAD/bearing.scad>


mode = "assembled";
//mode = "assembled_gantry";
//mode = "parts";

//show_body = true;

// Parameters ====================================================================

// What material are we building this machine from?

plate_thickness = 0.5 * inch;
plate_material = Birch;

// What size of envelope do we have?

envelope_x = 12 * inch;
envelope_y = 8 * inch;
envelope_z = 2 * inch;

// Where is the tool head?
$t = 0.5;
seek_x = envelope_x * $t;
seek_y = envelope_y * $t;
seek_z = envelope_z * $t;

// How wide is our carriage?
carriage_x = 4 * inch;

// What size of stepper are we using?

stepper_size = Nema17;
stepper_cutout_diameter = 1 * inch;

// How big are our mechanicals?

rod_diameter = 3/8 * inch;
leadscrew_diameter = 5/16 * inch;
leadscrew_cutout_diameter = 1/2 * inch;

tool_length = 1.5*inch;


// Fudge factor to keep OpenSCAD's renderer happy.
epsilon = 0.1 * mm; 

// Calculated Values ============================================================= 

cutout_thickness = 2 * plate_thickness;
cutout_offset = -1/2 * plate_thickness;

// Bed (Y Axis) ------------------------------------------------------------------

bed_clearance = 0.5 * inch;
bed_x = envelope_x + carriage_x - 2 * bed_clearance;
bed_y = envelope_y;

echo( str( "Bed size: ", bed_x/inch, " x ", bed_y/inch ) );

// Y bearing blocks.
bed_bearing_center_to_rod = bed_x * 1 / 4;
bed_bearing_x = bed_bearing_center_to_rod * 2 + 1 * inch;
bed_bearing_y = 1 * inch;
bed_bearing_z = 1/2 * inch;


// How far apart are the bearing blocks?
bed_bearing_separation = bed_y / 2;

// Distance from top of bottom plate to bottom of y axis bearing block.
bed_bearing_height = 1 * inch;

// Gantry (X Axis) ---------------------------------------------------------------

// Transfer plate dimensions.
transfer_plate_x = carriage_x;
transfer_plate_z = 4 * inch;

// X bearing blocks.
x_bearing_x = transfer_plate_z;
x_bearing_y = 1 * inch;
x_bearing_z = 1/2 * inch;
x_bearing_center_to_rod = x_bearing_x / 2 - x_bearing_y / 2;

// How far apart are the bearing blocks?
x_bearing_separation = 4 * inch;

// Distance from the front of the back plate to the center of the x bearing.
x_bearing_depth = 6 * inch;

// Distance from the top of the base plate to the center of the x bearing.
x_bearing_height = bed_bearing_height + bed_bearing_y + 2 * plate_thickness + envelope_z + tool_length ;// 7 * inch;

x_clearance = 1/2 * inch;

// Spindle (Z Axis) --------------------------------------------------------------

z_bearing_x = carriage_x;
z_bearing_y = 1 * inch;
z_bearing_z = 1/2 * inch;
z_bearing_center_to_rod = z_bearing_x / 2 - z_bearing_y / 2;

z_clearance = 1/4 * inch;

z_slide_x = carriage_x;
z_slide_y_top = 3 * plate_thickness + 2 * z_bearing_y + 2 * z_clearance;
z_slide_y_bottom = z_slide_y_top;
z_slide_z = envelope_z + transfer_plate_z + 2 * plate_thickness + 2 * z_clearance;
z_slide_front_edge_to_bearing_center = 1.5 * z_bearing_y + 2 * plate_thickness + z_clearance;


// Extents -----------------------------------------------------------------------

// How physically big is the machine?

body_x = envelope_x + carriage_x + 2 * plate_thickness + 2 * x_clearance;
body_y = envelope_y * 2 + 2 * plate_thickness + 2 * bed_clearance;
body_z = 12 * inch;

body_window_edge = 1.5 * inch;

echo( str( "Base size: ", body_x/inch, " x ", body_y/inch ) );

// How big is the cutout around the front of the machine?

body_lip_height = 3.25 * inch;
body_lip_depth = body_y - x_bearing_depth - 2 * inch;


// Radii -------------------------------------------------------------------------

stepper_cutout_radius = 1/2 * stepper_cutout_diameter;
rod_radius = 1/2 * rod_diameter;
leadscrew_radius = 1/2 * leadscrew_diameter;
leadscrew_cutout_radius = 1/2 * leadscrew_cutout_diameter;

// Patterns ======================================================================


module pattern_stepper_mounting_holes( stepper_size ) {
	mounting_spacing = lookup(NemaDistanceBetweenMountingHoles, stepper_size);
	mounting_diameter = lookup(NemaMountingHoleDiameter, stepper_size);

	union() {
		translate([	
			1/2 * mounting_spacing,
			1/2 * mounting_spacing,
			0
		])
			cylinder( 
				h = cutout_thickness,
				r = 1/2 * mounting_diameter
			);

		translate([	
			1/2 * mounting_spacing,
			-1/2 * mounting_spacing,
			0
		])
			cylinder( 
				h = cutout_thickness,
				r = 1/2 * mounting_diameter
			);

		translate([	
			-1/2 * mounting_spacing,
			-1/2 * mounting_spacing,
			0
		])
			cylinder( 
				h = cutout_thickness,
				r = 1/2 * mounting_diameter
			);

		translate([	
			-1/2 * mounting_spacing,
			1/2 * mounting_spacing,
			0
		])
			cylinder( 
				h = cutout_thickness,
				r = 1/2 * mounting_diameter
			);
	}
}

module pattern_stepper_mount() {

	union() {
		cylinder( 
			h = cutout_thickness,
			r = stepper_cutout_radius
		);

		pattern_stepper_mounting_holes( Nema23 );
		pattern_stepper_mounting_holes( Nema17 );
	}
}


module pattern_cross_nut(
		cross_diameter = 0.5 * inch,
		screw_diameter = 0.25 * inch,
		screw_length = 1.5 * inch
	) {

	union() {
		cylinder( 
			h = cutout_thickness,
			r = cross_diameter / 2
		);

		translate([0,0,cutout_thickness / 2] )rotate( [90,0,0] )
		cylinder( 
			h = screw_length,
			r = screw_diameter / 2
		);
	}
}

module pattern_bearing() {
	union() {
		translate( [0,0, -3/4 * cutout_thickness] )
			cylinder( 
				h = cutout_thickness,
				r = 7/8 * inch /2
			);
		translate( [0,0, cutout_offset] )
			cylinder( 
				h = cutout_thickness,
				r = 3/4 * inch /2
			);
	}
}

module pattern_bed_bearings() {
	union() {
		translate( [0, 0, cutout_offset] ) {
			translate( [bed_bearing_x / 2 + bed_bearing_center_to_rod, 0, 0] ) {
				cylinder(
					h = cutout_thickness,
					r = rod_radius + epsilon
				);
			}
			translate( [bed_bearing_x / 2 - bed_bearing_center_to_rod, 0, 0] ) {
				cylinder(
					h = cutout_thickness,
					r = rod_radius + epsilon
				);
			}
		}
	}
}

module pattern_x_bearings() {
	union() {
		translate( [0, 0, cutout_offset] ) {
			translate( [x_bearing_x / 2 + x_bearing_center_to_rod, 0, 0] ) {
				cylinder(
					h = cutout_thickness,
					r = rod_radius + epsilon
				);
			}
			translate( [x_bearing_x / 2 - x_bearing_center_to_rod, 0, 0] ) {
				cylinder(
					h = cutout_thickness,
					r = rod_radius + epsilon
				);
			}
		}
	}
}

module pattern_z_bearings() {
	union() {
		translate( [0, 0, cutout_offset] ) {
			translate( [z_bearing_x / 2 + z_bearing_center_to_rod, 0, 0] ) {
				cylinder(
					h = cutout_thickness,
					r = rod_radius + epsilon
				);
			}
			translate( [z_bearing_x / 2 - z_bearing_center_to_rod, 0, 0] ) {
				cylinder(
					h = cutout_thickness,
					r = rod_radius + epsilon
				);
			}
		}
	}
}


// Part ==========================================================================

// MDF Parts ---------------------------------------------------------------------

module stepper_mount() {
	color(
		plate_material
	)
	difference() {
		cube( [bed_x, bed_y, plate_thickness] );

		pattern_stepper_mount();
	}
}

module bed_bottom() {
	color(
		plate_material
	)
	cube( [bed_x, bed_y, plate_thickness] );
}

module bed_top() {
	bed_bottom();
}

module transfer_plate() {
	color(
		plate_material
	)
	cube( [transfer_plate_x, transfer_plate_z, plate_thickness] );
}

module slide_back() {
	color(
		plate_material
	)
	cube( [z_slide_x, z_slide_z - 2 * plate_thickness, plate_thickness] );
}

module slide_top() {

 	color(
		plate_material
	)
	difference() {
		cube( [z_slide_x, z_slide_y_top, plate_thickness] );
		union() {
			translate( [0, z_slide_front_edge_to_bearing_center, 0] ) {
				pattern_z_bearings();
				translate( [z_slide_x/2,0,0] )
					pattern_bearing();
			}
		}
	}

}

module slide_bottom() {
	color(
		plate_material
	)
	difference() {
		cube( [z_slide_x, z_slide_y_bottom, plate_thickness] );
			translate( [0, z_slide_front_edge_to_bearing_center, 0] ) {
				pattern_z_bearings();
			}
	}
}

// Body

module body_bottom() {
	color(
		plate_material
	)
	cube( [body_x, body_y, plate_thickness] );
}

module body_back() {

/*
	translate( [ 9 * inch,0,0] )
		rotate( [0,90,0] )
			projection( cut=true )
	rotate( [0,-90,0] )
		translate( [ -9 * inch,0,0] )
 */

	color(
		plate_material
	)
	difference() {
		cube( [body_x, body_z - plate_thickness, plate_thickness] );

		union() {
			translate( [
				body_x/2 - bed_bearing_x/2,
				bed_bearing_height + bed_bearing_y / 2
			] )
				pattern_bed_bearings();

			translate( [
				body_x/2,
				bed_bearing_height + plate_thickness,
				plate_thickness
			] )
				rotate( [0,180,0] )
					pattern_bearing();

			translate( [ body_window_edge, body_lip_height - plate_thickness, cutout_offset ] )
				cube( [
					body_x - 2 * body_window_edge,
					x_bearing_height - body_lip_height + plate_thickness,
					cutout_thickness
					] );
		}
	}
}

module body_front() {
	color(
		plate_material
	)
	difference() {
		cube( [body_x, body_z - plate_thickness, plate_thickness] );
		union() {
			translate( [
				body_x/2 - bed_bearing_x/2,
				bed_bearing_height + bed_bearing_y / 2
			] )
				pattern_bed_bearings();

			translate( [ body_window_edge, body_lip_height - plate_thickness, cutout_offset ] )
				cube( [
					body_x - 2 * body_window_edge,
					body_z - body_lip_height - body_window_edge,
					cutout_thickness
					] );
		}
	}
}

module body_either_side() {
	color(
		plate_material
	)
	difference() {
/*
		linear_extrude(	
			height = plate_thickness,
			convexity = 10
		)
		polygon(
			points=[
				[0,0],
				[0, body_lip_height - plate_thickness],
				[body_lip_depth - plate_thickness,body_lip_height - plate_thickness],
				[body_lip_depth - plate_thickness, body_z - plate_thickness],
				[body_y - 2 * plate_thickness, body_z - plate_thickness],
				[body_y - 2 * plate_thickness, 0]
			],
			paths=[[0,1,2,3,4,5]],
			convexity = 10
		);
 */
		cube( [body_y - 2 * plate_thickness, body_z - plate_thickness, plate_thickness ] );

 		union() {
			translate( [body_y - plate_thickness - x_bearing_depth, x_bearing_height, 0] )
				rotate( [0,0,90] )
					pattern_x_bearings();

			translate( [ body_window_edge, body_lip_height - plate_thickness,cutout_offset] )
				cube( [
					body_y - body_lip_depth - body_window_edge,
					body_z - body_lip_height - body_window_edge,
					cutout_thickness ] );

		}
	}
}

module body_left_side() {

	color(
		plate_material
	)
	difference() {
		body_either_side();

		translate( [
			body_y - plate_thickness - x_bearing_depth,
			x_bearing_height + x_bearing_x / 2,
			plate_thickness
		] )
			rotate( [180,0,0] )
				pattern_bearing();
	}
}

module body_right_side() {
	body_either_side();
}

// Plastic Parts -----------------------------------------------------------------

module bed_bearing( leadscrew_nut = false ) {
	color(
		[1,1,1]
	)
	difference() {
		cube( [bed_bearing_x, bed_bearing_y, bed_bearing_z] );
		union() {
			translate( [0, bed_bearing_y / 2, cutout_offset] ) {
				translate( [bed_bearing_x / 2, 0, 0] )
					if( leadscrew_nut == true ) {
						cylinder(
							h = cutout_thickness,
							r = leadscrew_radius
						);
					} else {
						cylinder(
							h = cutout_thickness,
							r = leadscrew_cutout_radius
						);
					}
			}
			translate( [0, bed_bearing_y / 2, 0 ] ) {
				pattern_bed_bearings();
			}	
		}
	}
}

module x_bearing( leadscrew_nut = false ) {
	color(
		[1,1,1]
	)
	difference() {
		cube( [x_bearing_x, x_bearing_y, x_bearing_z] );
		union() {
			translate( [0, x_bearing_y / 2, cutout_offset] ) {
				translate( [x_bearing_x / 2, 0, 0] )
					if( leadscrew_nut == true ) {
						cylinder(
							h = cutout_thickness,
							r = leadscrew_radius
						);
					} else {
						cylinder(
							h = cutout_thickness,
							r = leadscrew_cutout_radius
						);
					}
			}
			translate( [0, x_bearing_y / 2, 0 ] ) {
				pattern_x_bearings();
			}	
		}
	}
}

module z_bearing( leadscrew_nut = false ) {
	color(
		[1,1,1]
	)
	difference() {
		cube( [z_bearing_x, z_bearing_y, z_bearing_z] );
		union() {
			translate( [0, z_bearing_y / 2, cutout_offset] ) {
				translate( [z_bearing_x / 2, 0, 0] )
					if( leadscrew_nut == true ) {
						cylinder(
							h = cutout_thickness,
							r = leadscrew_radius
						);
					} else {
						cylinder(
							h = cutout_thickness,
							r = leadscrew_cutout_radius
						);
					}
			}
			translate( [0, z_bearing_y / 2, 0 ] ) {
				pattern_z_bearings();
			}	
		}
	}
}


// Mechanical Parts --------------------------------------------------------------

module bearing_x() {
	translate( [ -epsilon, 0, 0 ] )
		rotate( [0,90,0] )
			color( 
				Steel
			)
			cylinder(
				h = body_x + 2 * epsilon,
				r = rod_radius - epsilon
			);
}

module bearing_y() {
	translate( [ 0, -epsilon, 0 ] )
		rotate( [0,90,90] )
			color( 
				Steel
			)
			cylinder(
				h = body_y + 2 * epsilon,
				r = rod_radius - epsilon
			);
}

module bearing_z() {
	translate( [ 0, -epsilon, 0 ] )
		rotate( [0,0,90] )
			color( 
				Steel
			)
			cylinder(
				h = z_slide_z + 2 * epsilon,
				r = rod_radius - epsilon
			);
}

module leadscrew_x() {
	translate( [ -1/2 * inch -epsilon, 0, 0 ] )
		rotate( [0,90,0] )
			color( 
				Steel
			)
			cylinder(
				h = envelope_x + transfer_plate_x/2,
				r = leadscrew_radius - epsilon
			);
}

module leadscrew_y() {
	translate( [ 0, body_y - envelope_y -epsilon, 0 ] )
		rotate( [0,90,90] )
			color( 
				Steel
			)
			cylinder(
				h = envelope_y + 2 * epsilon,
				r = leadscrew_radius - epsilon
			);
}

module leadscrew_z() {
	translate( [ 0, 0, - envelope_z - transfer_plate_z -epsilon ] )
		rotate( [0,0,0] )
			color( 
				Steel
			)
			cylinder(
				h = 1/2 * inch + envelope_z + transfer_plate_z + 2 * epsilon,
				r = leadscrew_radius - epsilon
			);
}

// Assemblies ====================================================================

module mechanical_x_axis_assembled() {

	translate( [0, plate_thickness, x_bearing_x / 2 ]) {

		translate( [0,0, x_bearing_center_to_rod] )
			bearing_x();

		translate( [0,0, - x_bearing_center_to_rod] )
			bearing_x();

		translate([plate_thickness/2 + 1*mm,0,0])
			rotate([0,90,0])
				bearing( model=627 );

		translate( [-1.5 * inch,0,0] )
			rotate([0,-90,0])
				motor(Nema23);

		leadscrew_x();

	}
}

module mechanical_y_axis_assembled() {
	translate( [
		body_x/2,
		0,
		bed_bearing_height + bed_bearing_y / 2 + plate_thickness
	] ) {

		translate([0,1/2 * inch,0])
			leadscrew_y();

		translate( [bed_bearing_center_to_rod,0,0] )
			bearing_y();

		translate( [-bed_bearing_center_to_rod,0,0] )
			bearing_y();

		translate([0,body_y-1*mm - plate_thickness/2,0])
			rotate([90,0,0])
				bearing( model=627 );

		translate( [0,body_y + 1.5 * inch,0] )
			rotate([0,-90,-90])
				motor(Nema23);
	}

}

module mechanical_z_axis_assembled() {
	translate( [ z_bearing_y / 2,z_slide_front_edge_to_bearing_center,epsilon ] ) {
		bearing_z();

		translate( [ z_bearing_center_to_rod * 2, 0, epsilon ] ) {
			bearing_z();
		}

		translate( [z_bearing_center_to_rod,0,z_slide_z+1.5*inch] )
			motor(Nema23);

		translate( [z_bearing_center_to_rod,0,z_slide_z-plate_thickness - 1 * mm] )
			bearing( model=627 );

		translate( [z_bearing_center_to_rod,0,z_slide_z] )
			leadscrew_z();



	}

}

module transfer_plate_assembled() {
	rotate( [90,0,0] )
		transfer_plate();

	translate( [0,-x_bearing_y -plate_thickness ,x_bearing_x] ) {

		rotate( [0,90,0] )
			x_bearing( leadscrew_nut = true);

		translate( [transfer_plate_x - x_bearing_z, 0, 0 ] )
			rotate( [0,90,0] )
				x_bearing( leadscrew_nut = false);
	}

	translate( [z_bearing_x,plate_thickness + 1/2 * z_bearing_y,0] )
		rotate([0,0,180] ) {

			z_bearing( leadscrew_nut = false );

			translate( [0,0,transfer_plate_z - plate_thickness ] )
				z_bearing( leadscrew_nut = true );

	}
}

module z_slide_assembled() {

	slide_bottom();

	translate( [ 0, 0, z_slide_z - plate_thickness] )
		slide_top();

	translate( [ 0, plate_thickness, plate_thickness ] )
		rotate( [90,0,0] ) {
			slide_back();
		}

	translate([0,2 * z_bearing_y + 3 * plate_thickness + 2 * z_clearance,plate_thickness] )
		rotate( [90,0,0] ) {
			slide_back();
		}

}

module bed_assembled() {

	translate( [0, 0, bed_bearing_y] )
		bed_bottom();
	translate( [0, 0, bed_bearing_y + plate_thickness] )
		bed_top();

	translate( [bed_x / 2 - bed_bearing_x / 2, 0, 0] ) {

		translate( [
			0,
			( bed_y + bed_bearing_separation + bed_bearing_z )/2,
			0
		] )
			rotate( [90,0,0] )
				bed_bearing( leadscrew_nut = true);
	
		translate( [
			0,
			( bed_y - bed_bearing_separation + bed_bearing_z )/2,
			0
		] )
			rotate( [90,0,0] )
				bed_bearing( leadscrew_nut = false);
	}

}


module body_assembled() {
	body_bottom();

	translate( [ 0, body_y, plate_thickness ] )
		rotate( [90,0,0] )
			body_back();

	translate( [ 0, plate_thickness, plate_thickness ] )
		rotate( [90,0,0] )
			body_front();

	translate( [ 0, plate_thickness, plate_thickness ] )
		rotate( [90,0,90] )
			body_left_side();

	translate( [ body_x - plate_thickness, plate_thickness, plate_thickness ] )
		rotate( [90,0,90] )
			body_right_side();
}



// Top Level Geometry ============================================================

module assembled() {
	translate( [-1/2 * body_x, -1/2 * body_y, -1/2 * body_z] ) {

		translate( [
			body_x / 2 - bed_x / 2,
			seek_y + bed_clearance + plate_thickness,
			plate_thickness + bed_bearing_height
		] ) {
			bed_assembled();
		}

		mechanical_y_axis_assembled();

		translate( [
			0,
			body_y - x_bearing_depth - plate_thickness,
			x_bearing_height + plate_thickness
		] ) {

			mechanical_x_axis_assembled();

			translate( [
				plate_thickness + seek_x + x_clearance,
				plate_thickness + 1/2 * z_bearing_y + 1/2 * z_bearing_y,
				0
			] ) {

				transfer_plate_assembled();

				translate( [
					0,
					-z_slide_front_edge_to_bearing_center + plate_thickness,
					-seek_z - plate_thickness - z_clearance
				] ) {

					mechanical_z_axis_assembled();
					z_slide_assembled();
				}
			}
		}

		body_assembled();
	}
}


module parts() {

}

// Choose Our Top Level ----------------------------------------------------------

if (mode == "parts")
	parts();

if (mode == "exploded")
	exploded();

if (mode == "assembled")
	assembled();

