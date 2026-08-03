#!/usr/bin/env bash
# Read-only workstation capability report. Makes no package or config changes.
set -uo pipefail

strict=0
[[ "${1:-}" == "--strict" ]] && strict=1

ok=0
warn=0
fail=0

pass() { printf '  [ok]   %s\n' "$1"; ok=$((ok + 1)); }
note() { printf '  [warn] %s\n' "$1"; warn=$((warn + 1)); }
miss() { printf '  [miss] %s\n' "$1"; fail=$((fail + 1)); }

check_command() {
  local command_name="$1" level="$2" purpose="$3"
  if command -v "$command_name" >/dev/null 2>&1; then
    pass "$command_name — $purpose"
  elif [[ "$level" == "core" ]]; then
    miss "$command_name — $purpose"
  else
    note "$command_name — $purpose (optional)"
  fi
}

check_link() {
  local path="$1" label="$2"
  if [[ -L "$path" ]]; then
    pass "$label is managed"
  elif [[ -e "$path" ]]; then
    note "$label exists but is not managed by this checkout"
  else
    miss "$label is not installed"
  fi
}

printf 'ghost workstation doctor\n\n'

printf 'Host\n'
if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  pass "${PRETTY_NAME:-Linux}"
else
  note 'cannot identify distribution'
fi
[[ "${XDG_SESSION_TYPE:-}" == "wayland" ]] && pass 'Wayland session' || note 'not currently in a Wayland session'
[[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && pass 'Hyprland session' || note 'Hyprland is not currently active'

printf '\nCore commands\n'
check_command git core 'source control and worktrees'
check_command tmux core 'durable terminal sessions'
check_command kitty core 'detached agent terminals'
check_command jq core 'Hyprland JSON state and safe hook payloads'
check_command hyprctl core 'window/workspace control'
check_command wl-copy core 'Wayland clipboard integration'
check_command zsh core 'interactive operator shell'
check_command rsync core 'private backup and recovery'

printf '\nCapture and input\n'
check_command grim optional 'Wayland screenshots'
check_command slurp optional 'region selection'
check_command tesseract optional 'local OCR'
check_command wtype optional 'voice/OCR text injection'
check_command ddcutil optional 'external monitor brightness'
check_command playerctl optional 'media bindings'

printf '\nAgent providers\n'
check_command claude optional 'Claude Code seats'
check_command codex optional 'Codex seats'
check_command agy optional 'Antigravity slot wrapper'
check_command gh optional 'GitHub pull-request workflow'
check_command node optional 'JavaScript tooling runtime'
check_command pnpm optional 'workspace package manager'
check_command docker optional 'local container runtime'

printf '\nManaged configuration\n'
check_link "$HOME/.config/hypr/hyprland.conf" 'Hyprland config'
check_link "$HOME/.tmux.conf" 'tmux config'
check_link "$HOME/.zshrc" 'Zsh config'
check_link "$HOME/.config/kitty/kitty.conf" 'Kitty config'
check_link "$HOME/.config/rofi/config.rasi" 'Rofi config'
check_link "$HOME/.local/bin/spawn-agent-session" 'agent session launcher'
check_link "$HOME/.local/bin/new-agent-worktree" 'worktree launcher'

operator_config="${GHOST_OPERATOR_CONFIG:-$HOME/.config/ghost-operator/config.env}"
if [[ -r "$operator_config" ]]; then
  pass 'operator profile map exists'
else
  note 'operator profile map is not initialized'
fi

backup_marker="$HOME/.local/state/ghost-backup/last-success"
[[ -r "$backup_marker" ]] && pass 'private backup has a success marker' || note 'no private backup success marker yet'

printf '\nSummary: %d ok · %d warnings · %d missing core capabilities\n' "$ok" "$warn" "$fail"
if (( strict && fail > 0 )); then
  exit 1
fi
