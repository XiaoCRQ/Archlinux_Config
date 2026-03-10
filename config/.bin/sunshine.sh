#!/bin/bash

W=${SUNSHINE_CLIENT_WIDTH:-2560}
H=${SUNSHINE_CLIENT_HEIGHT:-1440}
FPS=${SUNSHINE_CLIENT_FPS:-144}
NAME="SUNSHINE_V"

case "$1" in
start)
  hyprctl keyword monitor "eDP-1,disable"
  hyprctl keyword monitor "eDP-2,disable"
  hyprctl keyword monitor "DP-1,disable"
  hyprctl keyword monitor "DP-2,disable"
  hyprctl keyword monitor "DP-3,disable"

  hyprctl output create headless $NAME
  hyprctl keyword monitor "$NAME,${W}x${H}@${FPS},0x0,1"
  ;;
stop)
  hyprctl output remove $NAME
  hyprctl reload
  ;;
esac
