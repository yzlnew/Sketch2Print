// Lightbulb Marker - Version 002
// Rebuilt from the reference as a front-facing pixel-art marker.
// Changes from previous version:
// - Replaced standalone round bulb with orange pixel creature body.
// - Added white blocky backing/outline as a single printable base layer.
// - Added four legs, side protrusion, black square eyes, and small pixel bulb.
// - Kept all geometry as shallow extruded blocks for a printable 2.5D object.

eps = 0.01;
$fn = 32;

outline = 4.0;
back_depth = 3.4;
body_depth = 5.8;
detail_depth = 7.1;

white = [1.00, 1.00, 0.96];
orange = [0.84, 0.40, 0.26];
black = [0.02, 0.02, 0.02];
bulb_yellow = [1.00, 0.83, 0.42];
bulb_light = [1.00, 0.91, 0.58];
bulb_orange = [0.95, 0.56, 0.22];
bulb_red = [0.74, 0.28, 0.22];
base_gray = [0.63, 0.62, 0.56];
base_dark = [0.43, 0.43, 0.39];

// Rectangles are [x, z, width, height] in the front view.
body_rects = [
    [-34, 18, 88, 50],   // main body
    [-56, 30, 22, 20],   // left blocky protrusion
    [-20, 62, 64, 16],   // stepped upper back
    [20, 78, 34, 26],    // tall right shoulder
    [42, 58, 18, 30],    // right vertical face
    [30, 96, 14, 10],    // small top step
    [-34, 0, 12, 18],    // leg 1
    [-12, 0, 12, 18],    // leg 2
    [24, 0, 12, 18],     // leg 3
    [48, 0, 12, 18]      // leg 4
];

connector_rects = [
    [-24, 68, 52, 30],
    [-18, 88, 40, 16]
];

bulb_fill_rects = [
    [-24, 118, 48, 34],
    [-16, 152, 32, 14],
    [-34, 124, 10, 34],
    [24, 124, 10, 34],
    [-18, 108, 36, 12]
];

bulb_light_rects = [
    [-16, 122, 32, 28],
    [-8, 108, 16, 16]
];

bulb_base_rects = [
    [-24, 96, 48, 12],
    [-20, 88, 40, 10]
];

bulb_detail_rects = [
    [-16, 152, 32, 7],
    [-26, 132, 9, 10],
    [17, 132, 9, 10]
];

bulb_red_rects = [
    [-9, 140, 7, 8],
    [6, 140, 7, 8],
    [-18, 130, 8, 8],
    [14, 130, 8, 8]
];

eye_rects = [
    [-25, 39, 10, 11],
    [40, 42, 10, 11]
];

module front_block(x, z, w, h, depth) {
    translate([x, -depth, z])
        cube([w, depth, h]);
}

module rect_layer(rects, depth, col) {
    color(col)
        union() {
            for (r = rects)
                front_block(r[0], r[1], r[2], r[3], depth);
        }
}

module outline_layer(rects, depth, col, margin) {
    color(col)
        union() {
            for (r = rects)
                front_block(
                    r[0] - margin,
                    r[1] - margin,
                    r[2] + 2 * margin,
                    r[3] + 2 * margin,
                    depth
                );
        }
}

module white_backing() {
    union() {
        outline_layer(body_rects, back_depth, white, outline);
        outline_layer(connector_rects, back_depth, white, outline);
        outline_layer(bulb_fill_rects, back_depth, white, outline);
        outline_layer(bulb_base_rects, back_depth, white, outline);
    }
}

module orange_body() {
    rect_layer(body_rects, body_depth, orange);
    rect_layer(eye_rects, detail_depth, black);
}

module pixel_bulb() {
    rect_layer(bulb_fill_rects, body_depth + 0.3, bulb_yellow);
    rect_layer(bulb_light_rects, body_depth + 0.6, bulb_light);
    rect_layer([bulb_base_rects[0]], body_depth + 0.2, base_gray);
    rect_layer([bulb_base_rects[1]], body_depth + 0.4, base_dark);
    rect_layer(bulb_detail_rects, detail_depth, bulb_orange);
    rect_layer(bulb_red_rects, detail_depth + 0.2, bulb_red);
}

module model() {
    union() {
        white_backing();
        orange_body();
        pixel_bulb();
    }
}

model();
