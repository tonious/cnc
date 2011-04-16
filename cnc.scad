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

seek_x = 11.5/2 * inch;
seek_y = 8/2 * inch;
seek_z = 2 * inch;

// What size of stepper are we using?

stepper_size = Nema17;
stepper_cutout_diameter = 1 * inch;

// How big are our mechanicals?

rod_diameter = 3/8 * inch;
leadscrew_diameter = 5/16 * inch;
leadscrew_cutout_diameter = 1/2 * inch;

epsilon = 0.1 * mm;

// Calculated Values ============================================================= 

cutout_thickness = 2 * plate_thickness;
cutout_offset = -1/2 * plate_thickness;

// Bed ---------------------------------------------------------------------------

bed_x = envelope_x + 1 * inch;
bed_y = envelope_y;

// Bed bearing block.
bed_bearing_center_to_rod = bed_x * 1 / 4;
bed_bearing_x = bed_bearing_center_to_rod * 2 + 1 * inch;
bed_bearing_y = 1 * inch;
bed_bearing_z = 1/2 * inch;

// How far apart are the bearing blocks?
bed_bearing_separation = bed_y / 2;

// Distance from top of bottom plate to bottom of y axis bearing block.
bed_bearing_height = 1 * inch;


// Gantry ------------------------------------------------------------------------

gantry_x = 6 * inch;
gantry_y = 2 * inch;
gantry_z = 2 * envelope_z + 2 * plate_thickness;

gantry_bearing_center_to_rod = gantry_x * 1/4;
gantry_bearing_x = gantry_bearing_center_to_rod * 2 + 1 * inch;
gantry_bearing_y = 1 * inch;
gantry_bearing_z = 1/2 * inch;

// How far apart are the bearing blocks?
gantry_bearing_separation = 4 * inch;

// Distance from the front of the back plate to the back of the gantry.
gantry_depth = 4 * inch;

// Distance from the top of the base plate to the bottom of the gantry.
gantry_height = 4 * inch;

// Distance from the front of the back gantry plate to the back of the z
// axis bearing black.
gantry_bearing_depth = 3/4 * inch;


// Extents -----------------------------------------------------------------------

// How physically big is the machine?

body_x = bed_x + gantry_x;
body_y = bed_y * 2 + 2 * plate_thickness;
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
					r = rod_radius
				);
			}
			translate( [bed_bearing_x / 2 - bed_bearing_center_to_rod, 0, 0] ) {
				cylinder(
					h = cutout_thickness,
					r = rod_radius
				);
			}
		}
	}
}

module pattern_gantry_bearings() {
	union() {
		translate( [0, 0, cutout_offset] ) {
			translate( [gantry_bearing_x / 2 + gantry_bearing_center_to_rod, 0, 0] ) {
				cylinder(
					h = cutout_thickness,
					r = rod_radius
				);
			}
			translate( [gantry_bearing_x / 2 - gantry_bearing_center_to_rod, 0, 0] ) {
				cylinder(
					h = cutout_thickness,
					r = rod_radius
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

// Gantry

module gantry_back() {
	color(
		plate_material
	)
	cube( [gantry_x, gantry_z - 2 * plate_thickness, plate_thickness] );
}

module gantry_bottom() {
	color(
		plate_material
	)
	difference() {
		cube( [gantry_x, gantry_y, plate_thickness] );
		union() {
			translate( [gantry_x / 2 - gantry_bearing_x/2, gantry_y - gantry_bearing_depth - plate_thickness, 0 ] )
			pattern_gantry_bearings();
		}
	}
}

module gantry_top() {
	color(
		plate_material
	)
	cube( [gantry_x, gantry_y, plate_thickness] );
}


module gantry_either_side() {
	color(
		plate_material
	)
	cube( [gantry_y-plate_thickness, gantry_z - 2 * plate_thickness, plate_thickness] );
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


// Mechanical Parts --------------------------------------------------------------

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

module mechanical_y_axis_assembled() {
	translate( [ body_x/2, 0, bed_bearing_height + bed_bearing_y / 2 + plate_thickness] ) {
		leadscrew_y();

		translate( [bed_bearing_center_to_rod,0,0] )
			bearing_y();

		translate( [-bed_bearing_center_to_rod,0,0] )
			bearing_y();
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

module gantry_assembled() {
	translate( [0,plate_thickness,plate_thickness] )
		rotate( [90,0,0] )
			gantry_back();

	translate( [0,-gantry_y + plate_thickness, 0 ] )
		gantry_bottom();

	translate( [0,-gantry_y + plate_thickness, gantry_z - plate_thickness ] )
		gantry_bottom();

	translate( [0,-gantry_y + plate_thickness, plate_thickness ] )
		rotate( [90,0,90] )
			gantry_either_side();

	translate( [gantry_x - plate_thickness,-gantry_y + plate_thickness, plate_thickness ] )
		rotate( [90,0,90] )
			gantry_either_side();
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
		%body_assembled();

		translate( [plate_thickness + seek_x, body_x - plate_thickness -gantry_depth, gantry_height + plate_thickness ] )
		gantry_assembled();
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
