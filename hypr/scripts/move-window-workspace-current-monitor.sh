#!/bin/bash
# Move active window to workspace N on the monitor where the window currently is
# Usage: ./move-window-workspace-current-monitor.sh <1-10>

WS=$1

if [ -z "$WS" ]; then
  echo "Usage: $0 <1-10>"
  exit 1
fi

# Get monitor of active window
ACTIVE_MONITOR=$(hyprctl activewindow -j | jq -r '.monitor')

# Map workspace number to correct workspace on current monitor
case $ACTIVE_MONITOR in
  "DP-2")
    # Left monitor: workspaces 1-5
    if [ $WS -gt 5 ]; then
      WS=$((WS - 5))
    fi
    ;;
  "DP-1")
    # Right monitor: workspaces 6-10
    if [ $WS -le 5 ]; then
      WS=$((WS + 5))
    fi
    ;;
esac

hyprctl dispatch movetoworkspace $WS
