#!/bin/sh

hdmi=$(xrandr -q | grep -w "connected" | grep -v eDP | awk '{print $1}')
if [ "$hdmi" ]; then
	edp=$(xrandr -q | grep -w "connected" | grep -v "${hdmi}" | awk '{print $1}')
	xrandr --output "$hdmi" --primary --mode 2560x1440 --pos 2560x0 --rate 144 --rotate normal \
		--output "$edp" --mode 2560x1600 --pos 0x0 --rotate normal
else
	edp=$(xrandr -q | grep -w "connected" | awk '{print $1}')
	xrandr --output $edp --primary --mode 2560x1600 --rate 240
fi
sleep 1 && feh --bg-fill /usr/share/endeavouros/backgrounds/endeavouros-wallpaper.png
