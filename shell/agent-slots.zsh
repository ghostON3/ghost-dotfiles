# Start a separately authenticated Claude Code profile in the current directory.
# Credentials remain in Claude's own config directories and are never sourced.

cc-here() {
  local profile="${1:-default}"
  shift 2>/dev/null || true
  local suffix=""
  [[ "$profile" == "default" ]] || suffix="-$profile"
  local config_dir="${CLAUDE_PROFILE_ROOT:-$HOME/.claude}${suffix}"
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
