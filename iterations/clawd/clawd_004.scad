// Clawd - Version 004
// Generated from reference image: references/01_clawd.png
// Pixel art character: blocky creature with flat head, side hands, eyes, four legs
//
// Changes from version 003:
// - Taller body (10px vs 8px) for better proportions
// - Eyes are now separate blocks (not indents) for multi-part assembly
// - Shallow recesses in body for eye alignment
// - Hands raised slightly (3.5px vs 3px)

// Parameters
pixel = 4;              // base pixel unit (mm)
depth = pixel * 3;      // 12mm depth

// Main body (flat top)
body_w = 12 * pixel;    // 48mm wide
body_h = 10 * pixel;    // 40mm tall (was 8px/32mm)

// Hands (protrude from left/right sides)
hand_w = 2 * pixel;     // 8mm protrusion
hand_h = 3 * pixel;     // 12mm tall
hand_z = 4 * pixel;     // 16mm from ground (centered with eyes)

// Four legs at bottom
// Layout: leg(2) | gap(1) | leg(2) | center_gap(2) | leg(2) | gap(1) | leg(2)
leg_h = 3 * pixel;      // 12mm tall
outer_leg_w = 2 * pixel;
inner_leg_w = 2 * pixel;
outer_gap = 1 * pixel;
center_gap = 2 * pixel;

// Eyes — separate blocks for assembly
eye_size = 1.5 * pixel; // 6mm square
eye_block_depth = 3;     // 3mm thick eye block (1mm recess + 2mm proud)
eye_recess = 1;          // 1mm shallow recess for alignment
eye_from_side = 3 * pixel;
eye_from_top = 3 * pixel;  // slightly lower due to taller body

// Export mode:
// "assembly"     -> assembled preview
// "print_layout" -> parts laid out separately for printing
// "body"         -> body only
// "left_eye"     -> left eye only
// "right_eye"    -> right eye only
part = "assembly";
print_gap = 6;

$fn = 32;

// Main body (print in body color)
module body() {
    difference() {
        union() {
            // Main body block (flat top)
            cube([body_w, depth, body_h]);

            // Left hand
            translate([-hand_w, 0, hand_z])
                cube([hand_w, depth, hand_h]);

            // Right hand
            translate([body_w, 0, hand_z])
                cube([hand_w, depth, hand_h]);
        }

        // Leg gaps
        // Gap 1: between outer-left and inner-left leg
        translate([outer_leg_w, -0.01, -0.01])
            cube([outer_gap, depth + 0.02, leg_h + 0.01]);

        // Center gap: between inner-left and inner-right leg
        translate([outer_leg_w + outer_gap + inner_leg_w, -0.01, -0.01])
            cube([center_gap, depth + 0.02, leg_h + 0.01]);

        // Gap 3: between inner-right and outer-right leg
        translate([body_w - outer_leg_w - outer_gap, -0.01, -0.01])
            cube([outer_gap, depth + 0.02, leg_h + 0.01]);

        // Left eye recess (shallow pocket for alignment)
        translate([
            eye_from_side - eye_size / 2,
            -0.01,
            body_h - eye_from_top - eye_size / 2
        ])
            cube([eye_size, eye_recess + 0.01, eye_size]);

        // Right eye recess
        translate([
            body_w - eye_from_side - eye_size / 2,
            -0.01,
            body_h - eye_from_top - eye_size / 2
        ])
            cube([eye_size, eye_recess + 0.01, eye_size]);
    }
}

// Single eye block (print in black)
module eye_block() {
    cube([eye_size, eye_block_depth, eye_size]);
}

// Left eye positioned for assembly preview
module left_eye() {
    translate([
        eye_from_side - eye_size / 2,
        -eye_block_depth + eye_recess,
        body_h - eye_from_top - eye_size / 2
    ])
        color("black") eye_block();
}

// Right eye positioned for assembly preview
module right_eye() {
    translate([
        body_w - eye_from_side - eye_size / 2,
        -eye_block_depth + eye_recess,
        body_h - eye_from_top - eye_size / 2
    ])
        color("black") eye_block();
}

module left_eye_part() {
    color("black") eye_block();
}

module right_eye_part() {
    color("black") eye_block();
}

module assembled_preview() {
    body();
    left_eye();
    right_eye();
}

// Parts arranged apart for separate printing/export.
module print_layout() {
    body();

    translate([body_w + print_gap, 0, 0])
        eye_block();

    translate([body_w + print_gap + eye_size + print_gap, 0, 0])
        eye_block();
}

if (part == "assembly") {
    assembled_preview();
} else if (part == "print_layout") {
    print_layout();
} else if (part == "body") {
    body();
} else if (part == "left_eye") {
    left_eye_part();
} else if (part == "right_eye") {
    right_eye_part();
} else {
    assembled_preview();
}
