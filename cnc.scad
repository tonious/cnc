include <MCAD/units.scad>
include <MCAD/stepper.scad>
include <MCAD/materials.scad>
include <MCAD/screw.scad>
include <MCAD/nuts_and_bolts.scad>

mode = "assembled";
//mode = "assembled_gantry";
//mode = "parts";

//show_body = true;

// Parameters ====================================================================

// What thickness of material are we building these machine from?

plate_thickness = 0.5 * inch;
plate_material = Birch;

// What size of envelope do we have?

envelope_x = 11.5 * inch;
envelope_y = 8 * inch;
envelope_z = 2 * inch;

// Where is the tool head?

seek_x = 11.5 / 2* inch;
seek_y = 8/2 * inch;
seek_z = 2 * inch;

// How wide is our carriage?
carriage_x = 6 * inch;

// What size of stepper are we using?

stepper_size = Nema17;
stepper_cutout_diameter = 1 * inch;

// How big are our mechanicals?

rod_diameter = 3/8 * inch;
leadscrew_diameter = 5/16 * inch;
leadscrew_cutout_diameter = 1/2 * inch;


// Fudge factor to keep OpenSCAD's renderer happy.
epsilon = 0.05 * mm; 

// Calculated Values ============================================================= 

cutout_thickness = 2 * plate_thickness;
cutout_offset = -1/2 * plate_thickness;

// Bed (Y Axis) ------------------------------------------------------------------

bed_x = envelope_x + 1 * inch;
bed_y = envelope_y;

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

// X bearing blocks.
x_bearing_center_to_rod = 2 * inch;
x_bearing_x = x_bearing_center_to_rod * 2 + 1 * inch;
x_bearing_y = 1 * inch;
x_bearing_z = 1/2 * inch;

transfer_plate_x = carriage_x;
transfer_plate_z = 2 * envelope_z + 2 * plate_thickness;

// How far apart are the bearing blocks?
x_bearing_separation = 4 * inch;

// Distance from the front of the back plate to the center of the x bearing.
x_bearing_depth = 4 * inch;

// Distance from the top of the base plate to the center of the x bearing.
x_bearing_height = 6 * inch;

// Spindle (Z Axis) --------------------------------------------------------------

y_bearing_x = carriage_x;
y_bearing_y = 1 * inch;
y_bearing_z = 1/2 * inch;


// Extents -----------------------------------------------------------------------

// How physically big is the machine?

body_x = envelope_x + carriage_x + 2 * plate_thickness;
body_y = envelope_y * 2 + 2 * plate_thickness;
body_z = 12 * inch;

// How big is the cutout around the front of the machine?

body_lip_height = 4 * inch;
body_lip_depth = 10 * inch;


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

// Part ==========================================================================

// MDF Parts ---------------------------------------------------------------------

// Bed

module bed_bottom() {
	color(
		plate_material
	)
	cube( [bed_x, bed_y, plate_thickness] );
}

module bed_top() {
	bed_bottom();
}

// 

module transfer_plate() {
	color(
		plate_material
	)
	cube( [transfer_plate_x, transfer_plate_z, plate_thickness] );
}


// Body

module body_bottom() {
	color(
		plate_material
	)
	cube( [body_x, body_y, plate_thickness] );
}

module body_back() {
	color(
		plate_material
	)
	difference() {
		cube( [body_x, body_z - plate_thickness, plate_thickness] );
		union() {
			translate( [ body_x/2 - bed_bearing_x/2, bed_bearing_height + bed_bearing_y / 2 ] )
				pattern_bed_bearings();

			translate( [body_x/2, bed_bearing_height + plate_thickness, cutout_offset] )
				pattern_stepper_mount();
		}
	}
}

module body_front() {
	color(
		plate_material
	)
	difference() {
		cube( [body_x, body_lip_height - plate_thickness, plate_thickness] );
		union() {
			translate( [ body_x/2 - bed_bearing_x/2, bed_bearing_height + bed_bearing_y / 2 ] )
				pattern_bed_bearings();
		}
	}
}

module body_either_side() {
	color(
		plate_material
	)
	difference() {
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

		translate( [body_y - plate_thickness - x_bearing_depth, x_bearing_height, 0] )
			rotate( [0,0,90] )
				pattern_x_bearings();
	}
}

module body_left_side() {
	body_either_side();
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


// Mechanical Parts --------------------------------------------------------------

module bearing_x() {
	translate( [-epsilon, 0, 0 ] )
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
	translate( [0, -epsilon, 0 ] )
		rotate( [0,90,90] )
			color( 
				Steel
			)
			cylinder(
				h = body_y + 2 * epsilon,
				r = rod_radius - epsilon
			);
}

module leadscrew_y() {
	translate( [0, body_y - envelope_y -epsilon, 0 ] )
		rotate( [0,90,90] )
			color( 
				Steel
			)
			cylinder(
				h = envelope_y + 2 * epsilon,
				r = leadscrew_radius - epsilon
			);
}

// Assemblies ====================================================================

module mechanical_x_axis_assembled() {

	translate( [0, body_y - x_bearing_depth, x_bearing_height + x_bearing_x  / 2 + plate_thickness ]) {

		translate( [0,0, x_bearing_center_to_rod] )
			bearing_x();

		translate( [0,0, - x_bearing_center_to_rod] )
			bearing_x();
	}
}

module mechanical_y_axis_assembled() {
	translate( [ body_x/2, 0, bed_bearing_height + bed_bearing_y / 2 + plate_thickness] ) {
		leadscrew_y();

		translate( [bed_bearing_center_to_rod,0,0] )
			bearing_y();

		translate( [-bed_bearing_center_to_rod,0,0] )
			bearing_y();
	}

}

module transfer_plate_assembled() {
	rotate( [90,0,0] )
		transfer_plate();

	translate( [0,0,x_bearing_x] ) {
		rotate( [0,90,0] )
			x_bearing( leadscrew_nut = true);

		translate( [transfer_plate_x - x_bearing_z, 0, 0 ] )
			rotate( [0,90,0] )
				x_bearing( leadscrew_nut = false);
	}
}

module bed_assembled() {

	translate( [0, 0, bed_bearing_y] )
		bed_bottom();
	translate( [0, 0, bed_bearing_y + plate_thickness] )
		bed_top();

	translate( [bed_x / 2 - bed_bearing_x / 2, 0, 0] ) {

		translate( [0, bed_y / 2 + bed_bearing_separation / 2 + bed_bearing_z/2, 0 ] )
			rotate( [90,0,0] )
				bed_bearing( leadscrew_nut = true);
	
		translate( [0, bed_y / 2 - bed_bearing_separation / 2 + bed_bearing_z/2, 0 ] )
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
			body_left_side();
}



// Top Level Geometry ============================================================

module assembled() {
	translate( [-1/2 * body_x, -1/2 * body_y, -1/2 * body_z] ) {

		translate( [ body_x / 2 - bed_x / 2 , seek_y + plate_thickness, plate_thickness + bed_bearing_height ] ) {
			bed_assembled();
		}

		mechanical_y_axis_assembled();
		mechanical_x_axis_assembled();
		mechanical_z_axis_assembled();

		translate( [plate_thickness + seek_x, body_y - x_bearing_depth - plate_thickness, x_bearing_height + plate_thickness] ) {
			transfer_plate_assembled();
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
