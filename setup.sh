#!/usr/bin/env bash
# Personal post-install setup for EndeavourOS + Hyprland.
# Usage:
#   ./setup.sh --dry-run
#   ./setup.sh
#   ./setup.sh --hyprland
#   ./setup.sh --hyprland --dry-run

set -Eeuo pipefail

DRY_RUN=0
WITH_HYPRLAND=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --hyprland) WITH_HYPRLAND=1 ;;
    -h|--help)
      sed -n '1,14p' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $arg (use --help)." >&2; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FAILED=()

say() { printf '\n==> %s\n' "$*"; }

run() {
  if (( DRY_RUN )); then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

# This script is intentionally targeted at EndeavourOS, not every Arch derivative.
if [[ ! -r /etc/os-release ]]; then
  echo "Cannot identify the operating system (/etc/os-release missing)." >&2
  exit 1
fi
# shellcheck disable=SC1091
. /etc/os-release
if [[ "${ID:-}" != "endeavouros" ]]; then
  echo "This setup is intended for EndeavourOS. Detected: ${PRETTY_NAME:-unknown}." >&2
  exit 1
fi

if (( EUID == 0 )); then
  echo "Run this script as your normal user, without sudo." >&2
  exit 1
fi
command -v pacman >/dev/null || { echo "pacman was not found." >&2; exit 1; }

# Packages selected for this setup. 'code' is the Code - OSS package.
BASE_PKGS=(
  fastfetch btop fzf ripgrep bat curl wget zip unzip tmux htop eza
  gcc gdb python python-pip nodejs npm clang cmake code
  brightnessctl
)

# Hyprland and its supporting desktop utilities.
HYPRLAND_PKGS=(
  hyprland xdg-desktop-portal-hyprland
  waybar wofi kitty thunar hyprpaper hyprlock hypridle mako
  grim slurp wl-clipboard pavucontrol playerctl
  hyprpolkitagent network-manager-applet
)

# Vivaldi is distributed through the AUR, not the standard Arch repos.
AUR_PKGS=(vivaldi)

say "Target: ${PRETTY_NAME}"
say "Selected browser: Vivaldi (AUR)"
say "Selected editor: Code - OSS (pacman package: code)"
say "Base packages: ${BASE_PKGS[*]}"
if (( WITH_HYPRLAND )); then
  say "Hyprland packages: ${HYPRLAND_PKGS[*]}"
else
  say "Hyprland packages will be skipped (use --hyprland to include them)."
fi

if (( DRY_RUN )); then
  say "Dry run only: no packages, services, or configuration files will be changed."
  run sudo pacman -Syu
  run sudo pacman -S --needed "${BASE_PKGS[@]}"
  if (( WITH_HYPRLAND )); then
    run sudo pacman -S --needed "${HYPRLAND_PKGS[@]}"
  fi
  run yay -S --needed vivaldi
  if (( WITH_HYPRLAND )); then
    run install -D "$SCRIPT_DIR/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
  fi
  exit 0
fi

printf '\nReview the package list above. Continue? [y/N] '
read -r answer
[[ "$answer" =~ ^[Yy]$ ]] || { echo "Cancelled; no changes made."; exit 0; }

say "Updating EndeavourOS"
sudo pacman -Syu

say "Installing selected official repository packages"
sudo pacman -S --needed "${BASE_PKGS[@]}"

if (( WITH_HYPRLAND )); then
  say "Installing Hyprland and selected desktop utilities"
  sudo pacman -S --needed "${HYPRLAND_PKGS[@]}"
fi

say "Installing Vivaldi from the AUR"
if ! command -v yay >/dev/null 2>&1; then
  echo "yay is not installed. Install an AUR helper (EndeavourOS commonly provides yay), then rerun this script." >&2
  exit 1
fi
yay -S --needed vivaldi

if (( WITH_HYPRLAND )); then
  say "Installing your Hyprland configuration"
  TARGET="$HOME/.config/hypr/hyprland.conf"
  mkdir -p "$(dirname "$TARGET")"
  if [[ -e "$TARGET" ]]; then
    BACKUP="$TARGET.backup.$(date +%Y%m%d-%H%M%S)"
    cp -a "$TARGET" "$BACKUP"
    echo "Existing configuration backed up to: $BACKUP"
  fi
  install -m 0644 "$SCRIPT_DIR/hyprland.conf" "$TARGET"
fi

say "Finished"
echo "Review any package-manager messages above. Log out and choose the Hyprland session if it is not already active."
