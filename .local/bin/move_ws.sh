#!/bin/bash

# Получение текущего активного монитора
current_output=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).output')

# Получение списка всех подключенных мониторов
connected_outputs=$(xrandr --query | grep " connected" | awk '{ print $1 }')

# Поиск другого монитора, отличного от текущего
for output in $connected_outputs; do
    if [ "$output" != "$current_output" ]; then
        target_output=$output
        break
    fi
done

# Перемещение текущего рабочего пространства на другой монитор
if [ -n "$target_output" ]; then
    i3-msg "move workspace to output $target_output"
else
    echo "Не удалось найти другой монитор"
fi
