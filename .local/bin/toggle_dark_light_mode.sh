#!/bin/bash

if [[ "$#" -ne 1 ]]; then
	echo "You must enter  <user>"
	exit 1
fi
mode=$(cat ~/.local/bin/mode.ini)
if [[ "$mode" = "light" ]]; then
	mode="dark"
else
  mode="light"
fi
echo $mode > ~/.local/bin/mode.ini
user=$1
cp "/home/${user}/.config/tmux/tmux.${mode}.conf" "/home/${user}/.tmux.conf"
cp "/home/${user}/.config/alacritty/alacritty.${mode}.toml" "/home/${user}/.config/alacritty/alacritty.toml"
cp "/home/${user}/.config/gtk-3.0/settings.${mode}.ini" "/home/${user}/.config/gtk-3.0/settings.ini"
cp "/home/${user}/.Xresources.${mode}" "/home/${user}/.Xresources"
n1=$(grep -n 'colorscheme =' "/home/${user}/.config/nvim/lua/plugins/astroui.lua" | cut -d ':' -f1)
scheme="nightfox"
if [[ "$mode" = "light" ]]; then
	scheme="dayfox"
fi
sed -i "${n1}s/.*/    colorscheme = \"${scheme}\",/" "/home/${user}/.config/nvim/lua/plugins/astroui.lua"
# tmux source-file "/home/${user}/.tmux.conf"
