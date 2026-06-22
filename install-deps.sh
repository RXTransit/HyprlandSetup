#!/usr/bin/env bash
set -euo pipefail

packages=(
  hyprland hypridle hyprpicker hyprshot hyprlock hyprshutdown
  waybar rofi bluetui nmtui grim slurp
  swaybg swaync wiremix bluez-utilz brightnessctl
  fzf networkmanager pacman-contrib otf-commit-mono-nerd uwsm cliphist
  wl-clipboard qt5ct qt6ct dolphin konsole kitty
)

sudo pacman -S --needed "${packages[@]}"
