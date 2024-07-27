#!/bin/bash
# Set the DISPLAY and XAUTHORITY variables
export DISPLAY=:0
export XAUTHORITY=/home/ravil/.Xauthority

external=$(xrandr -q | grep -w "connected" | grep -v eDP | awk '{print $1}')
if [ "$external" ]; then
	edp=$(xrandr -q | grep -w "connected" | grep -v "${external}" | awk '{print $1}')
	xrandr --output "$external" --primary --mode 2560x1440 --pos 2560x0 --rate 165 --rotate normal \
		--output "$edp" --mode 2560x1600 --pos 0x0 --rotate normal

	EXCLUDE_WORKSPACES=("3" "4")

  # Get the list of all workspaces
  workspaces=$(i3-msg -t get_workspaces | jq -r --arg external "$external" '.[] | select(.output != $external) | .num')

  # Function to check if a workspace is in the exclude list
  is_excluded() {
    local workspace=$1
    for exclude in "${EXCLUDE_WORKSPACES[@]}"; do
      if [[ "$workspace" == "$exclude" ]]; then
          return 0
      fi
    done
    return 1
  }

  # Move each workspace to the new monitor, except the excluded ones
  for workspace in $workspaces; do
    if ! is_excluded "$workspace"; then
      i3-msg "workspace number $workspace; move workspace to output $external" > /dev/null
    fi
  done
  
else
  edp=$(xrandr -q | grep -w "connected" | awk '{print $1}')
  xrandr --output "$edp" --primary --mode 2560x1600 --rate 240
	# Get the list of all workspaces
  workspaces=$(i3-msg -t get_workspaces | jq -r --arg edp "$edp" '.[] | select(.output != $edp) | .num')

  # Move each workspace to eDP-2
  for workspace in $workspaces; do
    i3-msg "workspace number $workspace; move workspace to output $edp" > /dev/null
  done

fi
# sleep 1 && feh --bg-fill /usr/share/endeavouros/backgrounds/endeavouros-wallpaper.png

