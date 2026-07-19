#!/usr/bin/env bash

BAT_PATH=$(upower -e 2>/dev/null | grep 'BAT')

if [ -z "$BAT_PATH" ]; then
    exit 0
fi

BAT=$(upower -i "$BAT_PATH" 2>/dev/null)
PERC=$(echo "$BAT" | grep -oP 'percentage:\s*\K[0-9]+')
STATE=$(echo "$BAT" | grep -oP 'state:\s*\K\w+')

if [ -z "$PERC" ]; then
    echo "N/A"
    exit 0
fi

case "$STATE" in
    charging)              ICON="⚡" ;;
    discharging)           ICON="🔋" ;;
    fully-charged|charged) ICON="🔌" ;;
    *)                     ICON="?" ;;
esac

echo "${ICON} ${PERC}%"

if [ "$STATE" = "discharging" ] && [ "$PERC" -le 15 ]; then
    echo "${ICON} ${PERC}%"
    echo "#f7768e"
    exit 33
fi
