---
name: pic2scad
description: Analyze a reference image and generate the first version of an OpenSCAD (.scad) file. Use this when the user provides a picture/sketch of an object they want to 3D print.
allowed-tools:
  - Bash(*/render-scad.sh*)
  - Bash(*/version-scad.sh*)
  - Read
  - Write
  - Glob
---

# pic2scad — Image to OpenSCAD

Analyze a reference image, generate OpenSCAD code, render a preview, and visually compare with the original.

## Workflow

### 1. Read the Reference Image

Use the Read tool to read the user's reference image (PNG/JPG). Analyze:

- **Overall shape**: What is the object? What are its main geometric forms?
- **Components**: How many distinct parts? How do they connect?
- **Proportions**: Relative sizes of different features
- **Symmetry**: Is the object symmetric along any axis?
- **Functional features**: Holes, slots, hooks, clips, threads, etc.
- **Internal structure**: Hollow? Solid? Shell?

If the user provides dimensions, use them. Otherwise, estimate reasonable dimensions based on the object type.

### 2. Determine the Next Version Number

```bash
.claude/skills/pic2scad/scripts/version-scad.sh <name>
```

Use a descriptive model name with underscores (e.g., `phone_stand`, `cable_clip`).

### 3. Generate the .scad File

Write the OpenSCAD code to the versioned filename (e.g., `phone_stand_001.scad`).

**Code structure:**
```openscad
// <Model Name> - Version NNN
// Generated from reference image: <reference_path>

// Include BOSL2 for advanced features (if needed)
include <libs/BOSL2/std.scad>

// Parameters (easy to adjust)
width = 50;
height = 30;
// ...

// Main model
module main_model() {
    // ...
}

main_model();
```

**Guidelines:**
- Parameterize all dimensions at the top
- Use BOSL2 when it simplifies the code (cuboid with rounding, attachments, etc.)
- Use `module` for reusable components
- Start simple — capture the main shape first, details in later iterations
- Add `$fn = 64;` or appropriate resolution for curves

### 4. Render the Preview

```bash
.claude/skills/iterate/scripts/render-scad.sh <name>_<version>.scad --output <name>_<version>.png
```

The default renderer theme is a high-contrast dark scheme to make silhouette, edges, and front/back faces easier to compare against the reference image.

### 5. Visual Comparison

Read both images and compare:
1. Read the reference image again
2. Read the rendered PNG

Evaluate:
- Does the overall shape match?
- Are proportions correct?
- Are key features present?
- What's missing or wrong?

Report your findings to the user with specific observations.

## File Naming Convention

```
<model-name>_<version>.scad  →  <model-name>_<version>.png
```

Examples:
- `phone_stand_001.scad` → `phone_stand_001.png`
- `cable_clip_001.scad` → `cable_clip_001.png`

## BOSL2 Usage

BOSL2 is available at `libs/BOSL2/std.scad`. Use it for:
- Rounded shapes: `cuboid([w,d,h], rounding=2)`
- Cylinders with rounding: `cyl(h=10, d=20, rounding=1)`
- Attachments: position child objects relative to parents
- Path operations: `path_sweep()`, `offset_sweep()`
- Distributions: `xcopies()`, `grid_copies()`

See `.claude/skills/resources/bosl2-quickref.md` for the full quick reference.

**Important:** Read `.claude/skills/resources/openscad-pitfalls.md` for common pitfalls — especially: use native OpenSCAD primitives for the first version (001), avoid BOSL2 `orient` parameter outside attachments, and don't use `hull()` between different shape types.

## Next Steps

After the first version is created:
- Use `/iterate` to compare with the reference and improve
- Use `/export-print` when the design is finalized

## Full Pipeline

```
/pic2scad → /iterate (repeat) → /export-print
```
