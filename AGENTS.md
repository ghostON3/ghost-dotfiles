# ghost-dotfiles
<!-- CLAUDE.md is a symlink to this file; edit only AGENTS.md. -->

Dormant Arch Linux and Hyprland workstation configuration. The default branch is `main`.

## Layout
`hypr/`, `tmux/`, and `shell/` hold configuration. `bootstrap/` manages setup, `operator/` holds portable launchers, and `recovery/` holds backup and restore helpers.

## Commands
Preview setup with `./bootstrap.sh --dry-run`. On Arch, `./bootstrap.sh --apply` installs packages and applies the public configuration. Inspect the machine with `./bootstrap/doctor.sh --strict`.
Pass `./tests/bootstrap-smoke.sh` before landing installer changes.

## How a change lands
Use a branch and PR. The optional Git template hook plays a sound after a commit. Checks run locally.

## Rules
Keep personal overlays out of Git. Use `hypr/personal.conf.example` for shareable examples.

## More
[Fresh machine setup and rollback](docs/fresh-machine.md).
