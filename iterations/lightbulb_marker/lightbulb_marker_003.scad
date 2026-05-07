// Lightbulb Marker - Version 003
// Rebuilt as a true 3D voxel-style object.
// Changes from previous version:
// - Removed the white sticker outline/backing from the printable geometry.
// - Replaced the flat 2.5D layout with deep orange body volumes.
// - Shrunk and raised the bulb into a smaller chunky 3D top detail.
// - Kept eyes and bulb markings as shallow raised surface details only.

eps = 0.01;
$fn = 32;

body_depth = 30;
leg_depth = 26;
top_depth = 28;
bulb_depth = 23;
detail_raise = 1.1;

orange = [0.84, 0.40, 0.26];
orange_side = [0.78, 0.34, 0.22];
black = [0.02, 0.02, 0.02];
bulb_yellow = [1.00, 0.82, 0.38];
bulb_light = [1.00, 0.90, 0.58];
bulb_orange = [0.93, 0.54, 0.20];
bulb_red = [0.70, 0.22, 0.18];
base_gray = [0.60, 0.60, 0.55];
base_dark = [0.38, 0.39, 0.36];

// Rectangles are [x, z, width, height] in the front silhouette.
body_core = [
    [-38, 20, 82, 46],   // main mass
    [-58, 32, 20, 18],   // left blocky protrusion
    [-24, 62, 58, 15],   // stepped upper back
    [18, 76, 30, 25],    // tall right shoulder
    [38, 58, 18, 31],    // right face block
    [27, 96, 12, 9]      // small top step
];

leg_blocks = [
    [-38, 0, 12, 20],
    [-18, 0, 12, 20],
    [20, 0, 12, 20],
    [43, 0, 12, 20]
];

eye_blocks = [
    [-27, 43, 10, 10],
    [32, 46, 10, 10]
];

socket_blocks = [
    [-18, 101, 34, 9],
    [-14, 94, 26, 8]
];

bulb_blocks = [
    [-22, 120, 34, 30],  // central bulb body
    [-14, 150, 20, 10],  // top cap
    [-30, 127, 8, 24],   // left side lobe
    [12, 127, 8, 24],    // right side lobe
    [-18, 111, 26, 10]   // lower bulb neck
];

bulb_light_blocks = [
    [-14, 124, 20, 22],
    [-7, 112, 8, 12]
];

bulb_orange_blocks = [
    [-14, 153, 20, 5],
    [-27, 132, 7, 10],
    [15, 132, 7, 10]
];

bulb_red_blocks = [
    [-8, 139, 5, 6],
    [5, 139, 5, 6],
    [-16, 130, 6, 6],
    [12, 130, 6, 6]
];

module block3d(x, z, w, d, h, col) {
    color(col)
        translate([x, -d / 2, z])
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

        // Slightly darker side slab gives the body real visual depth in 3/4 view.
        block3d(38, 58, 18, body_depth + 5, 31, orange_side);

        front_details(eye_blocks, body_depth, black, 1.3);
    }
}

module socket() {
    union() {
        block3d(socket_blocks[0][0], socket_blocks[0][1], socket_blocks[0][2], 22, socket_blocks[0][3], base_gray);
        block3d(socket_blocks[1][0], socket_blocks[1][1], socket_blocks[1][2], 20, socket_blocks[1][3], base_dark);
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
