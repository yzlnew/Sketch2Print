#!/bin/bash

# OpenSCAD Export to 3MF/STL with Geometry Validation
# Converts .scad files to printable formats
# Checks for non-manifold geometry and other printability issues

set -e

# Default values
OUTPUT=""
FORMAT="3mf"       # 3MF by default (more modern, supports metadata)
EXPORT_BOTH=false
BACKEND="Manifold"

# OpenSCAD path (macOS default)
OPENSCAD="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"

# Check if OpenSCAD exists
if [[ ! -x "$OPENSCAD" ]]; then
    if command -v openscad &> /dev/null; then
        OPENSCAD="openscad"
    else
        echo "Error: OpenSCAD not found at $OPENSCAD or in PATH"
        echo "Please install OpenSCAD from https://openscad.org/"
        exit 1
    fi
fi

# Parse arguments
INPUT=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --both)
            EXPORT_BOTH=true
            shift
            ;;
        --backend)
            BACKEND="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: export-print.sh <input.scad> [options]"
            echo ""
            echo "Options:"
            echo "  --output <path>     Output path (default: <input>.<format>)"
            echo "  --format <fmt>      Export format: 3mf (default) or stl"
            echo "  --both              Export both 3MF and STL"
            echo "  --backend <name>    Render backend (default: Manifold)"
            echo ""
            echo "Performs geometry validation during export:"
            echo "  - Non-manifold edges (holes in mesh)"
            echo "  - Self-intersecting geometry"
            echo "  - Degenerate faces"
            echo ""
            echo "Example:"
            echo "  export-print.sh model.scad"
            echo "  export-print.sh model.scad --format stl"
            echo "  export-print.sh model.scad --both"
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            if [[ -z "$INPUT" ]]; then
                INPUT="$1"
            else
                echo "Error: Multiple input files specified"
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate input
if [[ -z "$INPUT" ]]; then
    echo "Error: No input file specified"
    echo "Usage: export-print.sh <input.scad> [options]"
    exit 1
fi

if [[ ! -f "$INPUT" ]]; then
    echo "Error: Input file not found: $INPUT"
    exit 1
fi

BASENAME="${INPUT%.scad}"

# Function to export a single format
export_format() {
    local fmt="$1"
    local out="$2"

    echo "========================================"
    local FMT_UPPER
    FMT_UPPER=$(echo "$fmt" | tr '[:lower:]' '[:upper:]')
    echo "Export ${FMT_UPPER}: $(basename "$INPUT")"
    echo "========================================"
    echo ""

    # Build OpenSCAD command
    local CMD=("$OPENSCAD")
    CMD+=("--backend" "$BACKEND")

    if [[ "$fmt" == "stl" ]]; then
        CMD+=("--export-format" "binstl")
    fi

    CMD+=("-o" "$out")
    CMD+=("$INPUT")

    # Run OpenSCAD and capture all output
    echo "Rendering and exporting..."
    local RESULT
    RESULT=$("${CMD[@]}" 2>&1) || true

    # Check for geometry warnings
    local WARNINGS=""
    local HAS_ISSUES=false

    if echo "$RESULT" | grep -qi "not.*manifold\|non-manifold"; then
        WARNINGS="$WARNINGS\n- Non-manifold geometry detected (mesh has holes)"
        HAS_ISSUES=true
    fi

    if echo "$RESULT" | grep -qi "self-intersect"; then
        WARNINGS="$WARNINGS\n- Self-intersecting geometry detected"
        HAS_ISSUES=true
    fi

    if echo "$RESULT" | grep -qi "degenerate"; then
        WARNINGS="$WARNINGS\n- Degenerate faces detected (zero-area triangles)"
        HAS_ISSUES=true
    fi

    if echo "$RESULT" | grep -qi "WARNING\|warning"; then
        local OTHER_WARNS
        OTHER_WARNS=$(echo "$RESULT" | grep -i "warning" | head -5)
        if [[ -n "$OTHER_WARNS" ]]; then
            WARNINGS="$WARNINGS\n- Other warnings:\n$OTHER_WARNS"
        fi
    fi

    # Check if export succeeded
    if [[ -f "$out" ]]; then
        local SIZE
        SIZE=$(ls -lh "$out" | awk '{print $5}')

        echo ""
        echo "--- Export Results ---"
        echo "Output: $out"
        echo "Format: ${FMT_UPPER}"
        echo "Size: $SIZE"
        echo "Backend: $BACKEND"

        # Get triangle count from binary STL
        if [[ "$fmt" == "stl" ]]; then
            local TRIANGLES
            TRIANGLES=$(od -An -tu4 -j80 -N4 "$out" | tr -d ' ')
            echo "Triangles: $TRIANGLES"
        fi

        # Report geometry validation
        echo ""
        echo "--- Geometry Validation ---"

        if [[ "$HAS_ISSUES" == true ]]; then
            echo "STATUS: WARNING - Issues detected"
            echo -e "$WARNINGS"
            echo ""
            echo "The model may still print, but consider fixing these issues:"
            echo "- Non-manifold: Ensure all shapes are closed solids"
            echo "- Self-intersect: Use union() to properly combine overlapping shapes"
            echo "- Degenerate: Check for very thin or zero-thickness features"
        else
            echo "STATUS: PASSED - No geometry issues detected"
            echo "- Mesh appears manifold (watertight)"
            echo "- No self-intersections found"
            echo "- Ready for slicing"
        fi

        echo ""
        echo "========================================"
        if [[ "$HAS_ISSUES" == true ]]; then
            echo "RESULT: Exported with warnings -> $out"
        else
            echo "RESULT: Export successful -> $out"
        fi
        echo "========================================"
    else
        echo ""
        echo "--- Export Failed ---"
        echo "OpenSCAD output:"
        echo "$RESULT"
        echo ""
        echo "========================================"
        echo "RESULT: Export failed"
        echo "========================================"
        return 1
    fi
}

# Export
if [[ "$EXPORT_BOTH" == true ]]; then
    export_format "3mf" "${BASENAME}.3mf"
    echo ""
    export_format "stl" "${BASENAME}.stl"
elif [[ -n "$OUTPUT" ]]; then
    export_format "$FORMAT" "$OUTPUT"
else
    export_format "$FORMAT" "${BASENAME}.${FORMAT}"
fi
