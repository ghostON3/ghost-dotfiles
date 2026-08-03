# Fresh Arch machine runbook

This is the canonical recovery order. Public configuration comes first;
credentials are restored only after the machine passes its base checks.

## 1. Minimal prerequisites

From a newly installed Arch system, install Git and clone the repository:

```sh
sudo pacman -S --needed git
git clone https://github.com/ghostON3/ghost-dotfiles.git
cd ghost-dotfiles
```

## 2. Preview

```sh
./bootstrap.sh --dry-run
```

The default profiles are `desktop,developer,operator`. Add voice explicitly:

```sh
./bootstrap.sh --dry-run --profiles desktop,developer,operator,voice
```

Review the package list and every proposed link. Dry-run is deliberately the
default: cloning a repository is not consent to mutate a machine.

## 3. Apply the public workstation

```sh
./bootstrap.sh --apply --profiles desktop,developer,operator,voice
```

This installs missing official Arch packages, links public configuration,
initializes the user-owned operator profile map, installs generalized user
timers and configures the global Git template hook.

The AUR list in `bootstrap/packages.aur.txt` is informational. Review and
install those packages through your chosen AUR workflow; bootstrap never runs
unreviewed PKGBUILDs or installs an AUR helper.

## 4. Map local provider profiles

Edit:

```text
~/.config/ghost-operator/config.env
```

Map Claude and Codex slot names to their provider-owned directories. Authenticate
with each provider's own CLI. Never paste tokens into this repository.

## 5. Restore private authority

Mount the encrypted/local backup and preview restoration:

```sh
export GHOST_PRIVATE_BACKUP_DEST=/run/media/$USER/encrypted/ghost-workstation
./recovery/restore-private.sh
./recovery/restore-private.sh --apply
```

The restore preserves displaced files under
`~/.local/state/ghost-restore-displaced`.

## 6. Hardware calibration

Review before starting Hyprland:

- monitor connector names and workspace assignment;
- DDC/CI bus numbers;
- keyboard layouts;
- audio source/sink selection;
- GPU driver and display environment;
- optional bindings in `~/.config/hypr/personal.conf`.

Hardware values are not auto-detected into tracked files because connector and
bus identifiers are machine facts, not portable defaults.

## 7. Accept the machine

```sh
./bootstrap/doctor.sh --strict
./tests/bootstrap-smoke.sh
systemctl --user list-timers
```

Then install tmux plugins (`prefix + I`), restart the graphical session and
exercise one session for each configured provider.

## 8. Roll back public links

```sh
./bootstrap/uninstall.sh
```

Uninstall removes only symlinks that resolve into this checkout. It never
deletes user-owned files, private configuration, provider state or timestamped
backups.
