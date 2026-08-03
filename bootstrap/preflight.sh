#!/usr/bin/env bash
# Fail early when the host cannot safely consume this workstation profile.
set -euo pipefail

[[ -r /etc/os-release ]] || { echo "cannot identify operating system" >&2; exit 1; }
# shellcheck disable=SC1091
source /etc/os-release
[[ "${ID:-}" == "arch" || "${ID_LIKE:-}" == *arch* ]] || {
  echo "unsupported distribution: ${PRETTY_NAME:-unknown}; this profile targets Arch Linux" >&2
  exit 1
}
command -v pacman >/dev/null || { echo "pacman is required" >&2; exit 1; }
command -v git >/dev/null || { echo "git is required before bootstrap" >&2; exit 1; }

available_kib="$(df -Pk "$HOME" | awk 'NR == 2 { print $4 }')"
minimum_kib=$((8 * 1024 * 1024))
(( available_kib >= minimum_kib )) || {
  echo "at least 8 GiB free space is required for the base workstation" >&2
  exit 1
}

echo "preflight: ${PRETTY_NAME:-Arch Linux}, $((available_kib / 1024 / 1024)) GiB free"
