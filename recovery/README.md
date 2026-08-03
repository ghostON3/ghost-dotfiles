# Private state and recovery

The public repository rebuilds software and configuration. It cannot recreate
provider sessions, SSH keys, Git signing identity or machine-private service
configuration. Those cross a separate, explicit recovery boundary.

`backup-private.sh` copies selected private state only to
`$GHOST_PRIVATE_BACKUP_DEST`, which must already exist. Point it at an encrypted
local or mounted backup you control. The script has no network destination and
is a dry-run unless `--apply` is passed.

```sh
export GHOST_PRIVATE_BACKUP_DEST=/run/media/$USER/encrypted/ghost-workstation
./recovery/backup-private.sh
./recovery/backup-private.sh --apply
```

On a fresh machine, bootstrap the public system first, mount the private backup,
then preview and apply restoration:

```sh
./bootstrap.sh --apply
./recovery/restore-private.sh
./recovery/restore-private.sh --apply
./bootstrap/doctor.sh --strict
```

Restoration uses rsync's backup mode and moves displaced destination files under
`~/.local/state/ghost-restore-displaced` rather than silently destroying them.

Never commit the backup directory, generated provider profiles, `.ssh`, `.gnupg`
or the real `~/.config/ghost-private` overlay.
