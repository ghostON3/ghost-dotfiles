#!/usr/bin/env bash
# Resolve declarative profiles and optionally install missing official packages.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mode="dry-run"
profile_csv="desktop,developer,operator"

while (( $# )); do
  case "$1" in
    --apply) mode="apply" ;;
    --dry-run) mode="dry-run" ;;
    --profiles) shift; profile_csv="${1:-}" ;;
    *) echo "unknown argument: $1" >&2; exit 64 ;;
  esac
  shift
done

packages=()
IFS=',' read -r -a profiles <<< "$profile_csv"
for profile in "${profiles[@]}"; do
  manifest="$ROOT/bootstrap/profiles/$profile.packages"
  [[ -r "$manifest" ]] || { echo "unknown profile: $profile" >&2; exit 64; }
  while IFS= read -r package; do
    package="${package%%#*}"
    package="${package//[[:space:]]/}"
    [[ -n "$package" ]] && packages+=("$package")
  done < "$manifest"
done

mapfile -t packages < <(printf '%s\n' "${packages[@]}" | sort -u)
missing=()
for package in "${packages[@]}"; do
  pacman -Q "$package" >/dev/null 2>&1 || missing+=("$package")
done

if (( ${#missing[@]} == 0 )); then
  echo "packages: all selected profiles are installed"
  exit 0
fi

echo "packages: ${#missing[@]} missing for profiles [$profile_csv]"
printf '  %s\n' "${missing[@]}"
if [[ "$mode" == "apply" ]]; then
  sudo pacman -S --needed -- "${missing[@]}"
else
  printf 'dry-run: sudo pacman -S --needed --'
  printf ' %q' "${missing[@]}"
  printf '\n'
fi
