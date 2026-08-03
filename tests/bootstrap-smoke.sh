#!/usr/bin/env bash
# Isolated-home acceptance test for install/update/uninstall ownership behavior.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_HOME="$(mktemp -d /tmp/ghost-dotfiles-smoke.XXXXXX)"
trap 'rm -rf "$TEST_HOME"' EXIT

HOME="$TEST_HOME" "$ROOT/install.sh" >/dev/null

required_links=(
  .zshrc
  .tmux.conf
  .config/hypr/hyprland.conf
  .config/kitty/kitty.conf
  .config/rofi/config.rasi
  .local/bin/spawn-agent-session
  .local/bin/new-agent-worktree
  .local/bin/worktree-audit
)
for relative in "${required_links[@]}"; do
  [[ -L "$TEST_HOME/$relative" ]] || { echo "missing managed link: $relative" >&2; exit 1; }
done

operator_config="$TEST_HOME/.config/ghost-operator/config.env"
[[ -f "$operator_config" && ! -L "$operator_config" ]]
printf '\n# local-user-edit\n' >> "$operator_config"
HOME="$TEST_HOME" "$ROOT/install.sh" >/dev/null
tail -1 "$operator_config" | grep -qx '# local-user-edit'

HOME="$TEST_HOME" "$ROOT/bootstrap/uninstall.sh" >/dev/null
for relative in "${required_links[@]}"; do
  [[ ! -e "$TEST_HOME/$relative" ]] || { echo "owned link survived uninstall: $relative" >&2; exit 1; }
done
[[ -f "$operator_config" ]]

echo "bootstrap smoke: install, update preservation and ownership-safe uninstall passed"
