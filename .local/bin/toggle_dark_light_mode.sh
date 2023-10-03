#!/bin/bash

if [[ "$#" -ne 2 ]]; then
	echo "You must enter <mode> <user>"
	exit 1
fi
mode=$1
user=$2
n=$(grep -n 'colors: ' "/home/${user}/.config/alacritty/alacritty.yml" | cut -d ':' -f1)
sed -i "${n}s/.*/colors: \*${mode}/" "/home/${user}/.config/alacritty/alacritty.yml"

n1=$(grep -n 'colorscheme =' "/home/${user}/.config/nvim/lua/user/init.lua" | cut -d ':' -f1)
if [[ "$mode" = "light" ]]; then
	sed -i "${n1}s/.*/  colorscheme = \"dayfox\",/" "/home/${user}/.config/nvim/lua/user/init.lua"
	cp "/home/${user}/.config/tmux/tmux.light.conf" "/home/${user}/.tmux.conf"
else
	sed -i "${n1}s/.*/  colorscheme = \"carbonfox\",/" "/home/${user}/.config/nvim/lua/user/init.lua"
	cp "/home/${user}/.config/tmux/tmux.dark.conf" "/home/${user}/.tmux.conf"
fi
tmux source-file "/home/${user}/.tmux.conf"
