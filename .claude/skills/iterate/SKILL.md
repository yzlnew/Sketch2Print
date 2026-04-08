---
name: iterate
description: Compare the current OpenSCAD render with the original reference image via a subagent using a custom comparison prompt, then generate an improved version. Use this to iteratively refine a 3D model until it matches the reference.
allowed-tools:
  - Bash(*/render-scad.sh*)
  - Bash(*/version-scad.sh*)
  - Task
  - Read
  - Write
  - Glob
---

# iterate — Visual Comparison & Iterative Improvement

Compare the current render with the original reference image by delegating the visual comparison to a subagent with a custom prompt, then generate an improved version.

## Workflow

### 1. Locate the Reference Image and Latest Version

Use Glob to find:
- The reference image in `references/` directory
- The latest versioned `.scad` and `.png` files

```
references/<name>.*          # Original reference image
<name>_NNN.scad              # Latest SCAD source
<name>_NNN.png               # Latest render
```

### 2. Visual Comparison via Subagent (Core Step)

Delegate the comparison to a subagent using a custom prompt. The subagent should read both images and return a structured comparison the main agent can act on.

The custom prompt should instruct the subagent to:

1. **Read the reference image** — note the target shape, proportions, features
2. **Read the latest render PNG** — note what the current model looks like
3. **Compare them systematically** — focus on silhouette, proportions, key features, details, and orientation
4. **Return actionable modeling feedback** — list what is wrong, what already matches, and the highest-priority fixes

Ask the subagent to return a structured comparison like:

| Aspect | Reference | Current Render | Match? |
|--------|-----------|----------------|--------|
| Overall shape | ... | ... | ✓/✗ |
| Proportions | ... | ... | ✓/✗ |
| Key features | ... | ... | ✓/✗ |
| Details | ... | ... | ✓/✗ |
| Orientation | ... | ... | ✓/✗ |

The main agent should not do the visual comparison itself when this subagent path is available. It should use the subagent's report as the basis for the next modeling changes.

### 3. Read the Current .scad Code

Read the latest `.scad` file to understand the current implementation and identify what to change.

### 4. Plan Improvements

Based on the visual comparison, prioritize changes:
1. **Shape corrections** — fix major shape mismatches first
2. **Proportion adjustments** — scale/resize components
3. **Missing features** — add features not yet modeled
4. **Detail refinement** — improve small details last

### 5. Create the Next Version

```bash
.claude/skills/pic2scad/scripts/version-scad.sh <name>
```

Write the improved `.scad` file with the next version number. Document what changed in comments:

```openscad
// <Model Name> - Version NNN
// Changes from previous version:
// - Fixed: ...
// - Added: ...
// - Adjusted: ...
```

### 6. Render the New Version

```bash
.claude/skills/iterate/scripts/render-scad.sh <name>_<version>.scad --output <name>_<version>.png
```

### 7. Verify Improvement

Run the same subagent comparison flow again on the new render and the reference image:
- Did the changes improve the match?
- Are there regressions (things that got worse)?
- What remains to be fixed?

Report to the user:
- What was changed
- What improved
- What still needs work
- Whether another iteration is recommended

## Comparison Tips

When comparing renders to reference images:

- **Silhouette**: Compare the outline/silhouette from the same angle
- **Proportions**: Check width-to-height ratios
- **Symmetry**: Verify symmetry matches the reference
- **Curves vs straight**: Note where curves should be straight or vice versa
- **Thickness**: Check if parts are too thick or too thin
- **Angles**: Verify angles of sloped or angled features
- **Negative space**: Check holes, gaps, and cutouts

## Render Options for Better Comparison

If the default camera angle doesn't match the reference well:

```bash
# Custom camera angle
.claude/skills/iterate/scripts/render-scad.sh model.scad --camera 0,0,0,50,0,30,200

# Larger image for more detail
.claude/skills/iterate/scripts/render-scad.sh model.scad --size 1200x900

# Full render mode for accurate appearance
.claude/skills/iterate/scripts/render-scad.sh model.scad --render

# Override the default high-contrast theme if needed
.claude/skills/iterate/scripts/render-scad.sh model.scad --colorscheme Tomorrow
```

## When to Stop Iterating

Stop when:
- The overall shape clearly matches the reference
- Key functional features are present
- Proportions are close (exact match isn't always possible from a 2D reference)
- Further changes would be diminishing returns

Then proceed to `/export-print`.

## Full Pipeline

```
/pic2scad → /iterate (repeat) → /export-print
```
