# Omarchy configuration backup

This backup contains my user-level Omarchy and Hyprland configuration and a
record of installed applications. It intentionally does **not** include
documents, wallpapers, browser profiles, SSH keys, GitHub credentials, or
other personal files.

## Create or refresh the backup

Run this on an Omarchy/Arch Linux machine:

```bash
chmod +x backup-omarchy.sh
./backup-omarchy.sh
```

The script creates `omarchy-backup-YYYY-MM-DD.tar.gz`. To choose a filename:

```bash
./backup-omarchy.sh my-omarchy-backup.tar.gz
```

Review the archive before uploading it to GitHub. Configuration can contain
machine-specific paths, usernames, or settings that you may not want public.

## What is included

- `~/.config/hypr/`
- `~/.config/omarchy/`, excluding media, `backgrounds/`, and nested `.git/` metadata
- `~/.config/alacritty/`, `foot/`, `kitty/`, and `ghostty/`
- `~/.config/btop/`, `lazygit/`, and `starship.toml`
- `packages/pacman-explicit.txt`: explicitly installed Pacman packages
- `packages/pacman-aur-foreign.txt`: packages not from the Arch repositories,
  including AUR packages
- `packages/flatpak-apps.txt`: installed Flatpak applications
- `packages/omarchy-version.txt`: the Omarchy version at backup time

The package lists are records, not an automatic installer. Inspect package
names before installing them on a new machine.

## Download and restore

Clone or download this repository on the new Omarchy machine:

```bash
git clone https://github.com/USER/REPOSITORY.git
cd REPOSITORY
```

Extract the archive into your home directory. This can overwrite files with
the same names, so back up any new machine customizations first:

```bash
tar -xzf omarchy-backup-YYYY-MM-DD.tar.gz -C "$HOME"
```

Then restart the affected applications. For Hyprland, validate the restored
configuration before logging out:

```bash
hyprctl reload
hyprctl configerrors
omarchy restart shell
```

Install applications separately after reviewing the lists:

```bash
# Arch repository packages
sudo pacman -S --needed - < packages/pacman-explicit.txt

# AUR/foreign packages: install with your preferred AUR helper
yay -S --needed - < packages/pacman-aur-foreign.txt

# Flatpak applications
awk 'NF >= 1 {print $1}' packages/flatpak-apps.txt |
  xargs -r -n1 flatpak install -y flathub
```

The AUR list may include packages already provided by the base system, and the
explicit Pacman list may include packages that are not available in every
future Omarchy release. Resolve those entries individually if an install
command reports a missing package.
