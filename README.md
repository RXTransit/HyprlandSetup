# Hyprland Dotfiles

Waybar is a fork of [mechabar](https://github.com/sejjy/mechabar.git).
Background is [river-city.jpg](https://github.com/orangci/walls-catppuccin-mocha.git).

## Setup

### 1. Install dependencies

```bash
./install.sh --deps
```

### 2. Configure monitors

The configs use `HDMI-A-1` and `HDMI-A-2` by default. Get your monitor names:

```bash
hyprctl monitors
```

Then replace the connector names in `.config/hypr/hyprland.conf`, `.config/hypr/hyprpaper.conf`, and `etc/greetd/hyprland.conf`. (`etc/hyprpaper/hyprpaper.conf` is for the greeter only.) '.config/hypr/hyprpaper.conf'

Or run the interactive script (auto-detects and updates all three files):

```bash
./setup-monitors.sh
```

### 3. Copy configs

```bash
# Hyprland + Waybar
cp -r .config/hypr ~/.config/hypr
cp -r .config/waybar ~/.config/waybar

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
