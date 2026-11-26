#!/usr/bin/env bash
# =====================================================================
#  setup.sh - my personal post-install script for EndeavourOS (Arch-based)
#
#  What it does:
#    1. Updates the system
#    2. Installs my everyday packages (official repos + AUR)
#    3. Optionally installs Hyprland and copies my Hyprland config
#    4. Turns on a few useful services
#
#  How to run:
#    chmod +x setup.sh
#    ./setup.sh --dry-run        # just show what WOULD happen (safe)
#    ./setup.sh                  # install the everyday packages
#    ./setup.sh --hyprland       # also install Hyprland + copy hyprland.conf
#
#  It is safe to run again: already-installed packages are skipped.
#  To add a package, just add its name to a list below.
# =====================================================================

set -uo pipefail

DRY_RUN=0
WITH_HYPRLAND=0
for arg in "$@"; do
    case "$arg" in
        --dry-run)  DRY_RUN=1 ;;
        --hyprland) WITH_HYPRLAND=1 ;;
        -h|--help)  sed -n '2,19p' "$0"; exit 0 ;;
        *) echo "Unknown option: $arg (use --help)"; exit 1 ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAILED=()

# ---------------------------------------------------------------------
# PACKAGE LISTS  (edit these!)
# ---------------------------------------------------------------------

# Everyday tools from the official Arch repos (installed with pacman)
PACMAN_PKGS=(
    git base-devel stow
    neovim htop btop fastfetch
    unzip zip wget curl
    fzf ripgrep bat eza tmux
    firefox
    # --- coding (C++ / Python / web) ---
    gcc gdb make cmake clang
    python python-pip
    nodejs npm
    code                      # Code - OSS (the open-source VS Code build)
    # --- laptop basics ---
    brightnessctl
    bluez bluez-utils
)

# Things that only exist in the AUR (installed with yay)
AUR_PKGS=(
    # visual-studio-code-bin   # Microsoft's VS Code (alternative to 'code')
    # brave-bin                # Brave browser
)

# Only installed when you run with --hyprland
HYPRLAND_PKGS=(
    hyprland                   # the window manager itself
    xdg-desktop-portal-hyprland # screen sharing, file pickers
    hyprpolkitagent            # password pop-ups for admin tasks
    hyprpaper                  # wallpaper
    hypridle hyprlock          # idle timeout + lock screen
    waybar                     # top status bar
    wofi                       # app launcher (Super+D)
    kitty                      # terminal
    mako                       # notifications
    grim slurp wl-clipboard    # screenshots + clipboard
    thunar                     # file manager
    pavucontrol                # volume control
    network-manager-applet     # wifi tray icon
    playerctl                  # media keys
    qt5-wayland qt6-wayland    # make Qt apps behave on Wayland
    noto-fonts noto-fonts-emoji
    ttf-jetbrains-mono-nerd    # nice font with icons
)

# Services to switch on (systemd)
SERVICES=(
    bluetooth.service
    fstrim.timer               # keeps SSD healthy
)

# ---------------------------------------------------------------------
# HELPER FUNCTIONS
# ---------------------------------------------------------------------

say() { echo; echo "==> $*"; }

run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

# Install packages one by one, so a single wrong name doesn't stop everything.
install_pkgs() {
    local tool="$1"; shift
    local pkg
    for pkg in "$@"; do
        case "$tool" in
            pacman) run sudo pacman -S --needed --noconfirm "$pkg" || FAILED+=("$pkg") ;;
            yay)    run yay -S --needed --noconfirm "$pkg"          || FAILED+=("$pkg") ;;
        esac
    done
}

# ---------------------------------------------------------------------
# SAFETY CHECKS
# ---------------------------------------------------------------------

if [ "$(id -u)" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
    echo "Please run this as your normal user (not root / not with sudo)."
    echo "The script asks for your password itself when needed."
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "(note: pacman not found here - this machine is not Arch-based; dry-run only)"
    else
        echo "pacman not found. This script is for Arch-based distros (EndeavourOS, Arch, ...)."
        exit 1
    fi
fi

# ---------------------------------------------------------------------
# 1. UPDATE
# ---------------------------------------------------------------------
say "Updating the system"
run sudo pacman -Syu --noconfirm

# ---------------------------------------------------------------------
# 2. PACKAGES
# ---------------------------------------------------------------------
say "Installing everyday packages (pacman)"
install_pkgs pacman "${PACMAN_PKGS[@]}"

if [ "${#AUR_PKGS[@]}" -gt 0 ]; then
    say "Installing AUR packages (yay)"
    if command -v yay >/dev/null 2>&1 || [ "$DRY_RUN" -eq 1 ]; then
        install_pkgs yay "${AUR_PKGS[@]}"
    else
        echo "yay is not installed, skipping AUR packages."
    fi
fi

# ---------------------------------------------------------------------
# 3. HYPRLAND (optional)
# ---------------------------------------------------------------------
if [ "$WITH_HYPRLAND" -eq 1 ]; then
    say "Installing Hyprland and friends"
    install_pkgs pacman "${HYPRLAND_PKGS[@]}"

    say "Copying Hyprland config"
    TARGET="$HOME/.config/hypr/hyprland.conf"
    if [ -f "$SCRIPT_DIR/hyprland.conf" ]; then
        run mkdir -p "$HOME/.config/hypr"
        if [ -f "$TARGET" ]; then
            run cp "$TARGET" "$TARGET.backup.$(date +%Y%m%d-%H%M%S)"
            echo "Existing config backed up next to the original."
        fi
        run cp "$SCRIPT_DIR/hyprland.conf" "$TARGET"
    else
        echo "No hyprland.conf found next to setup.sh - skipping."
    fi
fi

# ---------------------------------------------------------------------
# 4. SERVICES
# ---------------------------------------------------------------------
say "Enabling services"
for svc in "${SERVICES[@]}"; do
    run sudo systemctl enable --now "$svc" || FAILED+=("service:$svc")
done

# ---------------------------------------------------------------------
# SUMMARY
# ---------------------------------------------------------------------
echo
if [ "${#FAILED[@]}" -eq 0 ]; then
    echo "All done. Reboot when you are ready."
else
    echo "Done, but these failed (check the spelling or search for the right name):"
    printf '  - %s\n' "${FAILED[@]}"
fi
