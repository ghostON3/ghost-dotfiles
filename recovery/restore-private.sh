#!/usr/bin/env bash
# Restore a local private backup. Dry-run by default; preserves overwritten files.
set -euo pipefail

mode="dry-run"
[[ "${1:-}" == "--apply" ]] && mode="apply"
source_dir="${GHOST_PRIVATE_BACKUP_DEST:-}"
[[ -d "$source_dir" ]] || { echo "set GHOST_PRIVATE_BACKUP_DEST to the restored backup root" >&2; exit 66; }
rsync_command="${RSYNC_COMMAND:-rsync}"
command -v "$rsync_command" >/dev/null || { echo "missing dependency: $rsync_command" >&2; exit 69; }

args=(-a --human-readable --backup --backup-dir="$HOME/.local/state/ghost-restore-displaced")
[[ "$mode" == "dry-run" ]] && args+=(--dry-run --itemize-changes)
"$rsync_command" "${args[@]}" "$source_dir/" "$HOME/"

echo "restore $mode complete; run bootstrap/doctor.sh before authenticating providers"
