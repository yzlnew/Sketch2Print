// Skateboard Charm - Version 001
// Generated from reference image: references/17_clawd_skateboard.png
// Solid skateboard figurine with wheels and a simple rider silhouette.

eps = 0.01;
$fn = 64;

deck_len = 78;
deck_w = 24;
deck_h = 5;
wheel_d = 11;
wheel_w = 7;
truck_w = 30;
truck_h = 4;
rider_w = 20;
rider_h = 22;
rider_d = 12;

module capsule_2d(len, w) {
    hull() {
        translate([-len / 2 + w / 2, 0])
            circle(d = w);
        translate([len / 2 - w / 2, 0])
            circle(d = w);
    }
}

module deck() {
    color([0.32, 0.42, 0.70])
        translate([0, 0, wheel_d / 2 + truck_h])
            linear_extrude(height = deck_h)
                capsule_2d(deck_len, deck_w);
}

module truck(x) {
    color([0.58, 0.58, 0.58])
        translate([x, 0, wheel_d / 2 + 2.8])
            cube([6, truck_w, truck_h], center = true);
}

module wheel(x, y) {
    color([0.05, 0.05, 0.06])
        translate([x, y, wheel_d / 2])
            rotate([90, 0, 0])
                cylinder(h = wheel_w, d = wheel_d, center = true);
}

module rider() {
    z0 = wheel_d / 2 + truck_h + deck_h - eps;
    color([0.86, 0.48, 0.35])
        translate([-rider_w / 2, -rider_d / 2, z0])
            union() {
                cube([rider_w, rider_d, rider_h]);

                translate([-4, 0, 7])
                    cube([4, rider_d, 8]);
                translate([rider_w, 0, 7])
                    cube([4, rider_d, 8]);
                translate([3, 0, -6])
                    cube([4, rider_d, 6]);
                translate([rider_w - 7, 0, -6])
                    cube([4, rider_d, 6]);
            }

    color([0.03, 0.03, 0.03]) {
        translate([-5.5, -rider_d / 2 - 0.5, z0 + 14])
            cube([3, 1.2, 3]);
        translate([2.5, -rider_d / 2 - 0.5, z0 + 14])
            cube([3, 1.2, 3]);
    }
}

module model() {
    union() {
        deck();

        for (x = [-24, 24]) {
            truck(x);
            wheel(x, -deck_w / 2 - 2.5);
            wheel(x, deck_w / 2 + 2.5);
        }

        rider();
    }
}

model();
