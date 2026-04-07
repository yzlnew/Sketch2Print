# OpenSCAD Cheat Sheet

Quick reference for OpenSCAD built-in language features.
Full docs: https://openscad.org/cheatsheet/index.html

## 3D Primitives

```openscad
cube(size);                          // size = number or [x,y,z]
cube([10,20,30], center=true);
sphere(r=10);                        // or sphere(d=20);
cylinder(h=10, r=5);                 // or r1, r2 for cone
cylinder(h=10, d1=20, d2=10);
polyhedron(points, faces);
```

## 2D Primitives

```openscad
square(size);                        // size = number or [x,y]
square([10,20], center=true);
circle(r=10);                        // or circle(d=20);
polygon(points);                     // polygon([[0,0],[10,0],[5,10]]);
text("Hello", size=10);
```

## Transformations

```openscad
translate([x,y,z])  child();
rotate([x,y,z])     child();        // degrees around each axis
rotate(a, v=[x,y,z]) child();       // angle a around vector v
scale([x,y,z])       child();
mirror([x,y,z])      child();       // mirror across plane
multmatrix(m)        child();       // 4x4 transformation matrix
color("red")         child();       // or color([r,g,b,a])
```

## Boolean Operations

```openscad
union()        { a(); b(); }        // combine shapes
difference()   { a(); b(); }        // a minus b (first child minus rest)
intersection() { a(); b(); }        // common volume only
```

## Extrusion

```openscad
linear_extrude(height, center, twist, slices, scale)
    2d_shape();

rotate_extrude(angle=360, $fn=100)
    2d_shape();                      // 2D shape must be in positive X
```

## Advanced Operations

```openscad
hull() { a(); b(); }                // convex hull of children
minkowski() { a(); b(); }           // Minkowski sum (slow! use for rounding)
offset(r=2)  2d_shape();            // expand/shrink 2D shape (round)
offset(delta=2, chamfer=true);      // expand with chamfer
projection(cut=false) 3d_shape();   // project 3D to 2D
```

## Modules and Functions

```openscad
module my_part(width, height=10) {
    cube([width, width, height]);
}
my_part(20);
my_part(30, height=15);

function add(a, b) = a + b;
function pythagorean(a, b) = sqrt(a*a + b*b);
```

## Control Flow

```openscad
for (i = [0:10])       translate([i*5,0,0]) cube(3);
for (i = [0:2:10])     ...;         // start:step:end
for (p = [[0,0],[10,0],[5,10]])  translate(p) sphere(1);

if (condition) { ... } else { ... }

let (x = 10, y = x*2) { ... }
```

## Special Variables

```openscad
$fn = 64;       // number of fragments for circles (global or local)
$fa = 12;       // minimum angle for fragments
$fs = 2;        // minimum size of fragments

// Tip: set $fn locally for performance
cylinder(h=10, r=5, $fn=64);
```

## Math Functions

```openscad
abs(x)  ceil(x)  floor(x)  round(x)  sign(x)
min(a,b)  max(a,b)  pow(base,exp)  sqrt(x)  log(x)  ln(x)
sin(deg)  cos(deg)  tan(deg)  asin(x)  acos(x)  atan(x)  atan2(y,x)
PI  // constant
```

## List/Vector Operations

```openscad
len(list)                            // length
concat(list1, list2)                 // join lists
list[i]                              // index access
[for (i=[0:9]) i*i]                  // list comprehension
each [1,2,3]                         // flatten in list context
```

## String Functions

```openscad
str("value: ", val)                  // string concatenation
len(string)                          // string length
chr(65)                              // "A"
ord("A")                             // 65
```

## Import/Include

```openscad
include <path/to/file.scad>         // include and execute
use <path/to/file.scad>             // import modules/functions only
import("file.stl");                  // import STL/DXF/SVG
```

## Common Patterns

### Rounded cube (without BOSL2)
```openscad
minkowski() {
    cube([w-2*r, d-2*r, h-2*r], center=true);
    sphere(r=r);
}
```

### Shell (hollow object)
```openscad
difference() {
    outer_shape();
    // slightly smaller inner shape
    offset_or_scaled_inner_shape();
}
```

### Fillet/chamfer edge
```openscad
// Use hull() between two offset shapes
hull() {
    translate([0,0,0]) cylinder(r=r1, h=0.01);
    translate([0,0,h]) cylinder(r=r2, h=0.01);
}
```

### Array/grid of objects
```openscad
for (x = [0:nx-1], y = [0:ny-1])
    translate([x*spacing, y*spacing, 0])
        child_object();
```

### Epsilon for clean booleans
```openscad
// Always add small overlap in difference() to avoid z-fighting
difference() {
    cube([10,10,10]);
    translate([2,2,-0.01])
        cube([6,6,10.02]);  // extends slightly beyond
}
```
