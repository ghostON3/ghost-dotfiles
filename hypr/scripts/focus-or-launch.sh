#!/bin/bash
# Focus a window by class, or launch the app if not running
# Press again to go back to the previous window
# Usage: focus-or-launch.sh <class-regex> <launch-command>

CLASS="$1"
LAUNCH="$2"
STATE_FILE="/tmp/hypr-focus-${CLASS}"

CURRENT=$(hyprctl activewindow -j | jq -r '.address')
CURRENT_CLASS=$(hyprctl activewindow -j | jq -r '.class')

# If we're already on the target app, go back to previous window
if echo "$CURRENT_CLASS" | grep -qiP "$CLASS"; then
    if [[ -f "$STATE_FILE" ]]; then
        PREV=$(cat "$STATE_FILE")
        rm "$STATE_FILE"
        hyprctl dispatch focuswindow "address:$PREV"
        exit 0
    fi
fi

# Save current window, then focus/launch target
if hyprctl clients -j | jq -e ".[] | select(.class | test(\"$CLASS\"))" > /dev/null 2>&1; then
    echo "$CURRENT" > "$STATE_FILE"
    hyprctl dispatch focuswindow "class:^($CLASS)$"
else
    echo "$CURRENT" > "$STATE_FILE"
    exec $LAUNCH &
fi
