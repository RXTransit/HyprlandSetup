# Hyprland Dotfiles

Waybar is a fork of [mechabar](https://github.com/sejjy/mechabar.git).
Background is [river-city.jpg](https://github.com/orangci/walls-catppuccin-mocha.git).

## Setup

### 1. Install dependencies

```bash
./install.sh --deps
```

### 2. Configure monitors (optional)

```bash
./setup-monitors.sh
```

This detects connected displays and updates `hyprland.conf`, `hyprpaper.conf`, and `greetd/hyprland.conf` with your chosen layout.

### 3. Copy configs

```bash
# Hyprland + Waybar
cp -r .config/hypr ~/.config/hypr
cp -r .config/waybar ~/.config/waybar

# Icons, themes, cursors
cp -r usr/share/icons/* ~/.local/share/icons/
cp -r usr/share/themes/* ~/.local/share/themes/

# Background (system-wide)
sudo cp -r usr/share/backgrounds /usr/share/

# Greetd (display manager)
sudo cp -r etc/greetd /etc/

# Hyprpaper (greeter wallpaper)
sudo cp -r etc/hyprpaper /etc/
```

### 4. Enable services

```bash
./install.sh --services
```
