// Lightbulb Marker - Version 007
// Chunky 3D voxel model; the reference's white sticker outline is not geometry.
// Changes from previous version:
// - Fixed the bulb support gap introduced in v006.
// - Used a narrow gray structural stem so the connector reads as part of the bulb base.
// - Kept the wider/lower 3D body proportions and shallow raised surface details.

eps = 0.01;
$fn = 32;

body_depth = 30;
leg_depth = 26;
bulb_depth = 23;
detail_raise = 1.1;

orange = [0.84, 0.40, 0.26];
black = [0.02, 0.02, 0.02];
bulb_yellow = [1.00, 0.82, 0.38];
bulb_light = [1.00, 0.90, 0.58];
bulb_orange = [0.93, 0.54, 0.20];
bulb_red = [0.70, 0.22, 0.18];
base_gray = [0.60, 0.60, 0.55];
base_dark = [0.38, 0.39, 0.36];

// Rectangles are [x, z, width, height] in the front silhouette.
body_core = [
    [-40, 18, 88, 48],   // broad main body mass
    [-64, 30, 24, 20],   // large left block protrusion
    [-24, 62, 60, 16],   // low stepped upper back
    [20, 76, 24, 24],    // shorter right shoulder
    [42, 58, 14, 30],    // clean right face block
    [30, 96, 10, 8]      // small top step
];

leg_blocks = [
    [-38, 0, 10, 18],
    [-16, 0, 10, 18],
    [24, 0, 10, 18],
    [44, 0, 10, 18]
];

eye_blocks = [
    [-23, 49, 9, 10],
    [34, 51, 9, 10]
];

socket_blocks = [
    [-15, 100, 30, 6],
    [-11, 95, 22, 5],
    [-6, 77, 12, 19]     // narrow structural stem, overlapped into body and socket
];

bulb_blocks = [
    [-22, 116, 36, 29],  // central bulb body
    [-16, 145, 24, 8],   // flatter top cap
    [-32, 123, 10, 24],  // left side lobe
    [14, 123, 10, 24],   // right side lobe
    [-18, 108, 28, 9]    // lower bulb neck
];

bulb_light_blocks = [
    [-14, 121, 22, 21],
    [-7, 109, 8, 12]
];

bulb_orange_blocks = [
    [-15, 147, 22, 4],
    [-29, 129, 7, 9],
    [17, 129, 7, 9]
];

bulb_red_blocks = [
    [-8, 135, 5, 6],
    [5, 135, 5, 6],
    [-17, 127, 6, 6],
    [13, 127, 6, 6]
];

module block3d(x, z, w, d, h, col, y = 0) {
    color(col)
        translate([x, y - d / 2, z])
            cube([w, d, h]);
}

module blocks3d(rects, d, col) {
    union() {
        for (r = rects)
            block3d(r[0], r[1], r[2], d, r[3], col);
    }
}

module front_detail(x, z, w, h, base_depth, col, raise = detail_raise) {
    color(col)
        translate([x, -base_depth / 2 - raise + eps, z])
            cube([w, raise, h]);
}

module front_details(rects, base_depth, col, raise = detail_raise) {
    union() {
        for (r = rects)
            front_detail(r[0], r[1], r[2], r[3], base_depth, col, raise);
    }
}

module orange_body() {
    union() {
        blocks3d(body_core, body_depth, orange);
        blocks3d(leg_blocks, leg_depth, orange);
        front_details(eye_blocks, body_depth, black, 1.3);
    }
}

module socket() {
    union() {
        block3d(socket_blocks[2][0], socket_blocks[2][1], socket_blocks[2][2], 16, socket_blocks[2][3], base_dark, 6);
        block3d(socket_blocks[0][0], socket_blocks[0][1], socket_blocks[0][2], 20, socket_blocks[0][3], base_gray);
        block3d(socket_blocks[1][0], socket_blocks[1][1], socket_blocks[1][2], 18, socket_blocks[1][3], base_dark);
    }
}

module chunky_bulb() {
    union() {
        blocks3d(bulb_blocks, bulb_depth, bulb_yellow);
        front_details(bulb_light_blocks, bulb_depth, bulb_light, 1.0);
        front_details(bulb_orange_blocks, bulb_depth, bulb_orange, 1.1);
        front_details(bulb_red_blocks, bulb_depth, bulb_red, 1.2);
    }
}

module model() {
    union() {
        orange_body();
        socket();
        chunky_bulb();
    }
}

model();
