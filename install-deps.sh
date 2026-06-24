#!/usr/bin/env bash
set -euo pipefail

packages=(
  hyprland hypridle hyprpicker hyprshot hyprlock hyprshutdown
  waybar rofi bluetui grim slurp
  swaybg swaync wiremix brightnessctl
  fzf networkmanager pacman-contrib otf-commit-mono-nerd uwsm cliphist
  wl-clipboard qt5ct qt6ct-kde dolphin konsole kitty breeze breeze5 nwg-look gnome-keyring polkit polkit-kde-agent mpvpaper
)

sudo pacman -S --needed "${packages[@]}"
