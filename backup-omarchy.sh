#!/usr/bin/env bash
set -euo pipefail

output="${1:-omarchy-backup-$(date +%Y-%m-%d).tar.gz}"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
stage="$(mktemp -d)"
trap 'rm -rf -- "$stage"' EXIT

mkdir -p "$stage/.config" "$stage/packages"

copy_config() {
  local relative_path="$1"
  if [[ -e "$HOME/$relative_path" ]]; then
    mkdir -p "$stage/$(dirname -- "$relative_path")"
    cp -a "$HOME/$relative_path" "$stage/$relative_path"
  fi
}

copy_config ".config/hypr"
copy_config ".config/omarchy"
copy_config ".config/alacritty"
copy_config ".config/foot"
copy_config ".config/kitty"
copy_config ".config/ghostty"
copy_config ".config/btop"
copy_config ".config/lazygit"
copy_config ".config/starship.toml"

# Wallpapers and other media are intentionally omitted; keep this backup small.
rm -rf -- "$stage/.config/omarchy/backgrounds"
rm -rf -- "$stage/.config/omarchy/lock-videos"
find "$stage/.config/omarchy" -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \
     -o -iname '*.gif' -o -iname '*.mp4' -o -iname '*.webm' \) -delete
# Plugin repositories do not need their nested Git metadata in the backup.
find "$stage/.config/omarchy" -type d -name .git -prune -exec rm -rf -- {} + 2>/dev/null || true
find "$stage/.config" -type f -name '*.save' -delete

if command -v pacman >/dev/null 2>&1; then
  pacman -Qqe >"$stage/packages/pacman-explicit.txt"
  pacman -Qqm >"$stage/packages/pacman-aur-foreign.txt"
fi

if command -v flatpak >/dev/null 2>&1; then
  flatpak list --app --columns=application,origin >"$stage/packages/flatpak-apps.txt" || true
fi

if command -v omarchy >/dev/null 2>&1; then
  omarchy version >"$stage/packages/omarchy-version.txt" 2>&1 || true
fi

cat >"$stage/BACKUP-MANIFEST.txt" <<EOF
Created: $(date --iso-8601=seconds)
Host: $(hostname)
Home: $HOME

Included:
- ~/.config/hypr
- ~/.config/omarchy (without media, backgrounds/, and nested .git/ metadata)
- terminal, btop, lazygit, and starship configuration
- package inventories under packages/

Excluded:
- documents, wallpapers, and other personal files
- browser, SSH, GitHub, and credential directories
- package caches and nested Git metadata
EOF

tar -czf "$script_dir/$output" -C "$stage" .
printf 'Created %s (%s)\n' "$script_dir/$output" "$(du -h "$script_dir/$output" | cut -f1)"
