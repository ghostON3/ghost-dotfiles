#!/usr/bin/env bash
# Install generalized user units. Dry-run by default.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mode="dry-run"
[[ "${1:-}" == "--apply" ]] && mode="apply"
units=(worktree-audit.service worktree-audit.timer backup-freshness.service backup-freshness.timer)

for unit in "${units[@]}"; do
  target="$HOME/.config/systemd/user/$unit"
  if [[ "$mode" == "apply" ]]; then
    mkdir -p "$(dirname "$target")"
    ln -sfn "$ROOT/services/$unit" "$target"
    echo "link: $target"
  else
    echo "would link: $target -> $ROOT/services/$unit"
  fi
done

if [[ "$mode" == "apply" ]]; then
  systemctl --user daemon-reload
  systemctl --user enable --now worktree-audit.timer backup-freshness.timer
else
  echo "would enable: worktree-audit.timer backup-freshness.timer"
fi
