include <MCAD/bearing.scad>
include <MCAD/units.scad>
include <MCAD/stepper.scad>
include <MCAD/materials.scad>
include <MCAD/screw.scad>
include <MCAD/shapes.scad>
include <MCAD/math.scad>

mode = "assembled";
//mode = "parts";
//mode = "cut";

//show_body = true;

// What thickness of material are we building these machine from?
plate_thickness = 0.5 * inch;
plate_material = Birch;

// What are the physical extents of this machine
// (excluding steppers and electronics)
x_size = 10 * inch;


// What are the dimensions of the bed?
x_bed_width = 4 * inch;
x_bed_height = 4 * inch;

// What are the dimensions of the gantry?
x_gantry_length = 3 * inch;

// Where is the gantry?
x_seek = 3.5 * inch;


// Axis parameters.
// How far is the center of our leadscrew and rods from the top of the base plate?
y_axis_offset = 7/8 * inch + plate_thickness;
// How far apart are it's bearings?
y_bearing_separation = ( x_size - 2 * plate_thickness ) / 3;
// How far is our x axis from the back plate?
x_axis_offset = 2.5 * inch;
// How far is our bottom x rod from the bottom of the machine?
x_axis_height = 4.5 * inch;
// How far is our top x rod from the bottom x rod?
x_bearing_separation = 3 * inch;


// How far is our stepper and leadscrew from the bottom x rod?
x_stepper_separation = 1 * inch;


// What size of stepper are we using?
stepper_size = Nema23;
stepper_cutout_diameter = 1 * inch;

// How big are our mechanicals?
rod_diameter = 3/8 * inch;
leadscrew_diameter = 5/16 * inch;

// How much clearance do we want in our bearing blocks?
bearing_clearance = 1/8 * inch;
// How far are they set in from the edges of the platform or gantry?
bearing_inset = 1/4 * inch;

// How big is our bearing block?
y_bearing = 1/2 * inch;
x_bearing = 1.5 * inch;
z_bearing = max( rod_diameter, leadscrew_diameter ) + 2 * bearing_clearance;


// Calculated values.

cutout_thickness = 2 * plate_thickness;
cutout_offset = -1/2 * plate_thickness;

// Radii.
stepper_cutout_radius = 1/2 * stepper_cutout_diameter;
rod_radius = 1/2 * rod_diameter;
leadscrew_radius = 1/2 * leadscrew_diameter;

// Patterns

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


module pattern_cross_nut( cross_diameter = 0.5 * inch, screw_diameter = 0.25 * inch, screw_length = 1.5 * inch ) {

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

module pattern_plate_mount() {
	translate( [0,0,cutout_offset ] ) {
		translate( [ 0.5 * inch, 0.5 * inch, 0] ) {
				pattern_cross_nut();	
		}

		translate( [ x_bed_width - 0.5 * inch, 0.5 * inch, 0] ) {
				pattern_cross_nut();	
		}
	}
}


// Plates.

module plate_base() {

	color(
		plate_material
	)
	difference() {
		cube([ x_bed_width, x_size, plate_thickness ] );

		union() {
			translate( [0, x_size, plate_thickness] ) rotate( [90,0,0] )
				pattern_plate_mount();

			translate( [0, 0.5 * inch, plate_thickness] ) rotate( [90,0,0] )
				pattern_plate_mount();

			translate( [0, 3 * inch, plate_thickness] ) rotate( [90,0,0] )
				pattern_plate_mount();

		}
	}
}

module plate_stepper() {

	color(
		plate_material
	)
	difference() {
		plate_vertical();

		translate( [0,0,cutout_offset ] ) {
			translate( [1/2 * x_bed_width, 1/2 * x_bed_height, 0] ) {
					pattern_stepper_mount();	
			}
		}		
	}
}

module plate_bearing() {

   //  translate([2*inch,0,0] )rotate([0,-90,0])projection( cut=true )rotate( [0,90,0] )translate([-2 * inch,0,0 ])
	color(
		plate_material
	)
	difference() {
		plate_vertical();

		union() {
			translate( [1/2 * x_bed_width, 1/2 * x_bed_height, 0] ) {
				translate( [0, 0, cutout_offset] ) {
					cylinder( 
						h = cutout_thickness,
						r = 0.5 * 6/8 * inch
					);
				}

				translate( [0, 0, 5/16 * inch  ] ) {
					cylinder( 
						h = plate_thickness,
						r = 0.5 * 7/8 * inch
					);
				}

				translate( [0, 0, 3/16 * inch - plate_thickness ] ) {
					cylinder( 
						h = plate_thickness,
						r = 0.5 * 7/8 * inch
					);
				}
			}


			translate( [ 1 * inch , 1/2 * x_bed_height, cutout_offset] ) {
				cylinder(
					h = cutout_thickness,
					r = rod_radius
				);
			}
			translate( [ x_bed_width - 1 * inch , 1/2 * x_bed_height, cutout_offset] ) {
				cylinder(
					h = cutout_thickness,
					r = rod_radius
				);
			}

			pattern_plate_mount();
		}
	}
}

module plate_vertical() {

	color(
		plate_material
	)
	difference() {
		cube( [x_bed_width, x_bed_height, plate_thickness] );

		pattern_plate_mount();
	}
}

// Mechanicals

module washer( id = 0.5 * inch, od = 0.5 * inch, thickness = 1/16 * inch ) {
	color(
		Steel 
	)
	difference() {
		cylinder( 
			h = thickness,
			r = od / 2
		);
		translate( [ 0, 0, -1/2 * thickness ] ) {
			cylinder( 
				h = thickness * 2,
				r = id / 2
			);
		}
	}
}

module bolt( size, length ) {
	color(
		Steel 
	)
	union() {
		cylinder(
			h = length * inch,
			r = 0.1640 / 2 * inch
		);
		cylinder(
			h = 0.096 * inch,
			r = 0.322 / 2 * inch
		);
	}
}

module nut() {
	color(
		Steel 
	)
	union() {
		hexagon( 0.4 * inch, 0.20  * inch );
	}
}

module leadscrew() {
	color(
		Steel 
	)
	union() {
		cylinder(
			h = 8 * inch,
			r = leadscrew_radius
		);
	}
}

// Display the parts we've built above.


module assembled() {
	plate_base();
	translate( [0,plate_thickness,plate_thickness] ) {
		rotate( [90,0,0] ) {
			plate_stepper();
			translate( [1/2 * x_bed_width, 1/2 * x_bed_height, plate_thickness] ) {		
				motor(Nema23);
			}
		}
	}

	translate( [0,x_size, plate_thickness] ) {
		rotate( [90,0,0] ) {
			plate_bearing();
		}
	}

	translate( [0,3 * inch,plate_thickness] ) {
		rotate( [90,0,0] ) {

			rotate(a = 180, [0,1, 0] )
				plate_bearing();

			translate( [1/2 * x_bed_width, 1/2 * x_bed_height, 0] ) {		
				translate( [ 0, 0, 7 * mm ] )
					bearing( model=627 );

				translate( [ 0, 0, -3.1 * mm ] )
					bearing( model=627 );

				translate( [ 0, 0, -6 * inch] )
					leadscrew();

				translate( [ 0, 0, -6 * mm ] )
					nut();

				translate( [ 0, 0, 17 * mm ] )
					nut();

			}
		}
	}
}

module parts() {
	translate( [ -4.25 * inch, -6 * inch, 0 ] ) {

		translate( [4.25 * inch, 8.5 * inch, 0 ] )
			plate_stepper();
	
		translate( [4.25 * inch, 4.25 * inch, 0 ] )
			plate_bearing();
	
		translate( [4.25 * inch, 0 ] )
			plate_bearing();
	
		plate_base();
	}
}

module cut() {
	projection() {
		parts();
	}
}


if (mode == "parts")
	parts();

if (mode == "exploded")
	exploded();

if (mode == "assembled")
	translate( [ -2 * inch, -2.75 * inch, -2.5 * inch ] )
		assembled();

if (mode == "cut" )
	cut();
