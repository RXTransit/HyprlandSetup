#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Hyprland + Waybar backup installer"
echo "    Installing configs and dependencies for a single-screen Arch system."
echo

# ── Dependencies (official repos only) ────────────────────────────────
PKGS=(
  hyprland waybar hyprlock hyprshot hyprpicker
  kitty rofi nautilus wofi swaybg
  uwsm polkit-gnome gnome-keyring
  python-pywal wl-clipboard imagemagick libnotify
  networkmanager blueman
  pipewire-pulse pavucontrol wireplumber
  pacman-contrib swaync
  inter-font ttf-dejavu ttf-nerd-fonts-symbols
)

echo "==> Installing official packages..."
sudo pacman -S --needed "${PKGS[@]}"

# ── AUR packages ─────────────────────────────────────────────────────
AUR=(
  bibata-modern-cursor-theme
  nerd-fonts-code-new-roman
  paru
  bluetui
  wiremix
)

install_aur() {
  if command -v paru &>/dev/null; then
    paru -S --needed "$@"
  elif command -v yay &>/dev/null; then
    yay -S --needed "$@"
  else
    echo ":: No AUR helper found (paru/yay)."
    echo "   Install paru first, then re-run or manually install:"
    printf '   %s\n' "$@"
    return 1
  fi
}

echo "==> Installing AUR packages..."
install_aur "${AUR[@]}" || true

# ── Copy configs ──────────────────────────────────────────────────────
echo "==> Copying hypr configs..."
mkdir -p "$HOME/.config/hypr"
cp -r "$DIR/hypr/"* "$HOME/.config/hypr/"

echo "==> Copying waybar configs..."
mkdir -p "$HOME/.config/waybar"
cp -r "$DIR/waybar/"* "$HOME/.config/waybar/"

echo "==> Copying wallpaper script..."
cp "$DIR/azotebg-hyprland.sh" "$HOME/azotebg-hyprland.sh"
chmod +x "$HOME/azotebg-hyprland.sh"

# ── Enable services ──────────────────────────────────────────────────
echo "==> Enabling NetworkManager..."
sudo systemctl enable --now NetworkManager

echo
echo "==> Done! Launch Hyprland from your display manager or TTY."
