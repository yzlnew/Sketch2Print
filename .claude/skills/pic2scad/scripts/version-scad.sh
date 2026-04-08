#!/bin/bash

# OpenSCAD Version Helper
# Finds the next available version number for a project name
# Stores all iterations under iterations/<project-name>/

set -e

if [[ -z "$1" ]]; then
    echo "Usage: version-scad.sh <project-name>"
    echo ""
    echo "Finds existing versions under iterations/<project-name>/ and returns the next version number."
    echo ""
    echo "Example:"
    echo "  version-scad.sh piano"
    echo "  # If iterations/piano/piano_001.scad and piano_002.scad exist, outputs: iterations/piano/piano_003"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_DIR="iterations/${PROJECT_NAME}"

mkdir -p "$PROJECT_DIR"

# Find existing versioned files for this project
EXISTING=$(ls -1 "${PROJECT_DIR}/${PROJECT_NAME}_"[0-9][0-9][0-9].scad 2>/dev/null | sort -V | tail -1 || true)

if [[ -z "$EXISTING" ]]; then
    # No existing versions, start at 001
    NEXT_VERSION="001"
    echo "No existing versions found for project '${PROJECT_NAME}'"
    echo "Project directory: ${PROJECT_DIR}"
    echo "Next version: ${PROJECT_DIR}/${PROJECT_NAME}_001"
    echo ""
    echo "Create: ${PROJECT_DIR}/${PROJECT_NAME}_001.scad"
else
    # Extract version number and increment
    CURRENT_VERSION=$(echo "$EXISTING" | sed -E "s#${PROJECT_DIR}/${PROJECT_NAME}_([0-9]{3})\.scad#\1#")
    NEXT_NUM=$((10#$CURRENT_VERSION + 1))
    NEXT_VERSION=$(printf "%03d" $NEXT_NUM)

    echo "Existing versions:"
    ls -1 "${PROJECT_DIR}/${PROJECT_NAME}_"[0-9][0-9][0-9].scad 2>/dev/null | sort -V
    echo ""
    echo "Latest: ${EXISTING}"
    echo "Next version: ${PROJECT_DIR}/${PROJECT_NAME}_${NEXT_VERSION}"
    echo ""
    echo "Create: ${PROJECT_DIR}/${PROJECT_NAME}_${NEXT_VERSION}.scad"
fi
