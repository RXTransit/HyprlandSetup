#!/usr/bin/env bash
#
# HyprlandSetup installer for:
#   - Arch Linux
#   - CachyOS
#   - Arch Linux with the official CachyOS repositories
#
# Run from the repository root:
#   chmod +x install.sh
#   ./install.sh
#
# Options:
#   --skip-repos      Do not add the CachyOS repositories
#   --skip-packages   Only install the dotfiles
#   --skip-dotfiles   Only configure repositories/install packages
#   --dry-run         Print commands without changing anything
#   --yes, -y         Do not ask for confirmation
#   --help, -h        Show usage

set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/hyprland-setup/backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

SKIP_REPOS=false
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
  --skip-repos      Do not add the official CachyOS repositories
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
        die "Root privileges are required, but neither sudo nor doas is installed."
    fi
}

confirm() {
    "$ASSUME_YES" && return 0
    local reply
    read -r -p "$1 [y/N] " reply
    [[ $reply =~ ^[Yy]$ ]]
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

parse_args() {
    while (($#)); do
        case "$1" in
            --skip-repos)    SKIP_REPOS=true ;;
            --skip-packages) SKIP_PACKAGES=true ;;
            --skip-dotfiles) SKIP_DOTFILES=true ;;
            --dry-run)       DRY_RUN=true ;;
            --yes|-y)        ASSUME_YES=true ;;
            --help|-h)       usage; exit 0 ;;
            *) die "Unknown option: $1" ;;
        esac
        shift
    done
}

check_supported_system() {
    command_exists pacman || die "pacman was not found. This installer only supports Arch Linux and CachyOS."

    if [[ ! -f /etc/arch-release && ! -f /etc/cachyos-release ]]; then
        die "This does not appear to be Arch Linux or CachyOS."
    fi

    if [[ -f /etc/cachyos-release ]]; then
        log "Detected CachyOS"
    else
        log "Detected Arch Linux"
    fi
}

cachyos_repos_enabled() {
    grep -Eq '^[[:space:]]*\[cachyos(-[^]]+)?\][[:space:]]*$' /etc/pacman.conf 2>/dev/null
}

enable_cachyos_repositories() {
    if cachyos_repos_enabled; then
        log "CachyOS repositories are already enabled"
        return 0
    fi

    warn "This will add the official CachyOS repositories and may install CachyOS's patched pacman."
    warn "The official setup script backs up /etc/pacman.conf before modifying it."

    if ! confirm "Add the official CachyOS repositories?"; then
        die "CachyOS repositories are required by this installer. Re-run with --skip-repos only if they are already configured another way."
    fi

    local archive_url="https://mirror.cachyos.org/cachyos-repo.tar.xz"

    if "$DRY_RUN"; then
        log "Would install the official CachyOS repository configuration"
        printf '+ temp_dir=$(mktemp -d)\n'
        printf '+ curl -fL %q -o "$temp_dir/cachyos-repo.tar.xz"\n' "$archive_url"
        printf '+ tar -xf "$temp_dir/cachyos-repo.tar.xz" -C "$temp_dir"\n'
        printf '+ sudo "$temp_dir/cachyos-repo/cachyos-repo.sh"\n'
        return 0
    fi

    command_exists curl || run_root pacman -S --needed --noconfirm curl

    local temp_dir
    temp_dir="$(mktemp -d)"
    trap 'rm -rf -- "$temp_dir"' RETURN

    log "Downloading the official CachyOS repository installer"
    curl -fL "$archive_url" -o "$temp_dir/cachyos-repo.tar.xz"
    tar -xf "$temp_dir/cachyos-repo.tar.xz" -C "$temp_dir"

    local repo_script
    repo_script="$(find "$temp_dir" -type f -name cachyos-repo.sh -print -quit)"
    [[ -n "$repo_script" ]] || die "The CachyOS repository archive did not contain cachyos-repo.sh."

    run chmod +x "$repo_script"
    run_root "$repo_script"

    cachyos_repos_enabled || die "The CachyOS repository installer completed, but no CachyOS repository was found in /etc/pacman.conf."
    log "CachyOS repositories enabled"
}

install_packages() {
    local packages=(
        breeze
        breeze5
        hyprland
        hyprpicker
        hyprshutdown
        bluez
        bluez-utils
        uwsm
        cliphist
        pipewire
        pipewire-pulse
        wireplumber
        wl-clipboard
        qt5ct
        qt6ct
        kitty
        nwg-look
        gnome-keyring
        polkit
        kvantum
        xdg-desktop-portal
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        xdg-user-dirs
        xdg-user-dirs-gtk
        jq
        libnotify
        thunar
        power-profiles-daemon
        sddm
        qt6-declarative
        qt6-svg
        qt6-virtualkeyboard
        qt6-multimediia
        qt6-imageformats
    )

    log "Synchronising package databases and upgrading the system"
    run_root pacman -Syu --needed --noconfirm "${packages[@]}"
}


install_aur_packages() {
    local aur_helper=""
    local aur_packages=(
        noctalia
        mpvpaper
    )

    if command_exists paru; then
        aur_helper="paru"
    elif command_exists yay; then
        aur_helper="yay"
    else
        log "No AUR helper found; installing yay"
        run_root pacman -S --needed --noconfirm base-devel git

        if "$DRY_RUN"; then
            printf '+ temp_dir=$(mktemp -d)\n'
            printf '+ git clone https://aur.archlinux.org/yay-bin.git "$temp_dir/yay-bin"\n'
            printf '+ cd "$temp_dir/yay-bin" && makepkg -si --needed --noconfirm\n'
        else
            local temp_dir
            temp_dir="$(mktemp -d)"
            trap 'rm -rf -- "$temp_dir"' RETURN

            git clone https://aur.archlinux.org/yay-bin.git "$temp_dir/yay-bin"
            (
                cd "$temp_dir/yay-bin"
                makepkg -si --needed --noconfirm
            )
        fi

        aur_helper="yay"
    fi

    log "Installing AUR packages with $aur_helper"
    run "$aur_helper" -S --needed --noconfirm "${aur_packages[@]}"
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
    run cp -a "$source/." "$destination/"
}

install_dotfiles() {
    [[ -d "$REPO_DIR/.config" ]] ||
        die "Could not find $REPO_DIR/.config. Keep install.sh in the repository root."

    log "Dotfiles will be installed into $HOME"
    log "Existing conflicting paths will be moved to $BACKUP_DIR"

    if ! confirm "Continue with the dotfile installation?"; then
        log "Dotfile installation cancelled"
        return 0
    fi

    local entry

    shopt -s nullglob dotglob

    for entry in "$REPO_DIR/.config"/*; do
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

    log "Dotfiles installed successfully"
    log "Backup location: $BACKUP_DIR"
}

post_install_notes() {
    cat <<'EOF'

Post-install checklist
----------------------
1. Edit ~/.config/hypr/config/monitors.lua for your displays. likewise ~/.config/hypr/config/workspaces.lua for persistence
2. Review ~/.config/hypr/config/autostart.lua and remove programs you do not use.
3. Log out and start a Hyprland/UWSM session.

Optional desktop defaults:
  xdg-mime default thunar.desktop inode/directory application/x-gnome-saved-search
EOF
}

main() {
    parse_args "$@"

    if [[ $EUID -eq 0 && -z ${SUDO_USER:-} ]]; then
        die "Run this installer as your normal user. It requests elevation only when needed."
    fi

    check_supported_system

    "$SKIP_REPOS" || enable_cachyos_repositories
    if ! "$SKIP_PACKAGES"; then
        install_packages
        install_aur_packages
    fi
    "$SKIP_DOTFILES" || install_dotfiles

    post_install_notes
}

main "$@"
