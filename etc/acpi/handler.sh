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
    # Получаем список всех подключенных внешних мониторов (кроме eDP*)
    externals=($(xrandr -q | grep -w "connected" | grep -v eDP | awk '{print $1}'))
    
    if [ ${#externals[@]} -gt 0 ]; then
        logger "handler.sh: Found ${#externals[@]} external displays: ${externals[*]}"
        
        # Выбираем первый внешний монитор как целевой для переноса рабочих пространств
        target_display=${externals[0]}
        
        # Если есть HDMI-1-0, используем его как приоритетный
        for display in "${externals[@]}"; do
            if [[ "$display" == "HDMI-1-0" ]]; then
                target_display="$display"
                break
            fi
        done
        
        logger "handler.sh: Moving workspaces to $target_display"
        
        # Получаем список всех рабочих пространств на eDP-2
        workspaces=$(i3-msg -t get_workspaces | jq -r '.[] | select(.output == "eDP-2") | .num')
        
        # Переносим каждое рабочее пространство на целевой дисплей
        for workspace in $workspaces; do
            i3-msg "workspace number $workspace; move workspace to output $target_display" > /dev/null
        done
        
        # Выключаем экран ноутбука
        xrandr --output eDP-2 --off
    else
        logger "handler.sh: No external displays found, cannot turn off laptop screen"
    fi
}

turn_on_laptop_screen() {
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
        logger "handler::External monitors found: ${externals[*]}"
        
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
        logger "handler::No external monitors connected"
        if [ -n "$edp" ]; then
            xrandr --output "$edp" --primary --mode 2560x1600 --rate 240
            
            # Переносим все рабочие пространства на eDP
            workspaces=$(i3-msg -t get_workspaces | jq -r --arg edp "$edp" '.[] | select(.output != $edp) | .num')
            for workspace in $workspaces; do
                i3-msg "workspace number $workspace; move workspace to output $edp" > /dev/null
            done
        fi
    fi
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
                    logger "Handler: Lid closed while external monitor connected, do not suspend"
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
