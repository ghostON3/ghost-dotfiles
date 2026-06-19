#!/usr/bin/env bash
# screenshot.sh - area|full|window
# All modes copy to clipboard. full and window also save to file.

case "${1:-area}" in
    area)
        file=~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png
        grim -g "$(slurp)" - | tee "$file" | wl-copy
        ;;
    full)
        file=~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png
        grim - | tee "$file" | wl-copy
        ;;
    window)
        win=$(hyprctl -j activewindow)
        pos=$(echo "$win" | jq -r '"\(.at[0]),\(.at[1])"')
        size=$(echo "$win" | jq -r '"\(.size[0])x\(.size[1])"')
        file=~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png
        grim -g "$pos $size" - | tee "$file" | wl-copy
        ;;
esac
