#!/usr/bin/env bash
# Fresh-machine entry point. Dry-run is the default; --apply performs changes.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mode="dry-run"
profiles=(desktop developer operator)

usage() {
  cat <<'EOF'
usage: ./bootstrap.sh [--dry-run|--apply] [--profiles desktop,developer,operator,voice]

Dry-run is the default. --apply installs official Arch packages and links the
public configuration. Credentials and private overlays are never restored by
this command.
EOF
}

while (( $# )); do
  case "$1" in
    --dry-run) mode="dry-run" ;;
    --apply) mode="apply" ;;
    --profiles)
      shift
      IFS=',' read -r -a profiles <<< "${1:-}"
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 64 ;;
  esac
  shift
done

"$ROOT/bootstrap/preflight.sh"

package_args=(--profiles "$(IFS=,; echo "${profiles[*]}")")
if [[ "$mode" == "apply" ]]; then
  "$ROOT/bootstrap/install-packages.sh" --apply "${package_args[@]}"
  "$ROOT/install.sh"
  "$ROOT/bootstrap/install-services.sh" --apply
else
  "$ROOT/bootstrap/install-packages.sh" --dry-run "${package_args[@]}"
  "$ROOT/install.sh" --dry-run
  "$ROOT/bootstrap/install-services.sh" --dry-run
fi

echo
echo "Bootstrap $mode complete. Run: ./bootstrap/doctor.sh"
