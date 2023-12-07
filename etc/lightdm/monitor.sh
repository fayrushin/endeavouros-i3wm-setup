#!/bin/sh

hdmi=$(xrandr -q | grep -w "connected" | grep -v eDP | awk '{print $1}')
if [ "$hdmi" ]; then
	edp=$(xrandr -q | grep -w "connected" | grep -v "${hdmi}" | awk '{print $1}')
	xrandr --output "$hdmi" --primary --mode 3840x2160 --pos 2560x0 --rotate normal \
		--output "$edp" --mode 2560x1600 --pos 0x560 --rotate normal
else
	edp=$(xrandr -q | grep -w "connected" | awk '{print $1}')
	xrandr --output $edp --primary --mode 2560x1600 --rate 60
fi
