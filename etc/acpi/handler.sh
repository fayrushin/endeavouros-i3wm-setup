#!/bin/bash
# Default acpi script that takes an entry for all actions

# Set the DISPLAY and XAUTHORITY variables
export DISPLAY=:0
export XAUTHORITY=/home/ravil/.Xauthority

is_external_monitor_connected() {
    xrandr | grep -E "^(HDMI|DP|VGA|DVI)-[0-9]-[0-9] connected" > /dev/null
    return $?
}
turn_off_laptop_screen() {
    hdmi=$(xrandr -q | grep -w "connected" | grep -v eDP | awk '{print $1}')
    if [ "$hdmi" ]; then
	    # Get the list of all workspaces on eDP-2
        workspaces=$(i3-msg -t get_workspaces | jq -r '.[] | select(.output == "eDP-2") | .num')

        # Move each workspace to hdmi
        for workspace in $workspaces; do
            i3-msg "workspace number $workspace; move workspace to output $hdmi"
        done
	fi
    xrandr --output eDP-2 --off
}

turn_on_laptop_screen() {
    # xrandr --output eDP-2 --auto
    hdmi=$(xrandr -q | grep -w "connected" | grep -v eDP | awk '{print $1}')
    if [ "$hdmi" ]; then
	    edp=$(xrandr -q | grep -w "connected" | grep -v "${hdmi}" | awk '{print $1}')
	    xrandr --output "$hdmi" --primary --mode 2560x1440 --pos 2560x0 --rate 144 --rotate normal \
		    --output "$edp" --mode 2560x1600 --pos 0x0 --rotate normal
		i3-msg "workspace number 3; move workspace to output $edp"
		i3-msg "workspace number 4; move workspace to output $edp"
    else
	    edp=$(xrandr -q | grep -w "connected" | awk '{print $1}')
	    xrandr --output $edp --primary --mode 2560x1600 --rate 240
	    # Get the list of all workspaces
        workspaces=$(i3-msg -t get_workspaces | jq -r '.[].num')

        # Move each workspace to eDP-2
        for workspace in $workspaces; do
            i3-msg "workspace number $workspace; move workspace to output $edp"
        done
    fi
    # sleep 1 && feh --bg-fill /usr/share/endeavouros/backgrounds/endeavouros-wallpaper.png
}

case "$1" in
    button/power)
        case "$2" in
            PBTN|PWRF)
                logger 'PowerButton pressed'
                ;;
            *)
                logger "ACPI action undefined: $2"
                ;;
        esac
        ;;
    button/sleep)
        case "$2" in
            SLPB|SBTN)
                logger 'SleepButton pressed'
                ;;
            *)
                logger "ACPI action undefined: $2"
                ;;
        esac
        ;;
    ac_adapter)
        case "$2" in
            AC|ACAD|ADP0)
                case "$4" in
                    00000000)
                        logger 'AC unpluged'
                        ;;
                    00000001)
                        logger 'AC pluged'
                        ;;
                esac
                ;;
            *)
                logger "ACPI action undefined: $2"
                ;;
        esac
        ;;
    battery)
        case "$2" in
            BAT0)
                case "$4" in
                    00000000)
                        logger 'Battery online'
                        ;;
                    00000001)
                        logger 'Battery offline'
                        ;;
                esac
                ;;
            CPU0)
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    button/lid)
        case "$3" in
            close)
                if is_external_monitor_connected; then
                    logger "Handler: Lid closed while external monitor ${hdmi} connected, do not suspend"
                    turn_off_laptop_screen
                else
                    logger "Handler: Lid closed while external monitor disconnected, suspend"
                    systemctl suspend
                fi
                ;;
            open)
                logger 'Handler: Lid opened'
                turn_on_laptop_screen
                ;;
            *)
                logger "ACPI action undefined: $3"
                ;;
    esac
    ;;
    *)
        logger "ACPI group/action undefined: $1 / $2"
        ;;
esac

# vim:set ts=4 sw=4 ft=sh et:
