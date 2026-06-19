# Git hooks — sound on commit

Two flavours of "give me an audible cue when a commit lands":

### `post-commit-standalone` — zero dependencies
Picks whatever audio player exists (`paplay` / `pw-play` / `aplay` / `ffplay`)
and plays a short cue. Nothing to run, nothing to configure.

```sh
ELO_COMMIT_SOUND_DISABLE=1                      # mute for one shell
ELO_COMMIT_SOUND_FILE=~/sounds/ping.oga         # custom cue
```

### `post-commit` — event-driven
What I actually run. Instead of playing locally, it POSTs the commit
(`{repo, sha, branch, message, author, ts}`) to a local API, which fans the
event out to every connected surface (web, desktop, browser extension) and
each one plays a *procedural* cue. Fire-and-forget, fully env-overridable:

```sh
ELO_COMMIT_SOUND_URL=http://localhost:3000/git-commits
ELO_COMMIT_SOUND_TIMEOUT=1
ELO_COMMIT_SOUND_DISABLE=1
```

JSON is built with `jq` when present, with a quote/newline-safe shell fallback
when it isn't.

## Install globally (every repo)

Use a git template directory so the hook is copied into every `git init` /
`git clone`:

```sh
mkdir -p ~/.config/git/template/hooks
cp post-commit-standalone ~/.config/git/template/hooks/post-commit
chmod +x ~/.config/git/template/hooks/post-commit
git config --global init.templateDir ~/.config/git/template
# existing repos: re-run `git init` inside them to copy the hook in
```
