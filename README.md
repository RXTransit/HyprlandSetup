Just put the damn .folders into your home directory

comes with a background by default that is executed via swaybg with the ~/.local/share/scripts/multimonwallpapers.sh bash script -- Edit this script to change the wallpaper locations, then reload with Meta + W

change the monitor names accordingly in .config/hypr/hyprland.conf   and remove some of the autostarts for programs that don't apply to you


Dependencies - 

hyprpaper waybar rofi bluetui nmtui hyprshot hyprlock grim slurp wiremix hyprshutdown swaybg swaync hypridle bluez-utilz brightnessctl  ffzf networkmanager pacman-contrib otf-commit-mono-nerd uwsm cliphist wl-clipboard qt5ct qt6ct

Works best with SDDM Login Manager

Only Tested on Arch, Btw


If audio icons do not appear in waybar, install pipewire, pipewire-pulse,  wireplumber and run command

systemctl --user restart pipewire pipewire-pulse wireplumber

Works will in uwsm managed session
