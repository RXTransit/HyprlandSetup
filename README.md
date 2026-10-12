# Umbriel Setup

![Umbriel Setup](images/image.png)

My personal Umbriel dotfiles and configuration for Arch Linux.
## Installation Script
```
##Packages 
sudo chmod +x install.sh && ./install.sh

## Manual Install

```
rsync -a -v .local/ ~/.local/
rsync -a -v .config/ ~/.config/
sudo rsync -a -v usr/ /usr/
sudo rsync -a -v etc/ /etc/

sudo chown root:root /etc 
sudo chown root:root /usr
```
## Wallpaper
Noctalia has a built in wallpaper plugin
that's what I used lol

## Configuration
all the configuration will be in ~/.config/umbriel/config.toml
afterwards run umbriel config validate

## Animated Wallpapers
Video wallpapers set by Noctalia require mpvpaper 

## Display Manager
Noctalia Greeter + Greetd

## Audio

If audio icons don't appear in waybar, install `pipewire`, `pipewire-pulse`, and `wireplumber`, then run:

```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
```

## Notes

- Tested on Arch Linux btw.
- Works well in `uwsm` managed session.

To set kitty as default terminal in thunar when opening directorys in terminal, go to thunar, click edit>configure custom actions>double click on Open Terminal Here> put in kitty %f as the command
Like wise you can set thunar  as default file manager as well
```
xdg-mime default thunar.desktop inode/directory application/x-gnome-saved-search
```
