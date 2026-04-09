// Clawd - Version 006
// Generated from reference image: references/01_clawd.png
// Changes from version 005:
// - Widened the main body silhouette slightly and deepened the center leg cutout.
// - Reduced the wizard hat footprint so it reads as an accessory instead of the main subject.
// - Kept the white frame + colored inlay assembly strategy unchanged.

display_mode = "assembly"; // ["assembly", "layout", "base", "body", "hat", "band", "left_eye", "right_eye"]

pixel = 4;
eps = 0.01;
$fn = 32;

// Assembly depths
base_depth = 6.0;
inlay_depth = 2.6;
detail_depth = 1.4;
base_pocket_depth = 2.9;
detail_pocket_depth = 1.6;

// Print clearances
body_clearance = 0.25;
detail_clearance = 0.15;
outline = 1 * pixel;
layout_gap = 10;

// Body proportions tuned from the 004 feedback:
// taller stance, longer legs, and lighter side protrusions.
body_w = 13 * pixel;
body_h = 11 * pixel;
hand_w = 1 * pixel;
hand_h = 3 * pixel;
hand_z = 5 * pixel;

leg_h = 4 * pixel;
outer_leg_w = 2 * pixel;
inner_leg_w = 2 * pixel;
outer_gap = 1 * pixel;
center_gap = 3 * pixel;

// Eyes remain simple square inserts to stay close to the reference.
eye_size = 1.5 * pixel;
eye_from_side = 3 * pixel;
eye_from_top = 3 * pixel;
eye_left_x = eye_from_side - eye_size / 2;
eye_bottom_z = body_h - eye_from_top - eye_size / 2;

// Render colors
frame_color = [0.97, 0.97, 0.97];
body_color = [0.86, 0.48, 0.35];
hat_color = [0.17, 0.27, 0.66];
band_color = [0.94, 0.76, 0.20];
eye_color = [0.03, 0.03, 0.03];

module extrude_front(depth) {
    translate([0, depth, 0])
        rotate([90, 0, 0])
            linear_extrude(height = depth)
                children();
}

module front_pocket(depth) {
    translate([0, -eps, 0])
        extrude_front(depth + eps)
            children();
}

module top_pocket(total_depth, pocket_depth) {
    translate([0, 0, total_depth - pocket_depth - eps])
        linear_extrude(height = pocket_depth + 2 * eps)
            children();
}

module orange_body_2d() {
    difference() {
        union() {
            square([body_w, body_h]);

            translate([-hand_w, hand_z])
                square([hand_w, hand_h]);

            translate([body_w, hand_z])
                square([hand_w, hand_h]);
        }

        translate([outer_leg_w, 0])
            square([outer_gap, leg_h]);

        translate([outer_leg_w + outer_gap + inner_leg_w, 0])
            square([center_gap, leg_h]);

        translate([body_w - outer_leg_w - outer_gap, 0])
            square([outer_gap, leg_h]);
    }
}

module left_eye_2d() {
    translate([eye_left_x, eye_bottom_z])
        square([eye_size, eye_size]);
}

module right_eye_2d() {
    translate([body_w - eye_left_x - eye_size, eye_bottom_z])
        square([eye_size, eye_size]);
}

module wizard_hat_2d() {
    union() {
        translate([3 * pixel, body_h + 2 * pixel])
            square([7 * pixel, 1 * pixel]);
        translate([2 * pixel, body_h])
            square([9 * pixel, 1 * pixel]);
        translate([3 * pixel, body_h + 1 * pixel])
            square([7 * pixel, 1 * pixel]);
        translate([4 * pixel, body_h + 3 * pixel])
            square([6 * pixel, 1 * pixel]);
        translate([5 * pixel, body_h + 4 * pixel])
            square([5 * pixel, 1 * pixel]);
        translate([6 * pixel, body_h + 5 * pixel])
            square([4 * pixel, 1 * pixel]);
        translate([7 * pixel, body_h + 6 * pixel])
            square([3 * pixel, 1 * pixel]);
        translate([8 * pixel, body_h + 7 * pixel])
            square([2 * pixel, 1 * pixel]);
    }
}

module hat_band_2d() {
    translate([4 * pixel, body_h + 1 * pixel])
        square([4 * pixel, 1 * pixel]);
}

module assembled_outline_2d() {
    union() {
        orange_body_2d();
        wizard_hat_2d();
    }
}

module outer_frame_2d() {
    offset(delta = outline)
        assembled_outline_2d();
}

module base_plate(flat = false) {
    color(frame_color)
        difference() {
            if (flat)
                linear_extrude(height = base_depth)
                    outer_frame_2d();
            else
                extrude_front(base_depth)
                    outer_frame_2d();

            if (flat)
                top_pocket(base_depth, base_pocket_depth)
                    offset(delta = body_clearance)
                        orange_body_2d();
            else
                front_pocket(base_pocket_depth)
                    offset(delta = body_clearance)
                        orange_body_2d();

            if (flat)
                top_pocket(base_depth, base_pocket_depth)
                    offset(delta = body_clearance)
                        wizard_hat_2d();
            else
                front_pocket(base_pocket_depth)
                    offset(delta = body_clearance)
                        wizard_hat_2d();
        }
}

module body_piece(flat = false) {
    color(body_color)
        difference() {
            if (flat)
                linear_extrude(height = inlay_depth)
                    orange_body_2d();
            else
                extrude_front(inlay_depth)
                    orange_body_2d();

            if (flat)
                top_pocket(inlay_depth, detail_pocket_depth)
                    offset(delta = detail_clearance)
                        left_eye_2d();
            else
                front_pocket(detail_pocket_depth)
                    offset(delta = detail_clearance)
                        left_eye_2d();

            if (flat)
                top_pocket(inlay_depth, detail_pocket_depth)
                    offset(delta = detail_clearance)
                        right_eye_2d();
            else
                front_pocket(detail_pocket_depth)
                    offset(delta = detail_clearance)
                        right_eye_2d();
        }
}

module hat_piece(flat = false) {
    color(hat_color)
        difference() {
            if (flat)
                linear_extrude(height = inlay_depth)
                    wizard_hat_2d();
            else
                extrude_front(inlay_depth)
                    wizard_hat_2d();

            if (flat)
                top_pocket(inlay_depth, detail_pocket_depth)
                    offset(delta = detail_clearance)
                        hat_band_2d();
            else
                front_pocket(detail_pocket_depth)
                    offset(delta = detail_clearance)
                        hat_band_2d();
        }
}

module band_piece(flat = false) {
    color(band_color)
        if (flat)
            linear_extrude(height = detail_depth)
                hat_band_2d();
        else
            extrude_front(detail_depth)
                hat_band_2d();
}

module left_eye_piece(flat = false) {
    color(eye_color)
        if (flat)
            linear_extrude(height = detail_depth)
                left_eye_2d();
        else
            extrude_front(detail_depth)
                left_eye_2d();
}

module right_eye_piece(flat = false) {
    color(eye_color)
        if (flat)
            linear_extrude(height = detail_depth)
                right_eye_2d();
        else
            extrude_front(detail_depth)
                right_eye_2d();
}

module assembly_view() {
    base_plate();
    body_piece();
    hat_piece();
    band_piece();
    left_eye_piece();
    right_eye_piece();
}

module print_layout() {
    base_plate(true);

    translate([76, 0, 0])
        body_piece(true);

    translate([138, 0, 0])
        hat_piece(true);

    translate([138, 52, 0])
        band_piece(true);

    translate([200, 0, 0])
        left_eye_piece(true);

    translate([214, 0, 0])
        right_eye_piece(true);
}

if (display_mode == "assembly") {
    assembly_view();
} else if (display_mode == "layout") {
    print_layout();
} else if (display_mode == "base") {
    base_plate(true);
} else if (display_mode == "body") {
    body_piece(true);
} else if (display_mode == "hat") {
    hat_piece(true);
} else if (display_mode == "band") {
    band_piece(true);
} else if (display_mode == "left_eye") {
    left_eye_piece(true);
} else if (display_mode == "right_eye") {
    right_eye_piece(true);
} else {
    assembly_view();
}
