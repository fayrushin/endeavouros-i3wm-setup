#!/bin/sh
# Set the DISPLAY and XAUTHORITY variables
export DISPLAY=:0
export XAUTHORITY=/home/ravil/.Xauthority

turn_off_laptop_screen() {
    external=$(xrandr -q | grep -w "connected" | grep -v eDP | awk '{print $1}')
    if [ "$external" ]; then
	    # Get the list of all workspaces on eDP-2
        workspaces=$(i3-msg -t get_workspaces | jq -r '.[] | select(.output == "eDP-2") | .num')

        # Move each workspace to external
        for workspace in $workspaces; do
            i3-msg "workspace number $workspace; move workspace to output $external"
        done
	fi
    xrandr --output eDP-2 --off
}
if grep -q closed /proc/acpi/button/lid/LID0/state; then
    turn_off_laptop_screen
    logger "sleep-monitor.sh: Lid is closed, turning off laptop screen"
else
    logger "sleep-monitor.sh: Lid is not closed, not turning off laptop screen"
fi
