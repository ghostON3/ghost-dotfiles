# Start separately authenticated provider profiles in the current directory.
# Credentials remain in provider-owned directories and are never sourced.

_ghost_operator_config="${GHOST_OPERATOR_CONFIG:-$HOME/.config/ghost-operator/config.env}"
[[ -r "$_ghost_operator_config" ]] && source "$_ghost_operator_config"

_ghost_profile_dir() {
  local provider="$1" profile="$2" fallback="$3"
  local key="${provider}_PROFILE_${(U)profile}"
  print -r -- "${(P)key:-$fallback}"
}

cc-here() {
  local profile="${1:-default}"
  shift 2>/dev/null || true
  local suffix=""
  [[ "$profile" == "default" ]] || suffix="-$profile"
  local config_dir="$(_ghost_profile_dir CLAUDE "$profile" "${CLAUDE_PROFILE_ROOT:-$HOME/.claude}${suffix}")"
  if [[ ! -d "$config_dir" ]]; then
    print -u2 -r -- "Claude profile not found: $config_dir"
    return 66
  fi
  print -r -- "open: claude profile=$profile cwd=$PWD"
  CLAUDE_CONFIG_DIR="$config_dir" "${CLAUDE_COMMAND:-claude}" "$@"
}

cc1h() { cc-here 1 "$@"; }
cc2h() { cc-here 2 "$@"; }
cc3h() { cc-here 3 "$@"; }
cc4h() { cc-here 4 "$@"; }

codex-here() {
  local profile="${1:-default}"
  shift 2>/dev/null || true
  local suffix=""
  [[ "$profile" == "default" ]] || suffix="-$profile"
  local config_dir="$(_ghost_profile_dir CODEX "$profile" "${CODEX_PROFILE_ROOT:-$HOME/.codex}${suffix}")"
  if [[ ! -d "$config_dir" ]]; then
    print -u2 -r -- "Codex profile not found: $config_dir"
    return 66
  fi
  print -r -- "open: codex profile=$profile cwd=$PWD"
  CODEX_HOME="$config_dir" "${CODEX_COMMAND:-codex}" "$@"
}

cx1h() { codex-here 1 "$@"; }
cx2h() { codex-here 2 "$@"; }
cx3h() { codex-here 3 "$@"; }

antigravity-here() {
  local slot="${1:-default}"
  shift 2>/dev/null || true
  print -r -- "open: antigravity slot=$slot cwd=$PWD"
  if [[ "$slot" == "default" ]]; then
    "${ANTIGRAVITY_COMMAND:-agy}" "$@"
  else
    "${ANTIGRAVITY_COMMAND:-agy}" "$slot" "$@"
  fi
}

agy1h() { antigravity-here 1 "$@"; }
agy2h() { antigravity-here 2 "$@"; }

# The *h functions above take over the current terminal, so one directory holds
# one agent per profile. The *n functions below open an ADDITIONAL agent in the
# current directory, so N agents can work the same repo concurrently (mind the
# shared git index — give committing lanes their own worktree).
#
# Session naming is not re-derived here: spawn-agent-session is the single owner
# of unique session names, and it already defaults its workdir to $PWD.
#
#   cd ~/projects/somerepo && cc4n && cc4n     # two independent Claude agents
#   cc1n --model opus                          # provider args pass through
agent-here-new() {
  local provider="$1" profile="${2:-default}"
  shift 2 2>/dev/null || shift $#
  local spawn="${GHOST_SPAWN_AGENT_SESSION:-$HOME/.local/bin/spawn-agent-session}"
  [[ -x "$spawn" ]] || spawn="spawn-agent-session"
  "$spawn" "$provider" "$profile" "$PWD" "$@"
}

cc1n() { agent-here-new claude 1 "$@"; }
cc2n() { agent-here-new claude 2 "$@"; }
cc3n() { agent-here-new claude 3 "$@"; }
cc4n() { agent-here-new claude 4 "$@"; }

cx1n() { agent-here-new codex 1 "$@"; }
cx2n() { agent-here-new codex 2 "$@"; }
cx3n() { agent-here-new codex 3 "$@"; }

agy1n() { agent-here-new antigravity 1 "$@"; }
agy2n() { agent-here-new antigravity 2 "$@"; }
