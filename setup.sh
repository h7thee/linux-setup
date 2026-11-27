#!/usr/bin/env bash
# EndeavourOS + Hyprland personal setup.
# Run as your normal user: ./setup.sh --hyprland

set -Eeuo pipefail

WITH_HYPRLAND=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --hyprland) WITH_HYPRLAND=1 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      echo "Usage: ./setup.sh [--hyprland] [--dry-run]"
      exit 0
      ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
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

if [[ ! -r /etc/os-release ]]; then
  echo "Cannot identify the operating system." >&2
  exit 1
fi
. /etc/os-release
if [[ "${ID:-}" != "endeavouros" ]]; then
  echo "This script is intended for EndeavourOS; detected ${PRETTY_NAME:-unknown}." >&2
  exit 1
fi
if (( EUID == 0 )); then
  echo "Do not run this script with sudo." >&2
  exit 1
fi
command -v pacman >/dev/null || { echo "pacman not found." >&2; exit 1; }

BASE_PKGS=(
  fastfetch btop fzf ripgrep bat curl wget zip unzip tmux htop eza
  gcc gdb python python-pip nodejs npm clang cmake code brightnessctl
)
HYPRLAND_PKGS=(
  hyprland xdg-desktop-portal-hyprland
  waybar wofi kitty thunar hyprpaper hyprlock hypridle mako
  grim slurp wl-clipboard pavucontrol playerctl
  hyprpolkitagent network-manager-applet
)

say "EndeavourOS setup"
say "Base packages: ${BASE_PKGS[*]}"
if (( WITH_HYPRLAND )); then
  say "Hyprland desktop packages: ${HYPRLAND_PKGS[*]}"
fi

if (( DRY_RUN )); then
  say "Dry run: no changes will be made."
  run sudo pacman -Syu
  run sudo pacman -S --needed "${BASE_PKGS[@]}"
  if (( WITH_HYPRLAND )); then
    run sudo pacman -S --needed "${HYPRLAND_PKGS[@]}"
    run install -Dm644 "$SCRIPT_DIR/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
    run install -Dm644 "$SCRIPT_DIR/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
    run install -Dm644 "$SCRIPT_DIR/waybar/style.css" "$HOME/.config/waybar/style.css"
    run install -Dm644 "$SCRIPT_DIR/wofi/style.css" "$HOME/.config/wofi/style.css"
  fi
  if command -v yay >/dev/null 2>&1; then
    run yay -S --needed vivaldi
  else
    say "yay not found; Vivaldi will be skipped in this dry run."
  fi
  exit 0
fi

printf '\nReview the package list. Continue? [y/N] '
read -r answer
[[ "$answer" =~ ^[Yy]$ ]] || { echo "Cancelled."; exit 0; }

say "Updating system"
sudo pacman -Syu
say "Installing base packages"
sudo pacman -S --needed "${BASE_PKGS[@]}"

if (( WITH_HYPRLAND )); then
  say "Installing Hyprland and desktop packages"
  sudo pacman -S --needed "${HYPRLAND_PKGS[@]}"
fi

if command -v yay >/dev/null 2>&1; then
  say "Installing Vivaldi from the AUR"
  yay -S --needed vivaldi
else
  say "yay not found; skipping Vivaldi. Install yay and rerun if you want it."
fi

backup_and_install() {
  local source="$1"
  local target="$2"
  if [[ -e "$target" ]]; then
    local backup="${target}.backup.$(date +%Y%m%d-%H%M%S)"
    cp -a "$target" "$backup"
    echo "Backed up $target to $backup"
  fi
  install -Dm644 "$source" "$target"
}

if (( WITH_HYPRLAND )); then
  say "Installing Hyprland, Waybar, and Wofi configuration files"
  backup_and_install "$SCRIPT_DIR/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
  backup_and_install "$SCRIPT_DIR/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
  backup_and_install "$SCRIPT_DIR/waybar/style.css" "$HOME/.config/waybar/style.css"
  backup_and_install "$SCRIPT_DIR/wofi/style.css" "$HOME/.config/wofi/style.css"
fi

say "Setup complete"
echo "Log out and start a fresh Hyprland session to load all startup settings."
echo "Shortcuts: Super+Q terminal | Super+D app launcher | Super+E file manager | Super+B browser"
