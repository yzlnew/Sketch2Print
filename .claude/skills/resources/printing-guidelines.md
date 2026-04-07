# 3D Printing Design Guidelines

Design rules for FDM 3D printing. Follow these to produce print-ready models.

## Dimensional Constraints

| Parameter | Minimum | Recommended | Notes |
|-----------|---------|-------------|-------|
| Wall thickness | 0.4mm | 0.8-1.2mm | 0.4mm = single extrusion width |
| Hole diameter | 1mm | 2mm+ | Small holes tend to close up |
| Detail size | 0.4mm | 0.8mm+ | Limited by nozzle diameter |
| Layer height | 0.05mm | 0.15-0.2mm | Affects surface quality vs speed |
| Bottom layer | 0.6mm | 1.0mm+ | For bed adhesion |

## Overhangs & Supports

- **< 45° overhang**: Prints fine without support
- **45-60° overhang**: May need support, consider chamfering
- **> 60° overhang**: Needs support material
- **90° (horizontal)**: Always needs support unless bridging

**Design tips to avoid supports:**
- Use 45° chamfers instead of 90° overhangs
- Use teardrop shapes for horizontal holes
- Split into multiple parts that assemble
- Orient the model so overhangs face up

## Bridging

- **< 10mm bridge**: Usually prints fine
- **10-30mm bridge**: May sag slightly, acceptable for many uses
- **> 30mm bridge**: Likely to sag, add support or redesign

## Tolerances for Assembly

| Fit Type | Clearance | Use Case |
|----------|-----------|----------|
| Press fit | 0.1-0.2mm | Parts that stay together permanently |
| Snug fit | 0.2-0.3mm | Parts that fit tightly but can be separated |
| Loose fit | 0.3-0.5mm | Parts that slide or rotate freely |
| Thread clearance | 0.4-0.6mm | Threaded connections |

**Important:** These values vary by printer. When in doubt, use more clearance.

## Geometry Requirements

### Manifold (Watertight)
- All shapes must be closed solids — no holes in the mesh
- Every edge must be shared by exactly 2 faces
- Use `union()` when combining overlapping shapes

### No Self-Intersection
- Overlapping shapes must be explicitly unioned
- Use `union() { shape_a(); shape_b(); }` not just `shape_a(); shape_b();`

### No Zero-Thickness
- Avoid coincident faces (z-fighting)
- Add epsilon (0.01mm) overlap in `difference()` operations
- No infinitely thin walls or features

## Strength Considerations

- **Layer adhesion** is weakest along Z axis — orient parts so stress is along XY
- **Infill** affects strength: 20% for decorative, 50%+ for functional, 100% for maximum
- **Perimeters** matter more than infill for strength — use 3+ walls for functional parts
- **Round corners** reduce stress concentration — use fillets/chamfers
- **Screw holes**: Use heat-set inserts for repeated assembly, not threads in plastic

## OpenSCAD Best Practices for Printing

```openscad
// Always use epsilon in difference()
eps = 0.01;
difference() {
    cube([20,20,10]);
    translate([5,5,-eps]) cube([10,10,10+2*eps]);
}

// Teardrop for horizontal holes (no support needed)
module teardrop_hole(r, h) {
    rotate([90,0,0])
    union() {
        cylinder(h=h, r=r, center=true);
        rotate(45) cube([r*sqrt(2), r*sqrt(2), h], center=true);
    }
}

// Chamfer bottom edges for bed adhesion
module chamfered_cube(size, chamfer=0.5) {
    hull() {
        translate([0,0,chamfer])
            cube([size[0], size[1], size[2]-chamfer]);
        translate([chamfer, chamfer, 0])
            cube([size[0]-2*chamfer, size[1]-2*chamfer, size[2]]);
    }
}
```

## Common External Libraries

When standard OpenSCAD isn't enough, consider:

| Library | Stars | Best For |
|---------|-------|----------|
| **BOSL2** | 2,080 | General-purpose: rounding, attachments, paths, threads, gears |
| **NopSCADlib** | 1,558 | Real hardware: screws, nuts, bearings, motors, electronics |
| **dotSCAD** | 910 | Math: curves, surfaces, fractals, Voronoi |
| **Round-Anything** | 649 | Fillets and rounding via polyRound |
| **MCAD** | 671 | Basic parts (ships with OpenSCAD) |
| **threadlib** | 459 | ISO/UNC/UNF standard threads |
| **nutsnbolts** | 290 | Quick fastener generation |
