# pic2scad

A Claude Code harness for converting reference images (sketches, photos, diagrams) into 3D-printable OpenSCAD models.

## Features

- **Image to SCAD**: Analyze reference images and generate OpenSCAD code
- **Visual iteration**: Compare renders with the original reference using Claude's vision
- **Version tracking**: Automatic versioning of design iterations (001, 002, ...)
- **Print export**: Export to 3MF (default) or STL with geometry validation
- **BOSL2 included**: Full BOSL2 library available for advanced modeling

## Requirements

- [Claude Code](https://claude.ai/claude-code)
- [OpenSCAD](https://openscad.org/) (installed and accessible)

## Quick Start

1. Place a reference image in `references/`:
   ```
   cp my_sketch.png references/
   ```

2. Use the skills in Claude Code:
   ```
   /pic2scad references/my_sketch.png
   ```

3. Iterate until the render matches your reference:
   ```
   /iterate
   ```

4. Export the final model:
   ```
   /export-print
   ```

## Workflow

```
Reference Image → /pic2scad → /iterate (repeat) → /export-print
                      ↓              ↓                    ↓
                  First .scad   Improved .scad        3MF/STL
                  + render      + visual diff         + validation
```

## Skills

| Skill | Description |
|-------|-------------|
| `/pic2scad` | Analyze reference image, generate first OpenSCAD version, render preview |
| `/iterate` | Compare render vs reference, identify differences, create improved version |
| `/export-print` | Export to 3MF/STL with geometry validation |

## Project Structure

```
pic2scad/
├── CLAUDE.md                    # Agent instructions
├── references/                  # Reference images (input)
├── libs/BOSL2/                  # BOSL2 library (submodule)
├── <model>_NNN.scad             # Generated OpenSCAD files
├── <model>_NNN.png              # Render previews
└── .claude/skills/
    ├── pic2scad/                # Image analysis + SCAD generation
    ├── iterate/                 # Visual comparison + improvement
    ├── export-print/            # Export + validation
    └── resources/               # OpenSCAD cheatsheet, BOSL2 ref, print guidelines
```

## License

MIT
