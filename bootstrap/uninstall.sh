#!/usr/bin/env bash
# Remove only links owned by this checkout. Never deletes user-owned files.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

remove_owned_link() {
  local target="$1" expected="$2"
  if [[ ! -L "$target" ]]; then
    echo "keep: $target (not a symlink)"
    return
  fi
  local actual
  actual="$(readlink -f "$target")"
  if [[ "$actual" != "$(readlink -f "$expected")" ]]; then
    echo "keep: $target (owned by another source)"
    return
  fi
  rm "$target"
  echo "removed: $target"
}

remove_owned_link "$HOME/.config/hypr/hyprland.conf" "$ROOT/hypr/hyprland.conf"
remove_owned_link "$HOME/.config/hypr/hyprlock.conf" "$ROOT/hypr/hyprlock.conf"
remove_owned_link "$HOME/.config/hypr/scripts" "$ROOT/hypr/scripts"
remove_owned_link "$HOME/.tmux.conf" "$ROOT/tmux/tmux.conf"
remove_owned_link "$HOME/.zshrc" "$ROOT/shell/zshrc"
remove_owned_link "$HOME/.config/kitty/kitty.conf" "$ROOT/kitty/kitty.conf"
remove_owned_link "$HOME/.config/kitty/theme.conf" "$ROOT/kitty/theme.conf"
remove_owned_link "$HOME/.config/rofi/config.rasi" "$ROOT/rofi/config.rasi"
remove_owned_link "$HOME/.config/git/ghost-dotfiles.conf" "$ROOT/git/config"
remove_owned_link "$HOME/.local/bin/spawn-agent-session" "$ROOT/operator/bin/spawn-agent-session"
remove_owned_link "$HOME/.local/bin/new-agent-worktree" "$ROOT/operator/bin/new-agent-worktree"
remove_owned_link "$HOME/.config/ghost-dotfiles/agent-slots.zsh" "$ROOT/shell/agent-slots.zsh"

echo "User-owned config and timestamped backups were preserved."
