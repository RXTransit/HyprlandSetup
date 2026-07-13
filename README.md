# Hyprland Setup

![Hyprland Setup](image.png)

My personal Hyprland dotfiles and configuration for Arch Linux. Migrated to LUA programming language
## Installation Script
```
sudo chmod +x install.sh && ./install.sh
```
## Useful Options
```
./install.sh --dry-run
./install.sh --skip-packages
./install.sh --skip-dotfiles
./install.sh --yes
```
## Manual Install
Copy the `.config`, `.local`, and other dotfolders into your home directory:

```bash
either move the lua or the hyprlang configs out of their respective folders  and put them directly into ~/.config/hypr/

cp -r .config ~/
cp -r .local ~/

then rename the ~/.config/noctalia/backup-settings.toml to config.toml and restart hyprland.
```

## Wallpaper
Noctalia has a built in wallpaper plugin
that's what I used lol

## Configuration

- Edit `.config/hypr/hyprland.lua` to match your monitor names.
- Remove autostart entries for programs you don't use.

## Dependencies for ARCH with CachyOS Repos/CachyOS

```
sudo pacman -S breeze breeze5 hyprland hyprpicker grim slurp hyprshutdown bluez bluez-utils uwsm cliphist pipewire pipewire-pulse wireplumber wl-clipboard qt5ct qt6ct kitty breeze breeze5 nwg-look gnome-keyring polkit kvantum noctalia xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk nemo xdg-user-dirs xdg-user-dirs-gtk power-profiles-daemon
```

## Animated Wallpapers
Video wallpapers set by Noctalia require mpvpaper 
The above Arch and Fedora dependencies already have precompiled binaries, Debian users will need to build from source from https://github.com/GhostNaN/mpvpaper.git
## Display Manager

Works best with **SDDM** login manager.

## Audio

If audio icons don't appear in waybar, install `pipewire`, `pipewire-pulse`, and `wireplumber`, then run:

```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
```

## Notes

- Tested on Arch Linux btw.
- Works well in `uwsm` managed session.
- `XF86AudioRaiseVolume` / `XF86AudioLowerVolume` keybinds only work if you have a **Corsair K70 RGB Core** keyboard with **OpenLinkHub** installed. (ID 1b1c:1bfd Corsair CORSAIR K70 CORE RGB Mechanical Gaming Keyboard)

To set kitty as default terminal in nemo when opening directorys in terminal run
```
gsettings set org.cinnamon.desktop.default-applications.terminal exec kitty
```
Like wise you can set nemo as default file manager as well
```
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
```

##PS

If anyone could figure out how to transfer this to NixOs, much appreciated!

Upon start-up of Hyprland, you will have an error as noctalia has not been initialised 

Run noctalia for the first time in a terminal and it will go away, then log out and log back in.

My Hyprland dotfiles have now been split for more ease of use. 

I have not actually tested that install.sh script

I have done a dry run of it 

This is arch only now

non-arch users can figure out instructions for their own distros


