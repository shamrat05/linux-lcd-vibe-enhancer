#!/bin/bash
# Wait for display server to settle
sleep 4
xrandr --output eDP-1-1 --set "Broadcast RGB" "Full" 2>/dev/null
xgamma -gamma 0.90 2>/dev/null
