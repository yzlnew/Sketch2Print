---
name: export-print
description: Export the finalized OpenSCAD model to 3MF (default) or STL format with automatic geometry validation. Use this after the design matches the reference image.
allowed-tools:
  - Bash(*/export-print.sh*)
  - Read
---

# export-print — Export to Printable Format

Convert finalized OpenSCAD designs to 3MF or STL for 3D printing, with automatic geometry validation.

## When to Use

Use this skill after:
1. The design has been iterated with `/iterate` and matches the reference image
2. The user confirms they're satisfied with the preview
3. You're ready to produce a print-ready file

## Usage

```bash
scripts/export-print.sh <input.scad> [options]
```

Use the latest `.scad` from `iterations/<project_name>/`.

### Options

- `--output <path>` — Custom output path (default: `<input>.<format>`)
- `--format <fmt>` — Export format: `3mf` (default) or `stl`
- `--both` — Export both 3MF and STL simultaneously
- `--backend <name>` — Render backend (default: `Manifold`)

### Examples

```bash
# Default: export to 3MF
scripts/export-print.sh iterations/phone_stand/phone_stand_003.scad

# Export to STL
scripts/export-print.sh iterations/phone_stand/phone_stand_003.scad --format stl

# Export both formats
scripts/export-print.sh iterations/phone_stand/phone_stand_003.scad --both
```

## Geometry Validation

During export, the script checks for common printability issues:

- **Non-manifold geometry** — Mesh has holes or edges shared by more than 2 faces
- **Self-intersecting geometry** — Parts of the model overlap incorrectly
- **Degenerate faces** — Zero-area triangles that can cause slicer issues

If issues are detected, the export still completes but warnings are shown with guidance.

## Output

```
--- Export Results ---
Output: iterations/phone_stand/phone_stand_003.3mf
Format: 3MF
Size: 245K
Backend: Manifold

--- Geometry Validation ---
STATUS: PASSED - No geometry issues detected
- Mesh appears manifold (watertight)
- No self-intersections found
- Ready for slicing
```

## Fixing Common Issues

If validation reports problems, go back to `/iterate`:

- **Non-manifold**: Ensure all shapes are closed solids, avoid 2D shapes in 3D context
- **Self-intersect**: Use `union()` to properly combine overlapping shapes
- **Degenerate**: Check for very thin features, increase `$fn` for curves

## Why 3MF over STL?

3MF is the recommended default because:
- Smaller file sizes (compressed XML)
- Supports color, material, and texture metadata
- Unambiguous units (always millimeters)
- Better compatibility with modern slicers (PrusaSlicer, Cura, BambuStudio)
- STL is still available with `--format stl` for legacy workflows

## Full Pipeline

```
/pic2scad → /iterate (repeat) → /export-print
                                      ↓
                             Geometry validation
                                      ↓
                              Ready for slicer
```
