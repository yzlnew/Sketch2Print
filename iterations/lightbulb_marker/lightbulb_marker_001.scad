// Lightbulb Marker - Version 001
// Generated from reference image: references/20_clawd_lightbulb.png
// One-piece bulb figurine with a thick base and raised face detail.

eps = 0.01;
$fn = 64;

base_d = 23;
base_h = 16;
neck_d = 16;
neck_h = 9;
bulb_d = 38;
bulb_z = 42;
ray_len = 13;
ray_w = 3.2;

module screw_base() {
    color([0.60, 0.62, 0.62])
        union() {
            cylinder(h = base_h, d = base_d);

            for (z = [4, 8, 12])
                translate([0, 0, z])
                    cylinder(h = 1.2, d = base_d + 3.0);
        }
}

module neck() {
    color([0.92, 0.74, 0.28])
        translate([0, 0, base_h - eps])
            cylinder(h = neck_h, d1 = neck_d, d2 = bulb_d * 0.48);
}

module bulb() {
    color([1.00, 0.86, 0.30, 0.86])
        translate([0, 0, bulb_z])
            scale([1, 1, 1.10])
                sphere(d = bulb_d);
}

module ray(angle) {
    color([1.00, 0.78, 0.20])
        rotate([0, 0, angle])
            translate([0, -ray_w / 2, bulb_z + bulb_d * 0.55 - 1.6])
                cube([ray_w, ray_len, ray_w]);
}

module face_detail() {
    y = -bulb_d / 2 - 1.1;
    z = bulb_z - 6;

    color([0.86, 0.48, 0.35])
        translate([-10, y, z - 3])
            cube([20, 2.2, 15]);

    color([0.03, 0.03, 0.03]) {
        translate([-6.2, y - 0.3, z + 5])
            cube([3.2, 2.8, 3.2]);
        translate([3.0, y - 0.3, z + 5])
            cube([3.2, 2.8, 3.2]);
    }
}

module model() {
    union() {
        screw_base();
        neck();
        bulb();
        face_detail();

        for (a = [0, 45, 90, 135, 180, 225, 270, 315])
            ray(a);
    }
}

model();
