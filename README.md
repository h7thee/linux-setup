# EndeavourOS + Hyprland setup

Personal post-install configuration for EndeavourOS. The setup script installs selected packages and, with `--hyprland`, deploys Hyprland, Waybar, and Wofi configuration files.

## Included
- **Browser:** Vivaldi (AUR, installed only when `yay` is available)
- **Editor:** Code - OSS (`code`)
- **Everyday tools:** fastfetch, btop, fzf, ripgrep, bat, curl, wget, zip, unzip, tmux, htop, eza
- **Development:** gcc, gdb, python, pip, nodejs, npm, clang, cmake
- **Desktop:** Hyprland, Waybar, Wofi, Kitty, Thunar, Hyprpaper, Hyprlock, Hypridle, Mako, Grim, Slurp, wl-clipboard, Pavucontrol, Playerctl, Hyprpolkitagent, NetworkManager applet

## Install / repair
```bash
sudo pacman -S --needed git
git clone https://github.com/h7thee/linux-setup.git
cd linux-setup
chmod +x setup.sh
./setup.sh --hyprland --dry-run
./setup.sh --hyprland
```
Run the script as your normal user, **not** with sudo. It checks EndeavourOS, asks before changing anything, updates the system, installs selected packages, and backs up existing config files before replacing them. It does not alter partitions, Windows, or the bootloader. If `yay` is missing, Vivaldi is skipped.

## Keybindings
| Shortcut | Action |
|---|---|
| Super + Q / Super + Enter | Kitty terminal |
| Super + D | Wofi application launcher |
| Super + E | Thunar file manager |
| Super + B | Vivaldi |
| Super + Shift + Q | Close active window |
| Super + Shift + E | Exit Hyprland |
| Super + F | Toggle fullscreen |
| Super + V | Toggle floating |
| Super + 1–5 | Switch workspace |
| Super + Shift + 1–5 | Move window to workspace |

## Waybar
Includes Hyprland workspace buttons (active workspace highlighted), active window title, clock/date, volume, network, brightness, battery, and tray. Config files are installed to `~/.config/waybar/`. Wofi styling is installed to `~/.config/wofi/style.css`.

## Cursor
The Hyprland config sets `cursor:no_hardware_cursors = 1` as a test workaround for possible cursor-rendering glitches. It is not guaranteed to fix input-device problems; remove it or set it to `2` if it makes things worse.

## Files
- `setup.sh` — package installation and config deployment
- `hyprland.conf` — Hyprland settings and shortcuts
- `waybar/config.jsonc`, `waybar/style.css` — Waybar layout and appearance
- `wofi/style.css` — Wofi launcher appearance
