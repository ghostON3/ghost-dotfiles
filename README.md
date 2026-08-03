# ghost-dotfiles

My Arch Linux + Hyprland workstation and agentic development environment, as
code. Dual-4K, Wayland-native, keyboard-and-mouse driven, tuned through daily
use — not a screenshot rice and not a generic starter kit.

Every binding here earns its place. The interesting parts aren't the colors;
they're the small behavioral fixes that a tiling WM doesn't give you for free.

```
hypr/    Hyprland + hyprlock + helper scripts
tmux/    tmux: vi-mode, clipboard, fzf session picker, voice input
git/     audible feedback on every commit
operator/ portable launchers for isolated worktrees and concurrent agent seats
shell/   current-directory shortcuts for separately authenticated CLI profiles
install.sh   symlink everything into place (idempotent, backs up originals)
```

## The parts I'd point a reviewer at

**Monitor-aware workspaces.** On a dual-head setup, vanilla Hyprland workspace
keys are global — `SUPER+3` yanks you to whichever monitor owns workspace 3.
`hypr/scripts/switch-workspace-current-monitor.sh` remaps `1-10` to *the
monitor your focus is on*, so the number keys mean the same thing on either
screen. Same idea for moving windows. Each monitor owns a disjoint workspace
range (1-5 left, 6-10 right) and the scripts do the translation.

**Scratchpad with memory.** `hypr/scripts/scratchpad.sh` stashes a window to a
special workspace and remembers where it came from, so un-stashing returns it
to its *origin* workspace — not wherever you happen to be standing. State is a
flat `address workspace` file in `/tmp`; no daemon.

**Focus-or-launch toggle.** `SUPER+C` focuses VS Code if it's running, launches
it if not, and — pressed again while already focused — bounces back to the
window you came from. One key, three behaviors, via a tiny state file.

**Golden-ratio pointer.** `sensitivity = -0.6180` (φ − 1, negated). Petty?
Maybe. It feels right and I can defend every magic number in here.

**Screenshots that always hit the clipboard.** Area/full/window all `wl-copy`;
full and window also archive to `~/Pictures/Screenshots`. `grim` + `slurp`,
no GUI tool in the path.

**tmux that gets out of the way.** `Ctrl-A` prefix, vi-style panes and copy,
splits inherit the current path, whole-pane capture straight to the Wayland
clipboard (`M-a`), an fzf session picker in a popup (`prefix f`), and a
push-to-talk whisper binding that types a transcription into the focused pane.
Catppuccin status bar, resurrect + continuum so a reboot restores the session.

**Sound on commit.** A `post-commit` hook that gives audible feedback the
moment a commit lands — a standalone zero-dependency variant (plays a cue via
whatever audio player exists) and the event-driven one I actually run (POSTs
the commit to a local API that fans it out to every open surface). See
[`git/README.md`](git/README.md).

**One gesture, one isolated lane.** Mouse side buttons can open separately
authenticated Claude Code seats in fresh tmux sessions. The worktree launcher
goes further: it creates a branch from an explicit base, places the worktree on
a dedicated worktree volume (with a configurable fallback), and starts the
chosen CLI profile inside it. See [`operator/`](operator/README.md).

**Several tools, explicit identities.** Claude Code, Codex and Antigravity can
run at the same time without pretending they share one account or one state
directory. The public scripts describe profile selection and process isolation;
credentials and provider session data never enter this repository.

## Install

```sh
git clone https://github.com/ghostON3/ghost-dotfiles
cd ghost-dotfiles
./install.sh
```

`install.sh` symlinks configs into `~/.config`, backs up anything it would
clobber, and installs the commit-sound hook into your global git template.

### Dependencies

Core: `hyprland hyprlock kitty rofi swww wl-clipboard cliphist grim slurp
wlsunset jq`.
Optional (for specific binds): `wlogout playerctl wireplumber ddcutil dolphin
google-chrome`.
tmux: `tmux` + [tpm](https://github.com/tmux-plugins/tpm) (`prefix + I` to
fetch plugins) + `wl-clipboard`.

## Personal overlay

Provider credentials, subscription state, machine inventory and usage history
stay private. The reusable mechanics — agent-seat launchers, worktree isolation,
mouse bindings and shell functions — are public. `hypr/hyprland.conf` sources an
optional `personal.conf` that is gitignored; `hypr/personal.conf.example` wires
the portable commands without embedding account data.

## Hardware it was tuned on

2× 3840×2160 @ 60 (DP-1 / DP-2), US/SK keyboard layouts, external-monitor
brightness over DDC/CI. Monitor names and `--bus` numbers are mine — change
them to yours.

---

MIT. Take what's useful.
