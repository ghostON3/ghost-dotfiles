# Operator controls

These are the portable mechanics behind my local multi-agent workflow. I run
multiple Claude Code subscriptions, Codex profiles and Antigravity sessions at
the same time, but each process receives an explicit profile and working
directory. Authentication data stays in the provider's native config directory
and is never copied into this repository.

## Fresh session in the current checkout

```sh
spawn-agent-session claude 4 "$PWD"
spawn-agent-session codex default "$PWD"
spawn-agent-session antigravity 2 "$PWD"
```

Each invocation opens a detached Kitty window containing a uniquely named tmux
session. Concurrent sessions therefore do not collide even when they use the
same provider profile.

## Initial default configuration

`install.sh` copies `operator/config/defaults.env` to
`~/.config/ghost-operator/config.env` only when that file does not already
exist. The copy becomes user-owned: later repository updates never overwrite
local profile choices.

The defaults make all three providers visible immediately:

```sh
CLAUDE_PROFILE_1="$HOME/.claude-1"
CODEX_PROFILE_1="$HOME/.codex"
ANTIGRAVITY_COMMAND="agy"
```

Edit the local copy when profile directories use account-specific names. Do
not put tokens or credentials in it; it maps human slot names to provider-owned
directories.

Provider commands and fallback profile roots are also configurable:

```sh
export CLAUDE_PROFILE_ROOT="$HOME/.claude"
export CODEX_PROFILE_ROOT="$HOME/.codex"
export ANTIGRAVITY_COMMAND=agy
```

Without an explicit mapping, numbered profiles use a `-N` suffix
(`~/.claude-4`, `~/.codex-2`). The `default` profile uses the unsuffixed
directory.

## New branch + isolated worktree + session

```sh
new-agent-worktree claude 4 origin/main auth-hardening
```

This command:

1. refuses to run outside a Git repository;
2. fetches no remote state implicitly—the caller selects the base;
3. creates a conventional `work/<slug>` branch;
4. places the worktree under `$GHOST_WORKTREE_ROOT`;
5. falls back to `$GHOST_WORKTREE_FALLBACK_ROOT` when the preferred root is not
   writable or exceeds `$GHOST_WORKTREE_MAX_USED_PCT`;
6. starts the selected agent profile inside the new worktree.

Defaults:

```sh
GHOST_WORKTREE_ROOT=/data/worktrees
GHOST_WORKTREE_FALLBACK_ROOT=$HOME/worktrees
GHOST_WORKTREE_MAX_USED_PCT=94
```

The launcher deliberately does not commit, push, delete branches or clean old
worktrees. Those are lifecycle decisions, not session-start side effects.

## Current-directory shell shortcuts

Source `shell/agent-slots.zsh` from `.zshrc`. Dedicated commands are deliberately
visible instead of hidden behind a generic dispatcher:

| Provider | Current-directory shortcuts |
|---|---|
| Claude Code | `cc1h`, `cc2h`, `cc3h`, `cc4h` |
| Codex | `cx1h`, `cx2h`, `cx3h` |
| Antigravity | `agy1h`, `agy2h` |

The `h` means **here**: the CLI starts in the directory where the operator is
standing.

## Trust boundary

The launchers do not disable provider permission systems. On machines where a
fully trusted sandbox is intentionally configured, extra CLI arguments can be
passed explicitly by the operator. Unsafe flags are never a repository default.
