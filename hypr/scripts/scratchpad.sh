#!/usr/bin/env bash
# scratchpad.sh - stash/unstash windows with workspace memory
# Usage: scratchpad.sh stash | unstash

HISTORY="/tmp/hypr-scratchpad-history"

case "${1:-}" in
    stash)
        window=$(hyprctl activewindow -j | jq -r '.address')
        workspace=$(hyprctl activewindow -j | jq -r '.workspace.id')
        [[ "$window" == "null" || -z "$window" ]] && exit 0
        # Save origin, overwrite if window already tracked
        grep -v "^$window " "$HISTORY" 2>/dev/null > "$HISTORY.tmp" || true
        echo "$window $workspace" >> "$HISTORY.tmp"
        mv "$HISTORY.tmp" "$HISTORY"
        hyprctl dispatch movetoworkspace special:magic
        ;;
    unstash)
        # Moves window back to origin AND follows it there
        window=$(hyprctl activewindow -j | jq -r '.address')
        [[ "$window" == "null" || -z "$window" ]] && exit 0
        origin=$(grep "^$window " "$HISTORY" 2>/dev/null | awk '{print $2}')
        if [[ -n "$origin" ]]; then
            hyprctl dispatch movetoworkspace "$origin"
            grep -v "^$window " "$HISTORY" > "$HISTORY.tmp" 2>/dev/null || true
            mv "$HISTORY.tmp" "$HISTORY"
        else
            hyprctl dispatch movetoworkspace "$(hyprctl monitors -j | jq -r '.[0].activeWorkspace.id')"
        fi
        ;;
    unstash-silent)
        # Moves window back to origin, stays in scratchpad
        window=$(hyprctl activewindow -j | jq -r '.address')
        [[ "$window" == "null" || -z "$window" ]] && exit 0
        origin=$(grep "^$window " "$HISTORY" 2>/dev/null | awk '{print $2}')
        if [[ -n "$origin" ]]; then
            hyprctl dispatch movetoworkspacesilent "$origin"
            grep -v "^$window " "$HISTORY" > "$HISTORY.tmp" 2>/dev/null || true
            mv "$HISTORY.tmp" "$HISTORY"
        else
            hyprctl dispatch movetoworkspacesilent "$(hyprctl monitors -j | jq -r '.[0].activeWorkspace.id')"
        fi
        ;;
    *)
        echo "Usage: scratchpad.sh stash|unstash|unstash-silent"
        exit 1
        ;;
esac
