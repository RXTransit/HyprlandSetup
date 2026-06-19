#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(eval echo "~$REAL_USER")"

run_as_user() {
  if [[ "$EUID" -eq 0 && -n "$SUDO_USER" ]]; then
    sudo -u "$REAL_USER" "$@"
  else
    "$@"
  fi
}
BACKUP_DIR="$REAL_HOME/.config/hyprland-setup-backup-$(date +%Y%m%d-%H%M%S)"

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

copy_config() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" ]]; then
    echo "   Backing up $dest -> $BACKUP_DIR/"
    mkdir -p "$BACKUP_DIR/$(dirname "$dest")"
    mv "$dest" "$BACKUP_DIR/"
  fi
  echo "   Copying $src -> $dest"
  cp -r "$src" "$dest"
}

install_bundled_assets() {
  local dir dest
  for dir in "$REPO_DIR/usr/share/"*/; do
    dest="$REAL_HOME/.local/share/$(basename "$dir")"
    mkdir -p "$dest"
    for item in "$dir"*/; do
      local name
      name="$(basename "$item")"
      if [[ ! -e "$dest/$name" ]]; then
        cp -r "$item" "$dest/"
        echo "   Installed $name to $dest"
      else
        echo "   $name already exists at $dest, skipping."
      fi
    done
  done
}

install_user_configs() {
  echo ":: Installing user configs..."

  run_as_user copy_config "$REPO_DIR/.config/hypr" "$REAL_HOME/.config/hypr"
  run_as_user copy_config "$REPO_DIR/.config/waybar" "$REAL_HOME/.config/waybar"
  run_as_user install_bundled_assets
}

install_system_files() {
  echo ":: Installing system-level files (needs sudo)..."

  if [[ -d "$REPO_DIR/usr/share/backgrounds" ]]; then
    sudo mkdir -p /usr/share/backgrounds
    sudo cp -r "$REPO_DIR/usr/share/backgrounds/"* /usr/share/backgrounds/
    echo "   Copied backgrounds to /usr/share/backgrounds/"
  fi

  if [[ -d "$REPO_DIR/etc/greetd" ]]; then
    sudo mkdir -p /etc/greetd
    for f in "$REPO_DIR/etc/greetd/"*; do
      sudo cp "$f" /etc/greetd/
    done
    echo "   Copied greetd configs to /etc/greetd/"
  fi

  if [[ -d "$REPO_DIR/etc/hyprpaper" ]]; then
    sudo mkdir -p /etc/hyprpaper
    for f in "$REPO_DIR/etc/hyprpaper/"*; do
      sudo cp "$f" /etc/hyprpaper/
    done
    echo "   Copied hyprpaper configs to /etc/hyprpaper/"
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
  --all           Install everything (default)
  --deps          Install packages only
  --configs       Copy configs only
  --system        Install system files (backgrounds, greetd)
  --monitors      Interactive monitor configuration
  --services      Enable systemd services
  --skip-aur      Skip AUR package installation
  --help          Show this help
EOF
  exit 0
}

main() {
  if [[ $# -eq 0 ]]; then
    set -- --all
  fi

  local do_deps=false do_configs=false do_system=false do_services=false do_monitors=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all) do_deps=true; do_configs=true; do_system=true; do_services=true ;;
      --deps) do_deps=true ;;
      --configs) do_configs=true ;;
      --system) do_system=true ;;
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
  $do_configs && install_user_configs
  $do_system && install_system_files
  $do_services && enable_services
  $do_monitors && bash "$REPO_DIR/setup-monitors.sh"

  echo "=== Done ==="
}

main "$@"
