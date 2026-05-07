// Lightbulb Marker - Version 005
// Chunky 3D voxel model; the reference's white sticker outline is not modeled.
// Changes from previous version:
// - Narrowed and stretched the orange body silhouette.
// - Replaced the large visible orange chimney with a small rear structural post.
// - Slimmed the legs and reduced the heavy gray socket.
// - Rebalanced the bulb into a wider, lower pixel-lobe shape.

eps = 0.01;
$fn = 32;

body_depth = 30;
leg_depth = 26;
post_depth = 12;
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
    [-34, 20, 76, 52],   // main body mass
    [-54, 32, 20, 18],   // left block protrusion
    [-24, 66, 54, 16],   // stepped upper back
    [18, 80, 24, 28],    // tall right shoulder
    [36, 60, 14, 28],    // right face block
    [27, 102, 11, 8]     // small top step
];

leg_blocks = [
    [-34, 0, 10, 20],
    [-14, 0, 10, 20],
    [22, 0, 10, 20],
    [42, 0, 10, 20]
];

eye_blocks = [
    [-27, 45, 9, 10],
    [31, 46, 9, 10]
];

socket_blocks = [
    [-16, 103, 30, 7],
    [-12, 98, 22, 6]
];

rear_post = [-10, 78, 14, 0, post_depth, 26];

bulb_blocks = [
    [-22, 119, 36, 29],  // central bulb body
    [-16, 148, 24, 8],   // flatter top cap
    [-32, 126, 10, 24],  // left side lobe
    [14, 126, 10, 24],   // right side lobe
    [-18, 111, 28, 9]    // lower bulb neck
];

bulb_light_blocks = [
    [-14, 124, 22, 21],
    [-7, 112, 8, 12]
];

bulb_orange_blocks = [
    [-15, 150, 22, 4],
    [-29, 132, 7, 9],
    [17, 132, 7, 9]
];

bulb_red_blocks = [
    [-8, 138, 5, 6],
    [5, 138, 5, 6],
    [-17, 130, 6, 6],
    [13, 130, 6, 6]
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
        block3d(rear_post[0], rear_post[1], rear_post[2], rear_post[4], rear_post[5], orange, 7);
        front_details(eye_blocks, body_depth, black, 1.3);
    }
}

module socket() {
    union() {
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
