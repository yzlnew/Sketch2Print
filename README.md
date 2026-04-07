# Sketch2Print

An agent-assisted workflow for turning reference images into 3D-printable OpenSCAD models and export-ready print files.

## Features

- **Agent-guided modeling**: Analyze reference images and generate OpenSCAD code with an iterative agent workflow
- **Visual iteration**: Compare renders with the original reference and refine the model step by step
- **Version tracking**: Automatic versioning of design iterations (001, 002, ...)
- **Printable output**: Export to 3MF (default) or STL with geometry validation
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
                 Agent-built    Agent-refined        Printable
                   .scad           model             3MF/STL
```

## Skills

| Skill | Description |
|-------|-------------|
| `/pic2scad` | Analyze reference image, generate first OpenSCAD version, render preview |
| `/iterate` | Compare render vs reference, identify differences, create improved version |
| `/export-print` | Export to 3MF/STL with geometry validation |

## Project Structure

```
Sketch2Print/
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
