// Skateboard Charm - Version 004
// Reference: references/17_clawd_skateboard.png
// Changes from previous version:
// - Removed the white sticker/backing layer from the physical model.
// - Rebuilt Clawd as a true 3D block figure assembled from rectangular prisms.
// - Kept the skateboard as a pixel-style maroon deck with blocky yellow wheels.

eps = 0.02;
$fn = 32;

body_d = 18;
deck_d = 22;
wheel_d = 16;
face_d = 0.55;

orange = [0.96, 0.45, 0.29];
shadow_orange = [0.75, 0.36, 0.28];
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
    // Primary orange mass. The front silhouette follows the reference art, but
    // each area is a separate cuboid so the model reads as a 3D block figure.
    block(-28, 62, 52, 16, body_d, orange);       // top head step
    block(-36, 44, 78, 24, body_d, orange);       // main face/body
    block(-36, 24, 54, 22, body_d, orange);       // lower left body
    block(18, 24, 30, 24, body_d, orange);        // lower right body
    block(24, 56, 26, 18, body_d, orange);        // upper right step
    block(46, 42, 18, 18, body_d, orange);        // right cheek protrusion
    block(-58, 42, 24, 18, body_d, orange);       // left cheek protrusion

    // Blocky legs and dangling lower pixels.
    block(-34, 8, 14, 26, body_d, orange);
    block(-24, 2, 12, 14, body_d, orange);
    block(-6, 0, 12, 20, body_d, orange);
    block(28, 0, 12, 24, body_d, orange);
    block(44, 0, 12, 24, body_d, orange);
    block(40, 22, 14, 20, body_d, orange);

    // Darker orange blocks capture the left-side pixel shading from the image.
    face_block(-28, 62, 16, 16, shadow_orange);
    face_block(-58, 42, 24, 18, shadow_orange);
    face_block(-36, 24, 16, 42, shadow_orange);
    face_block(-34, 8, 14, 26, shadow_orange);

    // Raised square eyes on the front face.
    face_block(-8, 52, 9, 9, black);
    face_block(32, 52, 9, 9, black);
}

module deck_block(x, z, w, h) {
    block(x, z, w, h, deck_d, maroon, 0);
}

module pixel_wheel(cx) {
    // Pixel wheels are square/cuboid clusters rather than cylinders.
    block(cx - 8, -24, 16, 7, wheel_d, wheel_yellow, 0);
    block(cx - 12, -17, 24, 9, wheel_d, wheel_yellow, 0);
    block(cx - 8, -8, 16, 7, wheel_d, wheel_yellow, 0);
    face_block(cx - 3, -17, 6, 6, maroon, wheel_d);
}

module pixel_skateboard() {
    // Side-view pixel skateboard. The right tail extends farther like the
    // reference, while the left nose steps upward.
    deck_block(-62, 2, 12, 6);
    deck_block(-56, -4, 14, 6);
    deck_block(-46, -8, 54, 6);
    deck_block(8, -12, 42, 6);
    deck_block(50, -8, 24, 6);

    // Simple block trucks tucked under the deck for print strength.
    block(-32, -12, 10, 4, deck_d + 4, axle_gray, 0);
    block(34, -12, 10, 4, deck_d + 4, axle_gray, 0);

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
