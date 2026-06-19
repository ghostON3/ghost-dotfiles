#!/bin/bash
# Switch to workspace N on the monitor where focus is
# Usage: ./switch-workspace-current-monitor.sh <1-10>

WS=$1

if [ -z "$WS" ]; then
  echo "Usage: $0 <1-10>"
  exit 1
fi

# Get active monitor (where focus/window is)
ACTIVE_MONITOR=$(hyprctl activewindow -j | jq -r '.monitor')

# Map workspace number to correct workspace on current monitor
case $ACTIVE_MONITOR in
  "DP-2")
    # Left monitor: workspaces 1-5
    # Keep 1-5 as-is, wrap 6-10 to 1-5
    if [ $WS -gt 5 ]; then
      WS=$((WS - 5))
    fi
    ;;
  "DP-1")
    # Right monitor: workspaces 6-10
    # Convert 1-5 to 6-10, keep 6-10 as-is
    if [ $WS -le 5 ]; then
      WS=$((WS + 5))
    fi
    ;;
esac

hyprctl dispatch workspace $WS
