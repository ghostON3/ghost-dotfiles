#!/usr/bin/env bash
set -euo pipefail

marker="$HOME/.local/state/ghost-backup/last-success"
max_age_hours="${GHOST_BACKUP_MAX_AGE_HOURS:-36}"
[[ -r "$marker" ]] || { echo "backup freshness: no successful backup marker" >&2; exit 1; }
last="$(<"$marker")"
now="$(date -u +%s)"
age_hours=$(( (now - last) / 3600 ))
(( age_hours <= max_age_hours )) || {
  echo "backup freshness: stale (${age_hours}h > ${max_age_hours}h)" >&2
  exit 1
}
echo "backup freshness: ok (${age_hours}h)"
