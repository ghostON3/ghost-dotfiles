#!/usr/bin/env bash
# install.sh — symlink the dotfiles into place.
#
# Idempotent. Backs up anything it would overwrite to <target>.bak-<timestamp>.
# Run from the repo root:  ./install.sh
set -euo pipefail

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
elif [[ $# -gt 0 ]]; then
  echo "usage: ./install.sh [--dry-run]" >&2
  exit 64
fi

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$1" dst="$2"
  if (( DRY_RUN )); then
    echo "would link: $dst -> $src"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "backup: $dst -> $dst.bak-$STAMP"
    mv "$dst" "$dst.bak-$STAMP"
  fi
  ln -sfn "$src" "$dst"
  echo "link:   $dst -> $src"
}

copy_initial() {
  local src="$1" dst="$2"
  if (( DRY_RUN )); then
    if [ -e "$dst" ]; then
      echo "would keep: $dst (user-owned config)"
    else
      echo "would init: $dst <- $src"
    fi
    return
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ]; then
    echo "keep:   $dst (user-owned config)"
    return
  fi
  cp "$src" "$dst"
  echo "init:   $dst <- $src"
}

# Hyprland
link "$REPO/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
link "$REPO/hypr/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
link "$REPO/hypr/scripts"       "$HOME/.config/hypr/scripts"

# tmux
link "$REPO/tmux/tmux.conf" "$HOME/.tmux.conf"

# Shell and terminal/launcher surfaces
link "$REPO/shell/zshrc" "$HOME/.zshrc"
link "$REPO/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
link "$REPO/kitty/theme.conf" "$HOME/.config/kitty/theme.conf"
link "$REPO/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
link "$REPO/git/config" "$HOME/.config/git/ghost-dotfiles.conf"

# Agent/operator launchers. Credentials and CLI state remain in their native
# profile directories; only the reusable launch mechanics are linked here.
link "$REPO/operator/bin/spawn-agent-session" "$HOME/.local/bin/spawn-agent-session"
link "$REPO/operator/bin/new-agent-worktree" "$HOME/.local/bin/new-agent-worktree"
link "$REPO/operator/bin/worktree-audit" "$HOME/.local/bin/worktree-audit"
link "$REPO/recovery/backup-freshness.sh" "$HOME/.local/bin/backup-freshness"
link "$REPO/shell/agent-slots.zsh" "$HOME/.config/ghost-dotfiles/agent-slots.zsh"
copy_initial "$REPO/operator/config/defaults.env" "$HOME/.config/ghost-operator/config.env"

# Git commit-sound hook (standalone variant) via global template
if (( DRY_RUN )); then
  echo "would install: Git commit-sound template hook"
else
mkdir -p "$HOME/.config/git/template/hooks"
cp "$REPO/git/hooks/post-commit-standalone" "$HOME/.config/git/template/hooks/post-commit"
chmod +x "$HOME/.config/git/template/hooks/post-commit"
git config --global init.templateDir "$HOME/.config/git/template"
git config --global --replace-all include.path "$HOME/.config/git/ghost-dotfiles.conf" '^~/.config/git/ghost-dotfiles\.conf$'
echo "git:    commit-sound hook installed to template dir"
fi

echo
echo "Done. Next:"
echo "  - cp hypr/personal.conf.example ~/.config/hypr/personal.conf  (optional)"
echo "  - source ~/.config/ghost-dotfiles/agent-slots.zsh from ~/.zshrc"
echo "  - install tmux plugins: prefix + I  (after cloning tpm)"
echo "  - reload Hyprland: hyprctl reload"
echo "  - run ./bootstrap/doctor.sh for a read-only capability report"
