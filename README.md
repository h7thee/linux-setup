# My Linux setup

Files in this folder:

| File | What it is |
|------|-----------|
| `setup.sh` | Installs my packages and turns on services (EndeavourOS / any Arch-based distro) |
| `hyprland.conf` | Starter Hyprland config, copied to `~/.config/hypr/` by `setup.sh --hyprland` |

## Use it

```bash
chmod +x setup.sh
./setup.sh --dry-run        # preview only, changes nothing
./setup.sh                  # everyday packages
./setup.sh --hyprland       # also Hyprland + config
```

Add a package: put its name in the right list near the top of `setup.sh`.
Find a package name: `pacman -Ss name` (official) or `yay -Ss name` (AUR).

## Back it up on GitHub

```bash
git init
git add .
git commit -m "my setup script"
# create an empty repo on github.com first, then:
git remote add origin https://github.com/YOUR-USERNAME/linux-setup.git
git branch -M main
git push -u origin main
```

After a reinstall: `sudo pacman -S git`, clone the repo, run `./setup.sh`.

## Hyprland first steps

- `Super+Enter` terminal, `Super+D` launcher, `Super+Q` close window, `Super+Shift+E` exit.
- If the config shows an error bar, run `hyprctl reload` and read the message,
  or compare with the example config Hyprland generates.
- Waybar and Hyprpaper need their own small config files (`~/.config/waybar/`,
  `~/.config/hypr/hyprpaper.conf`). They work with defaults / examples until you customise them.
