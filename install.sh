#!/usr/bin/env bash
# install.sh — symlink the dotfiles into place.
#
# Idempotent. Backs up anything it would overwrite to <target>.bak-<timestamp>.
# Run from the repo root:  ./install.sh
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "backup: $dst -> $dst.bak-$STAMP"
    mv "$dst" "$dst.bak-$STAMP"
  fi
  ln -sfn "$src" "$dst"
  echo "link:   $dst -> $src"
}

# Hyprland
link "$REPO/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
link "$REPO/hypr/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
link "$REPO/hypr/scripts"       "$HOME/.config/hypr/scripts"

# tmux
link "$REPO/tmux/tmux.conf" "$HOME/.tmux.conf"

# Git commit-sound hook (standalone variant) via global template
mkdir -p "$HOME/.config/git/template/hooks"
cp "$REPO/git/hooks/post-commit-standalone" "$HOME/.config/git/template/hooks/post-commit"
chmod +x "$HOME/.config/git/template/hooks/post-commit"
git config --global init.templateDir "$HOME/.config/git/template"
echo "git:    commit-sound hook installed to template dir"

echo
echo "Done. Next:"
echo "  - cp hypr/personal.conf.example ~/.config/hypr/personal.conf  (optional)"
echo "  - install tmux plugins: prefix + I  (after cloning tpm)"
echo "  - reload Hyprland: hyprctl reload"
