# Hyprland Setup

![Hyprland Setup](image.png)

My personal Hyprland dotfiles and configuration for Arch Linux.

## Installation

Copy the `.config`, `.local`, and other dotfolders into your home directory:

```bash
cp -r .config ~/
cp -r .local ~/
```

## Wallpaper

Comes with a default wallpaper managed by `swaybg`. The script at `~/.local/share/scripts/multimonwallpapers.sh` controls wallpaper placement across multiple monitors.

- Edit the script to change wallpaper paths.
- Reload wallpapers with **Meta + W**.

## Configuration

- Edit `.config/hypr/hyprland.conf` to match your monitor names.
- Remove autostart entries for programs you don't use.

## Dependencies

```
hyprland hypridle hyprpicker waybar rofi bluetui nmtui hyprshot hyprlock grim slurp
wiremix hyprshutdown swaybg swaync hypridle bluez-utilz brightnessctl
fzf networkmanager pacman-contrib otf-commit-mono-nerd uwsm cliphist
wl-clipboard qt5ct qt6ct dolphin konsole kitty
```

## Display Manager

Works best with **SDDM** login manager.

## Audio

If audio icons don't appear in waybar, install `pipewire`, `pipewire-pulse`, and `wireplumber`, then run:

```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
```

## Notes

- Only tested on **Arch Linux**, btw.
- Works well in `uwsm` managed session.

## Keybindings

| Key | Action |
|-----|--------|
| Meta + W | Reload wallpapers |
