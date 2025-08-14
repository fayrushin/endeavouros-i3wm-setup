#!/bin/bash
# Set the DISPLAY and XAUTHORITY variables
export DISPLAY=:0
export XAUTHORITY=/home/ravil/.Xauthority

logger "monitor_setup::Changing monitor layout..."

# Получаем список всех подключенных мониторов
all_connected=($(xrandr -q | grep -w "connected" | awk '{print $1}'))

# Ищем встроенный монитор (обычно eDP)
edp=""
for monitor in "${all_connected[@]}"; do
    if [[ $monitor == eDP* ]]; then
        edp=$monitor
        break
    fi
done

# Собираем внешние мониторы
externals=()
for monitor in "${all_connected[@]}"; do
    if [[ $monitor != $edp ]]; then
        externals+=("$monitor")
    fi
done

if [ ${#externals[@]} -gt 0 ]; then
    logger "monitor_setup::External monitors found: ${externals[*]}"
    
    # Сортируем мониторы: HDMI-1-0 должен быть первым, остальные - по алфавиту
    sorted_externals=()
    # Ищем HDMI-1-0
    for i in "${!externals[@]}"; do
        if [[ "${externals[i]}" == "HDMI-1-0" ]]; then
            sorted_externals+=("${externals[i]}")
            unset 'externals[i]'
        fi
    done
    # Сортируем оставшиеся мониторы
    sorted_externals+=($(printf "%s\n" "${externals[@]}" | sort))
    
    # Формируем команду xrandr
    xrandr_cmd="xrandr"
    primary_set=false
    pos_x=0
    
    # Сначала добавляем встроенный монитор (если есть)
    if [ -n "$edp" ]; then
        xrandr_cmd+=" --output $edp --mode 2560x1600 --pos ${pos_x}x0 --rotate normal"
        pos_x=$((pos_x + 2560))
    fi
    
    # Добавляем внешние мониторы
    for monitor in "${sorted_externals[@]}"; do
        if [ "$primary_set" = false ]; then
            xrandr_cmd+=" --output $monitor --primary --mode 2560x1440 --pos ${pos_x}x0 --rate 144 --rotate normal"
            primary_set=true
        else
            xrandr_cmd+=" --output $monitor --mode 2560x1440 --pos ${pos_x}x0 --rate 144 --rotate normal"
        fi
        pos_x=$((pos_x + 2560))
    done
    
    # Выполняем команду
    eval $xrandr_cmd
else
    logger "monitor_setup::No external monitors connected"
    if [ -n "$edp" ]; then
        xrandr --output "$edp" --primary --mode 2560x1600 --rate 240
        
        # Переносим все рабочие пространства на eDP
        workspaces=$(i3-msg -t get_workspaces | jq -r --arg edp "$edp" '.[] | select(.output != $edp) | .num')
        for workspace in $workspaces; do
            i3-msg "workspace number $workspace; move workspace to output $edp" > /dev/null
        done
    fi
fi
