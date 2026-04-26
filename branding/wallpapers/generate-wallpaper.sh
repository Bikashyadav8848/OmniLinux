#!/bin/bash
# Generate OmniLinux wallpaper
# Creates a default wallpaper using ImageMagick

set -e

WALLPAPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$WALLPAPER_DIR"

echo "Generating OmniLinux wallpaper..."

if command -v convert &> /dev/null; then
    # Create gradient background
    convert -size 1920x1080 \
        -define gradient:angle=135 \
        gradient:'#0D1117-#1a1f2e' \
        "$WALLPAPER_DIR/omnilinux-bg.png"
    
    # Add subtle pattern
    convert "$WALLPAPER_DIR/omnilinux-bg.png" \
        -fill 'rgba(61,126,255,0.1)' \
        -draw "circle 960,540 1000,540" \
        "$WALLPAPER_DIR/omnilinux-bg.png"
    
    echo "Created omnilinux-bg.png (1920x1080)"
else
    echo "ImageMagick not found. Using placeholder."
fi

# Copy to default location
mkdir -p /usr/share/backgrounds/omnilinux
cp "$WALLPAPER_DIR/omnilinux-bg.png" /usr/share/backgrounds/omnilinux/ 2>/dev/null || true
cp "$WALLPAPER_DIR/omnilinux-bg.png" /usr/share/backgrounds/omnilinux/default.png 2>/dev/null || true

echo "Wallpaper generation complete!"