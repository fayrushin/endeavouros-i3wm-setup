#!/bin/bash

if [[ "$#" -ne 2 ]]; then
	echo "You must enter <mode> <user>"
	exit 1
fi
mode=$1
user=$2
cp "/home/${user}/.config/tmux/tmux.${mode}.conf" "/home/${user}/.tmux.conf"
cp "/home/${user}/.config/alacritty/alacritty.${mode}.toml" "/home/${user}/.config/alacritty/alacritty.toml"
n1=$(grep -n 'colorscheme =' "/home/${user}/.config/nvim/lua/user/init.lua" | cut -d ':' -f1)
scheme="nightfox"
if [[ "$mode" = "light" ]]; then
	scheme="dayfox"
fi
sed -i "${n1}s/.*/  colorscheme = \"${scheme}\",/" "/home/${user}/.config/nvim/lua/user/init.lua"
tmux source-file "/home/${user}/.tmux.conf"
