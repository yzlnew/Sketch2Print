// Skateboard Charm - Version 005
// Reference: references/17_clawd_skateboard.png
// Changes from previous version:
// - Increased overall model depth for a stronger 3D block presence.
// - Removed all darker orange sticker/shadow patches from Clawd.
// - Rebuilt the skateboard stack so deck, trucks, and wheels touch cleanly without vertical overlap.

eps = 0.02;
$fn = 32;

body_d = 30;
deck_d = 38;
truck_d = 44;
wheel_d = 26;
face_d = 0.7;

orange = [0.96, 0.45, 0.29];
black = [0.02, 0.02, 0.02];
maroon = [0.34, 0.07, 0.16];
wheel_yellow = [1.00, 0.68, 0.28];
axle_gray = [0.35, 0.34, 0.34];

module block(x, z, w, h, d, material, y = 0) {
    color(material)
        translate([x + w / 2, y, z + h / 2])
            cube([w + eps, d + eps, h + eps], center = true);
}

module face_block(x, z, w, h, material, host_d = body_d) {
    color(material)
        translate([x + w / 2, -host_d / 2 - face_d / 2 + eps, z + h / 2])
            cube([w, face_d, h], center = true);
}

module clawd_body() {
    // Block figure built from simple cuboids. The front silhouette follows the
    // reference, but no printed/sticker shadow patches are modeled.
    block(-28, 62, 52, 16, body_d, orange);       // top head step
    block(-36, 44, 78, 24, body_d, orange);       // main face/body
    block(-36, 24, 54, 22, body_d, orange);       // lower left body
    block(18, 24, 30, 24, body_d, orange);        // lower right body
    block(24, 56, 26, 18, body_d, orange);        // upper right step
    block(46, 42, 18, 18, body_d, orange);        // right cheek protrusion
    block(-58, 42, 24, 18, body_d, orange);       // left cheek protrusion

    // Blocky legs and dangling lower pixels. Lowest faces sit on the deck top.
    block(-34, 8, 14, 26, body_d, orange);
    block(-24, 0, 12, 16, body_d, orange);
    block(-6, 0, 12, 20, body_d, orange);
    block(28, 0, 12, 24, body_d, orange);
    block(44, 0, 12, 24, body_d, orange);
    block(40, 22, 14, 20, body_d, orange);

    // Raised square eyes on the front face.
    face_block(-8, 52, 9, 9, black);
    face_block(32, 52, 9, 9, black);
}

module deck_block(x, z, w, h) {
    block(x, z, w, h, deck_d, maroon);
}

module truck(cx) {
    // Truck top touches the deck underside at z=-5. Wheels touch the truck
    // underside at z=-10, avoiding stacked intersections.
    block(cx - 5, -10, 10, 5, truck_d, axle_gray);
}

module pixel_wheel(cx) {
    // Pixel wheels are chunky cuboid clusters with no overlap into the deck.
    block(cx - 7, -34, 14, 6, wheel_d, wheel_yellow);
    block(cx - 12, -28, 24, 9, wheel_d, wheel_yellow);
    block(cx - 9, -19, 18, 9, wheel_d, wheel_yellow);
    face_block(cx - 3, -24, 6, 6, maroon, wheel_d);
}

module pixel_skateboard() {
    // Pixel skateboard side profile. Adjacent blocks meet at faces instead of
    // occupying the same space.
    deck_block(-64, 0, 12, 5);    // stepped nose
    deck_block(-52, -3, 10, 5);
    deck_block(-42, -5, 94, 5);   // main deck under the figure
    deck_block(52, -5, 26, 5);    // right tail extension

    truck(-30);
    truck(36);

    pixel_wheel(-30);
    pixel_wheel(36);
}

module model() {
    union() {
        pixel_skateboard();
        clawd_body();
    }
}

model();
