# OpenSCAD Pitfalls and How to Avoid Them

Common issues when generating `.scad` files, based on practical iteration work.

## 1. BOSL2 `orient` Can Produce Blank Renders

**Symptom:** Using `cyl(..., orient=BACK)` or similar `orient` values can result in a completely blank render.

**Why it happens:** `orient` changes the object's alignment axis. When combined with `translate()` or `rotate()`, it can easily move geometry out of view or create invalid placement.

**Safer approach:** Use an explicit `rotate([90,0,0])` instead. It is much easier to reason about:

```openscad
// Bad: easy to misplace or mis-orient
translate([0, 5, 50])
    cyl(h=12, d=60, anchor=BOTTOM, orient=BACK);

// Better: predictable transform
translate([0, 5, 50])
    rotate([90, 0, 0])
        cylinder(h=12, d=60, center=true);
```

**Recommendation:** Use BOSL2 `orient` mainly inside the Attachments system (`attach()`, `position()`). For standalone placement, prefer `rotate()`.

## 2. `hull()` Between Different Shapes Can Create Unexpected Tapers

**Symptom:** You use `hull()` between a cylinder and a rectangular block expecting a flat transition, but get a funnel or tapered body instead.

**Why it happens:** `hull()` computes the convex hull of all child geometry. A circular profile and a rectangular profile naturally produce a blended convex transition.

**Safer approach:** If you need a flat connecting plate, model that plate directly with a single `cube()` instead of using `hull()` across mismatched shapes:

```openscad
// Bad: creates a tapered transition
hull() {
    translate([0,0,80]) cylinder(r=30, h=3);
    cube([35, 3, 50], center=true);
}

// Better: use a direct backplate
cube([65, 3, 110]);  // backplate
// Add the sensor ring and charger box in front of it
```

## 3. Do Not Overuse BOSL2 in Version 001

**Symptom:** The first version relies heavily on BOSL2 features such as `cuboid`, `cyl`, `diff()`, `attach()`, and `tag("remove")`, making debugging much harder when rendering fails.

**Safer approach:**
- Use native OpenSCAD primitives in version `001`: `cube()`, `cylinder()`, `difference()`, `union()`, `translate()`, `rotate()`
- Introduce BOSL2 gradually in later iterations after the base shape is confirmed
- Use BOSL2 where it clearly adds value, such as `rounding`, `chamfer`, `tube()`, or `path_sweep()`

```openscad
// First version: plain OpenSCAD for easier debugging
difference() {
    cube([40, 20, 10], center=true);
    cylinder(h=11, d=6, center=true);
}

// Later version: BOSL2 for refinement
diff()
cuboid([40,20,10], rounding=2, edges="Z") {
    tag("remove") cyl(h=11, d=6);
}
```

## 4. Validate Renders from Multiple Angles

**Symptom:** The default camera angle may show only the front of a backplate and hide important geometry in front of it, such as a ring clamp or pocket.

**Safer approach:** If key features are hidden, render additional views with `--camera`:

```bash
# Default angle
render-scad.sh model.scad --output model.png

# Front 45-degree elevated view
render-scad.sh model.scad --output model_front.png --camera 60,60,50,0,8,45,220
```

## 5. Avoid Z-Fighting in `difference()`

**Symptom:** Boolean subtraction leaves flickering surfaces or thin residual faces.

**Why it happens:** The cutting solid ends exactly flush with the target solid, which can cause ambiguous faces.

**Safer approach:** Extend the subtracting geometry by `0.01` to `0.1` mm beyond the body being cut:

```openscad
difference() {
    cube([30, 30, 10]);
    // Bad: exactly flush
    translate([5, 5, 0]) cube([20, 20, 10]);
    // Better: extend slightly past the body
    translate([5, 5, -0.01]) cube([20, 20, 10.02]);
}
```
