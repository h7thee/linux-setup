# My EndeavourOS + Hyprland setup

A small, personal post-install script for **EndeavourOS**. It installs the tools I selected, optionally installs my Hyprland desktop components, and copies my Hyprland configuration.

This is not a generic installer for every Arch-based distribution. The script checks that it is running on EndeavourOS.

## What's included

### Browser and editor
- **Vivaldi** — installed from the AUR using `yay`.
- **Code - OSS** — installed from the Arch repositories as package `code`.

### Everyday utilities
- `fastfetch` — system information in the terminal
- `btop`, `htop` — resource/process monitors
- `fzf` — interactive fuzzy finder
- `ripgrep` — fast text search
- `bat` — syntax-highlighted file viewer
- `curl`, `wget` — network/download tools
- `zip`, `unzip` — archive tools
- `tmux` — terminal session manager
- `eza` — enhanced directory listing

### Programming
- `gcc`, `gdb` — C/C++ compiler and debugger
- `python`, `python-pip` — Python and its package installer
- `nodejs`, `npm` — JavaScript runtime and package manager
- `clang`, `cmake` — additional C/C++ compiler and build system

### Optional Hyprland desktop components
Installed only with `--hyprland`:
- Hyprland and `xdg-desktop-portal-hyprland`
- Waybar, Wofi, Kitty, Thunar, Hyprpaper
- Hyprlock, Hypridle, Mako
- Grim, Slurp, wl-clipboard
- Pavucontrol, Playerctl
- Hyprpolkitagent, NetworkManager applet

The script also installs `brightnessctl` because the supplied Hyprland config uses it for the laptop brightness keys.

## Before running

1. Install EndeavourOS and connect to the internet.
2. Clone this repository.
3. Read the package lists in `setup.sh`.
4. Run a dry run first. It prints the planned commands and does not change the system.

## Usage

```bash
sudo pacman -S --needed git
git clone https://github.com/h7thee/linux-setup.git
cd linux-setup

chmod +x setup.sh
./setup.sh --dry-run
```

Install everyday tools, Vivaldi, and Code - OSS:

```bash
./setup.sh
```

Also install Hyprland and its selected desktop components, then copy the config:

```bash
./setup.sh --hyprland --dry-run
./setup.sh --hyprland
```

The script asks for confirmation before making changes. It uses `pacman --needed` so packages already installed are not reinstalled. Vivaldi is an AUR package and is installed with `yay`; if `yay` is unavailable, install/configure an AUR helper and rerun the script.

## Important notes

- EndeavourOS may already include some packages depending on the installation choices. The script checks package-manager state through `pacman --needed`, so already-installed packages are skipped.
- The script performs a full system upgrade with `pacman -Syu`. Review package-manager prompts and do not interrupt an upgrade midway.
- The Hyprland configuration is copied to `~/.config/hypr/hyprland.conf`. If a file already exists, it is backed up with a timestamp before replacement.
- Waybar and Hyprpaper may need their own configuration files for a customised bar and wallpaper.
- This script does not repartition disks, format drives, modify Windows, or install/configure a bootloader.
- AUR packages are community-maintained. Review build prompts and package information before installing.

## Files

| File | Purpose |
|---|---|
| `setup.sh` | Installs selected packages and optionally configures Hyprland |
| `hyprland.conf` | Starter Hyprland keybindings and desktop behaviour |
| `README.md` | Installation and usage instructions |

## Updating this repository

After editing files locally:

```bash
git add setup.sh README.md hyprland.conf
git commit -m "Update EndeavourOS setup"
git push
```
