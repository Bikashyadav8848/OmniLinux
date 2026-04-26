#!/bin/bash
# Generate OmniLinux Plymouth theme assets
# Run this script to create boot splash images

set -e

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$THEME_DIR"

echo "Generating OmniLinux Plymouth theme assets..."

# Check for ImageMagick
if command -v convert &> /dev/null; then
    # Create background image
    convert -size 1920x1080 \
        gradient:'#0D1117-#1a1f2e' \
        "$ASSETS_DIR/background.png"
    echo "Created background.png"

    # Create logo image
    convert -size 200x200 \
        -background '#3D7EFF' \
        -fill white \
        -gravity center \
        -font DejaVu-Sans-Bold \
        -pointsize 36 \
        label:"Omni\nLinux" \
        "$ASSETS_DIR/logo.png"
    echo "Created logo.png"

    # Create progress bar images
    convert -size 300x20 xc:transparent \
        -stroke '#3D7EFF' -strokedewidth 2 \
        "$ASSETS_DIR/progress_box.png"
    echo "Created progress_box.png"

    convert -size 300x20 xc:'#3D7EFF' \
        "$ASSETS_DIR/progress_bar.png"
    echo "Created progress_bar.png"
else
    echo "ImageMagick not found. Creating minimal placeholders..."
    # Create minimal valid PNG placeholders
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg==" | base64 -d > "$ASSETS_DIR/background.png"
    echo "iVBORw0KGgoAAAANSUhEUgAAAMgAAAAOCAYAAAAD0eNT6AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAOxAAADsQBlSsOGwAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAADlSURBVDiN7ZKxDYAwEEV/HLEBloAFWIYrsASWYAlYgiVgCZagpEiSFPn2xX0hJEWKFMn3n+z3i6qqKoT4tAgABAgQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAggQIEAAAPgCq6xG0U6Hq1IAAAAASUVORK5CYII=" | base64 -d > "$ASSETS_DIR/logo.png"
fi

echo "Plymouth theme assets generation complete!"