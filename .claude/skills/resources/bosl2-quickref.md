# BOSL2 Quick Reference

The Belfry OpenSCAD Library v2 — the most comprehensive OpenSCAD library.
GitHub: https://github.com/BelfrySCAD/BOSL2
Wiki: https://github.com/BelfrySCAD/BOSL2/wiki

## Setup

```openscad
include <libs/BOSL2/std.scad>
```

For specific modules, include additional files:
```openscad
include <libs/BOSL2/std.scad>
include <libs/BOSL2/threading.scad>   // for threads
include <libs/BOSL2/gears.scad>       // for gears
include <libs/BOSL2/beziers.scad>     // for bezier curves
```

## Enhanced Primitives

### cuboid — Better cube()
```openscad
cuboid([30,20,10]);                              // centered by default
cuboid([30,20,10], rounding=2);                  // round all edges
cuboid([30,20,10], rounding=2, edges="Z");       // round only Z-aligned edges
cuboid([30,20,10], chamfer=1);                   // chamfer edges
cuboid([30,20,10], rounding=2, except=[TOP]);    // round all except top
cuboid([30,20,10], anchor=BOTTOM);               // anchor to bottom face
```

### cyl — Better cylinder()
```openscad
cyl(h=30, d=20);                                 // centered
cyl(h=30, d=20, rounding=2);                     // round top & bottom edges
cyl(h=30, d=20, rounding1=2, rounding2=0);       // round only bottom
cyl(h=30, d1=30, d2=20, chamfer2=2);             // tapered with top chamfer
```

### sphere / prismoid
```openscad
sphere(d=20);                                    // same as built-in
prismoid([40,20], [30,10], h=15);                // tapered rectangular prism
prismoid([40,20], [30,10], h=15, rounding=3);    // with rounded edges
```

## Attachments System (Key Feature)

Attach child objects to parent faces using anchor points.

### Anchors
```
TOP, BOTTOM, LEFT, RIGHT, FRONT, BACK, CENTER
TOP+LEFT, BOTTOM+FRONT+RIGHT, etc.
```

### Basic Attachment
```openscad
cuboid([30,30,10]) {
    // Attach cylinder on top face
    attach(TOP) cyl(h=20, d=10);

    // Attach on right face, pointing outward
    attach(RIGHT) cyl(h=15, d=8);
}
```

### Position (place without reorienting)
```openscad
cuboid([30,30,10]) {
    position(TOP) sphere(d=10);      // sphere sits on top, not reoriented
    position(TOP+RIGHT) sphere(d=5); // on top-right corner
}
```

### Tag for Boolean Operations
```openscad
diff()                               // automatic difference using tags
cuboid([30,30,10]) {
    tag("remove")
        attach(TOP) cyl(h=20, d=8); // this gets subtracted
}
```

## Rounding & Chamfer

```openscad
// On cuboid edges
cuboid([30,20,10], rounding=2);
cuboid([30,20,10], rounding=2, edges=[TOP+FRONT, TOP+BACK]);

// On cylinders
cyl(h=20, d=30, rounding=3);

// Rounded prism (arbitrary 2D shape extruded with rounding)
rounded_prism(
    path2d,                          // 2D path
    height=10,
    joint_top=2, joint_bot=2         // rounding at top/bottom
);
```

## Path & Sweep Operations

### path_sweep — Sweep 2D shape along 3D path
```openscad
path = arc(r=30, angle=180);
shape = circle(r=5, $fn=32);
path_sweep(shape, path);
```

### offset_sweep — Extrude with changing offset
```openscad
offset_sweep(
    circle(r=20),
    height=30,
    top=os_circle(r=3),              // round top edge
    bottom=os_circle(r=3)            // round bottom edge
);
```

## Distribution / Copies

```openscad
xcopies(n=5, spacing=10) sphere(d=8);        // 5 copies along X
ycopies(n=3, spacing=15) cube(5);            // 3 copies along Y
zcopies(n=4, spacing=8) sphere(d=5);         // 4 copies along Z

grid_copies([10,10], n=[3,4]) sphere(d=5);   // 3x4 grid

rot_copies(n=6) right(20) sphere(d=5);       // 6 copies rotated around Z
```

## Movement Shortcuts

```openscad
right(10)  child();    // translate([10,0,0])
left(10)   child();    // translate([-10,0,0])
fwd(10)    child();    // translate([0,-10,0])
back(10)   child();    // translate([0,10,0])
up(10)     child();    // translate([0,0,10])
down(10)   child();    // translate([0,0,-10])
```

## Threading

```openscad
include <libs/BOSL2/threading.scad>

threaded_rod(d=10, l=30, pitch=2);
threaded_nut(nutwidth=17, id=10, h=8, pitch=2);
trapezoidal_threaded_rod(d=10, l=30, pitch=3);
```

## Gears

```openscad
include <libs/BOSL2/gears.scad>

spur_gear(mod=2, teeth=20, thickness=5);
bevel_gear(mod=2, teeth=20, mate_teeth=30);
rack(mod=2, teeth=10, thickness=5);
```

## Useful Utilities

```openscad
// Masking / trimming
half_of(RIGHT) sphere(d=30);         // cut in half
quarter_of([1,1,0]) sphere(d=30);    // quarter slice

// Tube
tube(h=30, od=20, id=16);            // hollow cylinder

// Teardrop (printable circle)
teardrop(r=10, h=5);                 // no overhang >45°
```

## Common Patterns with BOSL2

### Rounded box with lid cutout
```openscad
diff()
cuboid([60,40,30], rounding=3, edges="Z", anchor=BOTTOM) {
    tag("remove")
        position(TOP) cuboid([56,36,20], anchor=TOP);
}
```

### Phone stand
```openscad
diff()
prismoid([60,40], [60,30], h=80, rounding=2, anchor=BOTTOM) {
    tag("remove")
        attach(FRONT, overlap=5) cuboid([50,10,70]);
}
```

### Mounting bracket
```openscad
diff()
cuboid([40,30,5], rounding=1, anchor=BOTTOM) {
    tag("remove") {
        position(CENTER) cyl(h=10, d=6);       // center hole
        xcopies(25) cyl(h=10, d=4);            // mounting holes
    }
}
```
