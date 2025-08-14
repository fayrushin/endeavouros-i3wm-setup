#!/bin/sh
# Set the DISPLAY and XAUTHORITY variables
export DISPLAY=:0
export XAUTHORITY=/home/ravil/.Xauthority

turn_off_laptop_screen() {
    # Получаем список всех подключенных внешних мониторов (кроме eDP*)
    externals=($(xrandr -q | grep -w "connected" | grep -v eDP | awk '{print $1}'))
    
    if [ ${#externals[@]} -gt 0 ]; then
        logger "sleep-monitor.sh: Found ${#externals[@]} external displays: ${externals[*]}"
        
        # Выбираем первый внешний монитор как целевой для переноса рабочих пространств
        target_display=${externals[0]}
        
        # Если есть HDMI-1-0, используем его как приоритетный
        for display in "${externals[@]}"; do
            if [[ "$display" == "HDMI-1-0" ]]; then
                target_display="$display"
                break
            fi
        done
        
        logger "sleep-monitor.sh: Moving workspaces to $target_display"
        
        # Получаем список всех рабочих пространств на eDP-2
        workspaces=$(i3-msg -t get_workspaces | jq -r '.[] | select(.output == "eDP-2") | .num')
        
        # Переносим каждое рабочее пространство на целевой дисплей
        for workspace in $workspaces; do
            i3-msg "workspace number $workspace; move workspace to output $target_display" > /dev/null
        done
        
        # Выключаем экран ноутбука
        xrandr --output eDP-2 --off
    else
        logger "sleep-monitor.sh: No external displays found, cannot turn off laptop screen"
    fi
}

if grep -q closed /proc/acpi/button/lid/LID0/state; then
    turn_off_laptop_screen
    logger "sleep-monitor.sh: Lid is closed, turning off laptop screen"
else
    logger "sleep-monitor.sh: Lid is not closed, not turning off laptop screen"
fi
