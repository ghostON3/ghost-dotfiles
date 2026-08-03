# Machine-private overlay contract

The private overlay may provide:

- `shell.zsh` — account-specific aliases and local service endpoints;
- `hypr.conf` — bindings to private binaries and hardware-specific commands;
- `environment.d/*.conf` — non-secret machine feature flags;
- systemd drop-ins for local paths.

It must not redefine public safety invariants or make the public bootstrap depend
on one account. Secrets remain in provider credential stores, a password manager
or an encrypted backup—not in example files.
