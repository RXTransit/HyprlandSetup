#!/usr/bin/env bash
#
# HyprlandSetup installer
# Supports Arch-based, Fedora-based, and Debian/Ubuntu-based distributions.
#
# This script:
#   - Detects a supported package manager
#   - Installs the closest available dependency set
#   - Backs up conflicting dotfiles
#   - Copies .config and .local/share from this repository
#   - Prepares Noctalia's config file
#
# Run from the repository root:
#   chmod +x install.sh
#   ./install.sh
#
# Options:
#   --skip-packages   Only install the dotfiles
#   --skip-dotfiles   Only install packages
#   --dry-run         Print commands without changing anything
#   --yes             Do not ask for confirmation
#   --help            Show usage

set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/hyprland-setup/backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

SKIP_PACKAGES=false
SKIP_DOTFILES=false
DRY_RUN=false
ASSUME_YES=false

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWARNING:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
    cat <<'EOF'
Usage: ./install.sh [OPTIONS]

Options:
  --skip-packages   Do not install packages
  --skip-dotfiles   Do not copy configuration files
  --dry-run         Print commands without executing them
  --yes, -y         Assume yes for confirmation prompts
  --help, -h        Show this help
EOF
}

run() {
    if "$DRY_RUN"; then
        printf '+ '
        printf '%q ' "$@"
        printf '\n'
    else
        "$@"
    fi
}

run_root() {
    if [[ $EUID -eq 0 ]]; then
        run "$@"
    elif command -v sudo >/dev/null 2>&1; then
        run sudo "$@"
    elif command -v doas >/dev/null 2>&1; then
        run doas "$@"
    else
        die "This operation needs root privileges, but neither sudo nor doas is installed."
    fi
}

confirm() {
    "$ASSUME_YES" && return 0
    read -r -p "$1 [y/N] " reply
    [[ $reply =~ ^[Yy]$ ]]
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

parse_args() {
    while (($#)); do
        case "$1" in
            --skip-packages) SKIP_PACKAGES=true ;;
            --skip-dotfiles) SKIP_DOTFILES=true ;;
            --dry-run) DRY_RUN=true ;;
            --yes|-y) ASSUME_YES=true ;;
            --help|-h) usage; exit 0 ;;
            *) die "Unknown option: $1" ;;
        esac
        shift
    done
}

detect_package_manager() {
    if command_exists pacman; then
        PKG_FAMILY="arch"
        PKG_MANAGER="pacman"
    elif command_exists dnf5; then
        PKG_FAMILY="fedora"
        PKG_MANAGER="dnf5"
    elif command_exists dnf; then
        PKG_FAMILY="fedora"
        PKG_MANAGER="dnf"
    elif command_exists apt-get; then
        PKG_FAMILY="debian"
        PKG_MANAGER="apt"
    elif command_exists zypper; then
        PKG_FAMILY="suse"
        PKG_MANAGER="zypper"
    else
        PKG_FAMILY="unknown"
        PKG_MANAGER="unknown"
    fi
}

install_arch_packages() {
    local packages=(
        breeze breeze5
        hyprland hyprpicker hyprshot hyprshutdown
        grim slurp
        bluez bluez-utils
        uwsm cliphist
        pipewire pipewire-pulse wireplumber
        wl-clipboard
        qt5ct qt6ct
        kitty
        nwg-look
        gnome-keyring polkit
        kvantum
        xdg-desktop-portal
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        nemo
        xdg-user-dirs xdg-user-dirs-gtk
        jq libnotify
    )

    log "Installing Arch-family packages"
    run_root pacman -Syu --needed "${packages[@]}"

    if ! command_exists noctalia; then
        warn "Noctalia was not found in the official package set."
        warn "Install it from your preferred AUR helper or from Noctalia's official instructions."
    fi
}

enable_fedora_copr() {
    local dnf_cmd="$1"

    if ! command_exists copr && ! rpm -q dnf-plugins-core >/dev/null 2>&1; then
        run_root "$dnf_cmd" install -y dnf-plugins-core
    fi

    # These repositories are used by the project's documented Fedora setup.
    run_root "$dnf_cmd" copr enable -y lionheartp/Hyprland || \
        warn "Could not enable lionheartp/Hyprland COPR; continuing."

    run_root "$dnf_cmd" copr enable -y solopasha/hyprland || \
        warn "Could not enable solopasha/hyprland COPR; continuing."
}

install_fedora_packages() {
    local dnf_cmd="$PKG_MANAGER"
    local packages=(
        plasma-breeze breeze-gtk breeze-icon-theme
        qt5ct qt6ct
        kvantum kvantum-qt5
        pipewire pipewire-pulseaudio wireplumber
        bluez bluez-tools
        hyprland uwsm hyprshutdown hyprpicker
        kitty
        hyprshot grim slurp
        nwg-look
        xdg-desktop-portal
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        cliphist wl-clipboard
        nemo
        xdg-user-dirs xdg-user-dirs-gtk
        fastfetch
        jq libnotify
        mpvpaper
    )

    log "Preparing Fedora repositories"
    enable_fedora_copr "$dnf_cmd"

    log "Installing Fedora-family packages"
    run_root "$dnf_cmd" install -y "${packages[@]}"

    if ! command_exists noctalia; then
        warn "Noctalia is not installed. Try the noctalia-git package if your enabled repositories provide it."
    fi
}

setup_noctalia_apt_repo() {
    command_exists curl || run_root apt-get install -y curl
    command_exists gpg  || run_root apt-get install -y gnupg

    run_root install -d -m 0755 /etc/apt/keyrings

    if "$DRY_RUN"; then
        echo "+ curl -fsSL https://pkg.noctalia.dev/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/noctalia.gpg"
    else
        curl -fsSL https://pkg.noctalia.dev/gpg.key |
            gpg --dearmor |
            run_root tee /etc/apt/keyrings/noctalia.gpg >/dev/null
    fi

    if "$DRY_RUN"; then
        echo "+ write /etc/apt/sources.list.d/noctalia.list"
    else
        echo "deb [signed-by=/etc/apt/keyrings/noctalia.gpg] https://pkg.noctalia.dev/apt trixie main" |
            run_root tee /etc/apt/sources.list.d/noctalia.list >/dev/null
    fi
}

install_debian_packages() {
    local packages=(
        hyprland
        kitty
        qt5ct qt6ct
        uwsm
        qt-style-kvantum
        nemo
        pipewire pipewire-pulse wireplumber
        fastfetch
        xdg-desktop-portal
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        hyprshutdown hyprpicker
        bluez bluez-tools
        cliphist wl-clipboard
        grim slurp
        jq libnotify-bin
        breeze-icon-theme
        curl git
        xdg-user-dirs
    )

    log "Updating APT package metadata"
    run_root apt-get update

    log "Installing Debian-family packages"
    # Package availability varies by Debian/Ubuntu release, so install one by
    # one and continue when an optional package is unavailable.
    local pkg
    for pkg in "${packages[@]}"; do
        if ! run_root apt-get install -y "$pkg"; then
            warn "Could not install '$pkg'; it may not exist in this release."
        fi
    done

    if ! command_exists noctalia; then
        if confirm "Add Noctalia's official APT repository and install Noctalia?"; then
            setup_noctalia_apt_repo
            run_root apt-get update
            run_root apt-get install -y noctalia || \
                warn "Noctalia installation failed. Check whether your release is supported."
        fi
    fi

    if ! command_exists hyprshot; then
        warn "Hyprshot was not found in APT. Installing it into ~/.local/bin from its Git repository."
        install_hyprshot_from_git
    fi
}

install_suse_packages() {
    warn "openSUSE support is best-effort because package names and repositories vary."
    local packages=(
        hyprland kitty qt5ct qt6ct
        pipewire wireplumber
        bluez
        grim slurp
        wl-clipboard
        nemo
        jq libnotify-tools
        xdg-desktop-portal
        xdg-desktop-portal-gtk
    )

    local pkg
    for pkg in "${packages[@]}"; do
        if ! run_root zypper --non-interactive install "$pkg"; then
            warn "Could not install '$pkg'."
        fi
    done
}

install_hyprshot_from_git() {
    command_exists git || die "git is required to install Hyprshot."
    local source_dir="${XDG_DATA_HOME:-$HOME/.local/share}/hyprshot"
    local bin_dir="$HOME/.local/bin"

    run mkdir -p "$bin_dir"

    if [[ -d "$source_dir/.git" ]]; then
        run git -C "$source_dir" pull --ff-only
    else
        run git clone https://github.com/Gustash/hyprshot.git "$source_dir"
    fi

    run ln -sfn "$source_dir/hyprshot" "$bin_dir/hyprshot"
    run chmod +x "$source_dir/hyprshot"
}

install_packages() {
    detect_package_manager
    log "Detected package family: $PKG_FAMILY ($PKG_MANAGER)"

    case "$PKG_FAMILY" in
        arch)   install_arch_packages ;;
        fedora) install_fedora_packages ;;
        debian) install_debian_packages ;;
        suse)   install_suse_packages ;;
        *)
            warn "No supported package manager was detected."
            warn "Skipping package installation; the dotfiles can still be copied."
            ;;
    esac
}

backup_path() {
    local target="$1"
    local relative="${target#"$HOME"/}"
    local destination="$BACKUP_DIR/$relative"

    [[ -e "$target" || -L "$target" ]] || return 0

    log "Backing up $target"
    run mkdir -p "$(dirname "$destination")"
    run mv "$target" "$destination"
}

copy_tree_contents() {
    local source="$1"
    local destination="$2"

    [[ -d "$source" ]] || return 0
    run mkdir -p "$destination"

    # cp -a source/. destination/ copies hidden files and preserves metadata.
    run cp -a "$source/." "$destination/"
}

install_dotfiles() {
    [[ -d "$REPO_DIR/.config" ]] ||
        die "Could not find $REPO_DIR/.config. Run this script from the cloned repository."

    log "Dotfiles will be installed into $HOME"
    log "Backups will be written to $BACKUP_DIR"

    if ! confirm "Continue with the dotfile installation?"; then
        log "Dotfile installation cancelled."
        return 0
    fi

    # Back up only paths that this repository is known to replace.
    local config_source="$REPO_DIR/.config"
    local entry

    shopt -s nullglob dotglob
    for entry in "$config_source"/*; do
        backup_path "$HOME/.config/$(basename "$entry")"
    done

    if [[ -d "$REPO_DIR/.local/share" ]]; then
        for entry in "$REPO_DIR/.local/share"/*; do
            backup_path "$HOME/.local/share/$(basename "$entry")"
        done
    fi
    shopt -u nullglob dotglob

    copy_tree_contents "$REPO_DIR/.config" "$HOME/.config"
    copy_tree_contents "$REPO_DIR/.local/share" "$HOME/.local/share"

    local noctalia_dir="$HOME/.config/noctalia"
    if [[ -f "$noctalia_dir/backup-settings.toml" && ! -e "$noctalia_dir/config.toml" ]]; then
        log "Creating Noctalia config.toml from backup-settings.toml"
        run cp "$noctalia_dir/backup-settings.toml" "$noctalia_dir/config.toml"
    fi

    if command_exists xdg-user-dirs-update; then
        run xdg-user-dirs-update
    fi

    log "Dotfiles installed successfully."
    log "Backup location: $BACKUP_DIR"
}

post_install_notes() {
    cat <<'EOF'

Post-install checklist
----------------------
1. Edit ~/.config/hypr/config/monitors.lua for your display names,
   resolutions, positions, and refresh rates.
2. Review ~/.config/hypr/config/autostart.lua and remove programs you do not use.
3. Start Noctalia once from a terminal before restarting Hyprland.
4. Ensure ~/.local/bin is included in PATH.
5. Log out and start a Hyprland/UWSM session.

Optional desktop defaults:
  gsettings set org.cinnamon.desktop.default-applications.terminal exec kitty
  xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
EOF
}

main() {
    parse_args "$@"

    if [[ $EUID -eq 0 && -z ${SUDO_USER:-} ]]; then
        warn "Running the whole installer as root will install dotfiles into root's home."
        die "Run it as your normal user; the script will request elevation when necessary."
    fi

    "$SKIP_PACKAGES" || install_packages
    "$SKIP_DOTFILES" || install_dotfiles
    post_install_notes
}

main "$@"
