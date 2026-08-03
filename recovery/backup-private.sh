#!/usr/bin/env bash
# Back up private workstation state to an explicitly mounted local destination.
set -euo pipefail

mode="dry-run"
[[ "${1:-}" == "--apply" ]] && mode="apply"
destination="${GHOST_PRIVATE_BACKUP_DEST:-}"
[[ -n "$destination" ]] || {
  echo "set GHOST_PRIVATE_BACKUP_DEST to an encrypted/local backup directory" >&2
  exit 64
}
[[ -d "$destination" ]] || { echo "backup destination does not exist: $destination" >&2; exit 66; }
rsync_command="${RSYNC_COMMAND:-rsync}"
command -v "$rsync_command" >/dev/null || { echo "missing dependency: $rsync_command" >&2; exit 69; }

paths=(
  "$HOME/.ssh"
  "$HOME/.gnupg"
  "$HOME/.gitconfig"
  "$HOME/.config/ghost-private"
  "$HOME/.config/ghost-operator"
)

operator_config="${GHOST_OPERATOR_CONFIG:-$HOME/.config/ghost-operator/config.env}"
if [[ -r "$operator_config" ]]; then
  # shellcheck disable=SC1090
  source "$operator_config"
  while IFS= read -r variable; do
    value="${!variable:-}"
    [[ -n "$value" ]] && paths+=("$value")
  done < <(compgen -A variable | grep -E '^(CLAUDE|CODEX)_PROFILE_')
fi

args=(-a --relative --human-readable)
[[ "$mode" == "dry-run" ]] && args+=(--dry-run --itemize-changes)
for path in "${paths[@]}"; do
  [[ -e "$path" ]] || continue
  relative="${path#"$HOME"/}"
  "$rsync_command" "${args[@]}" "$HOME/./$relative" "$destination/"
done

if [[ "$mode" == "apply" ]]; then
  state_dir="$HOME/.local/state/ghost-backup"
  mkdir -p "$state_dir"
  date -u +%s > "$state_dir/last-success"
  echo "backup complete: $destination"
else
  echo "backup dry-run complete; rerun with --apply to write"
fi
