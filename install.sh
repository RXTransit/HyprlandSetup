#!/usr/bin/env bash
set -euo pipefail

PACKAGES=(
  hyprland hyprlock hypridle hyprpaper waybar
  kitty rofi nautilus hyprshot
  wireplumber pipewire pipewire-pulse
  bluez-utils brightnessctl fzf networkmanager pacman-contrib
  otf-commit-mono-nerd
  greetd-regreet greetd
  polkit-gnome gnome-keyring
  libnotify
)

AUR_PACKAGES=(
  uwsm
)

install_pacman_pkgs() {
  local missing=()
  for pkg in "${PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
      missing+=("$pkg")
    fi
  done
  if ((${#missing[@]})); then
    echo ":: Installing missing packages: ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
  else
    echo ":: All pacman packages already installed."
  fi
}

install_aur_pkgs() {
  if [[ -z "${SKIP_AUR:-}" && -n "${AUR_PACKAGES[*]}" ]]; then
    local helper=""
    for cmd in paru yay; do
      if command -v "$cmd" &>/dev/null; then
        helper="$cmd"
        break
      fi
    done
    if [[ -n "$helper" ]]; then
      echo ":: Installing AUR packages with $helper..."
      $helper -S --needed --noconfirm "${AUR_PACKAGES[@]}"
    else
      echo ":: No AUR helper found. Install AUR packages manually:"
      printf '   %s\n' "${AUR_PACKAGES[@]}"
    fi
  fi
}

enable_services() {
  echo ":: Enabling services..."
  local services=(
    greetd
    bluetooth
    NetworkManager
    pipewire pipewire-pulse wireplumber
  )
  for svc in "${services[@]}"; do
    if systemctl list-unit-files "$svc" &>/dev/null; then
      sudo systemctl enable --now "$svc" 2>/dev/null || true
    fi
  done
}

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --deps          Install packages
  --services      Enable systemd services
  --monitors      Interactive monitor configuration
  --skip-aur      Skip AUR package installation
  --help          Show this help
EOF
  exit 0
}

main() {
  if [[ $# -eq 0 ]]; then
    set -- --deps
  fi

  local do_deps=false do_services=false do_monitors=false
  REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --deps) do_deps=true ;;
      --services) do_services=true ;;
      --monitors) do_monitors=true ;;
      --skip-aur) SKIP_AUR=1 ;;
      --help) usage ;;
      *) echo "Unknown option: $1"; usage ;;
    esac
    shift
  done

  echo "=== HyprlandSetup Installer ==="

  $do_deps && install_pacman_pkgs
  $do_deps && install_aur_pkgs
  $do_services && enable_services
  $do_monitors && bash "$REPO_DIR/setup-monitors.sh"

  echo "=== Done ==="
}

main "$@"
