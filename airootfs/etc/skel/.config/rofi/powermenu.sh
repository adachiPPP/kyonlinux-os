#!/usr/bin/env bash

theme="$HOME/.config/rofi/rofi.rasi"

options="Logout\nReboot\nShutdown"

selected=$(echo -e "$options" | rofi -dmenu -p "Power" -theme "$theme")

case "$selected" in
    "Logout")   i3-msg exit ;;
    "Reboot")   systemctl reboot ;;
    "Shutdown") systemctl poweroff ;;
esac
