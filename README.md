# dotfiles

Static files, GNU Stow for placement, layered per machine.

## Install on a new machine

```sh
git clone https://github.com/larslevie/dotfiles.git ~/dotfiles
~/dotfiles/bin/dot bootstrap work        # or: personal
```

That is the whole thing. `bootstrap` installs the Xcode Command Line Tools and
Homebrew if missing, installs stow, registers the machine in `machines.conf`,
backs up any colliding files, links every layer, rebuilds the skill views, runs
`brew bundle` for the common and profile Brewfiles, pulls SSH public keys from
1Password, and finishes with `doctor`. Omit the profile and it lists the
choices and asks.

It is safe to re-run: registration is idempotent and linking is a restow.

Only these need you afterwards, because they are interactive logins:

1. 1Password → sign in → Settings → Developer → enable the SSH agent and
   "Integrate with 1Password CLI" (git signing, every `github-*` host alias,
   and `dot keys` depend on it). If you signed in after `bootstrap` ran,
   follow up with `dot keys`.
2. `gh auth login`
3. `aws sso login --profile witco-login` on work machines

Clone over HTTPS, as above — the SSH host aliases don't exist until the config
is linked, and the 1Password agent isn't running yet on a fresh machine.

## Commands

| Command             | What it does                                      |
| ------------------- | ------------------------------------------------- |
| `dot bootstrap [p]` | Clone to done: deps, register, link, brew, doctor |
| `dot info`   | Show this machine's hostname, profile, and active layers |
| `dot check`  | Dry run — print every link that would be made            |
| `dot apply`  | Link the layers and rebuild the skill views              |
| `dot adopt`  | Like `apply`, but backs up colliding real files first    |
| `dot doctor` | Health check: bad links, unpulled keys, drift, untracked files |
| `dot brew`   | `brew bundle` the common Brewfile, then this profile's   |
| `dot keys`   | Pull SSH public keys from 1Password into `~/.ssh`         |
| `dot unlink` | Remove all links for this machine                        |

## Layout

```
layers/
  common/home/            every machine
  profiles/work/home/     work machines
  profiles/personal/home/ personal machines
  hosts/<hostname>/home/  one machine (optional escape hatch)
```

`machines.conf` maps a hostname to a profile. Each layer's `home/` is stowed
into `$HOME`, in order: common, then profile, then host.

Layers never contain the same path twice. Where settings need to *merge* rather
than sit side by side, each tool's own include mechanism does the work:

| Tool | Merge point                                                     |
| ---- | --------------------------------------------------------------- |
| git  | `~/.gitconfig` includes `common` → `profile` → `host` → `local`  |
| zsh  | `~/.config/zsh/conf.d/*.zsh` sourced in filename order           |
| ssh  | `~/.ssh/config` includes `~/.ssh/config.d/*.conf`                |
| brew | `dot brew` runs the common Brewfile, then `Brewfile.<profile>`   |

Numeric prefixes let a profile fragment land *between* two common ones, so
layering is not limited to appending.

## Adding a machine

`dot bootstrap <profile>` registers it for you. If it needs anything unique
beyond its profile, add `layers/hosts/<hostname>/home/...` — for git that means
`.config/git/host.gitconfig`, which is included last and wins — then
`./bin/dot apply`.

## Git identity

Identity is chosen by **directory**, not by machine, so a personal repo cloned
onto a work laptop still commits with the personal address:

- default → `larslevie@gmail.com`
- under `~/werk/` → `lars.levie@fnf.com`, signed with the Witco key

Anonymous `github.com` URLs are rewritten onto 1Password-backed host aliases.
Longest prefix wins, so `cincpro/` and `RealGeeks/` go to their work aliases and
everything else goes to `github-personal`.

## Claude settings

Claude Code reads exactly one user settings file and has no include mechanism,
so this is the one place layering can't be delegated to the tool. The layers are
merged into `~/.claude/settings.json` by `dot apply`:

```
layers/common/claude/settings.json              base
layers/profiles/<profile>/claude/settings.json  profile delta
layers/hosts/<host>/claude/settings.json        host delta
```

Objects merge deeply, lists concatenate and de-duplicate (what allow-lists
want), scalars replace. To replace a list outright instead of extending it, name
the key with a trailing `!` in the overriding layer.

Note these sit in `claude/`, *not* `home/.claude/` — they are inputs to the
merge, not files stow places.

Because the result is generated it can't also be a symlink into the repo, and
Claude Code rewrites `settings.json` when you change options in the app
(model, theme, voice, notifications...). So drift is expected, not exceptional:
`dot apply` folds it into `layers/hosts/<host>/claude/settings.json` — the host
layer, not common, so one machine's UI state doesn't apply to every other
machine — and the fold shows up as an ordinary uncommitted diff in `git
status`. Promote a change to common by hand if it's really global.

| Command             | What it does                                        |
| ------------------- | ---------------------------------------------------- |
| `dot claude check`  | Report whether the live file has drifted              |
| `dot claude apply`  | Fold drift into the host layer and write (default)    |
| `dot claude force`  | Discard local changes and regenerate                  |

`dot claude adopt` is still accepted, as an alias for the default `apply`.

## Why directories stay real

Stow runs with `--no-folding`, so directories under `$HOME` are created as real
directories and only tracked *files* become symlinks. Without it, stow points
`~/.claude` at the repo and every session log, cache, and sqlite file a tool
writes lands inside it — which is what the old ~100-line `.gitignore` was
fighting. Files you author still edit in place and show up in `git diff`
immediately.

The cost: a *new* file a tool writes into a stowed directory (a skill manager
installing a skill, a new config file dropped in place) is invisible to both
`git status` and stow. `dot doctor` closes that gap by scanning one level into
every directory a tracked file lives in and reporting what the repo doesn't
know about as `untracked` — never descending into an unknown directory, so
`~/.claude/projects` is one line, not thousands. Answering the prompt with
`a` moves the file into the layer that already owns its directory and relinks
it; `i` records it in that layer's `unmanaged.conf` (same convention as
`op-items.conf`: one glob per line, outside `home/` so stow never touches it)
so it isn't asked about again. Non-interactive runs (`dot doctor --report`, or
any non-tty, which is what `bootstrap` uses) just list them.

Two more hazards `doctor` catches: a tool that saves by writing a temp file and
renaming over the target replaces the symlink with a real file, reported as
`detached`; and a symlink that resolves *somewhere*, but not into this repo's
copy — a stale clone, an old dotfiles manager — reported as `wronglink`. Both
fail `doctor`'s exit code; `untracked` does not, since it's a queue of things
to triage, not evidence `$HOME` disagrees with the repo. `dot adopt` re-links
detached files.

## Skills

`~/.agents/skills` is the single canonical store. Everything else —
`~/.claude/skills`, `~/.config/agents/skills`, `~/.config/goose/skills`,
`~/.codex/skills` — is a **generated view**, rebuilt by `bin/link-skills` and
never committed.

Those views used to be 59 committed symlinks, 15 of them broken: 8 with the
wrong `../` depth and 7 pointing at skills renamed upstream. Committed links
encode one machine's layout, so every other machine's skill manager fought
them. Only hand-written skills are tracked now; manager-installed ones are
reproducible from `.agents/.skill-lock.json`.

## Secrets

Private keys, tokens, and `~/.config/env.secrets` are never committed. AWS
uses SSO.

SSH public keys aren't tracked either — they're pulled from 1Password by
`dot keys` (part of `bootstrap`, safe to re-run standalone). Each layer that
needs one lists it in an `op-items.conf` file, outside `home/` so stow never
touches it:

```
# <path relative to $HOME>   <op:// reference>
.ssh/github_personal.pub     op://Private/GitHub - Personal/public key
```

Private key material never touches disk — matching identities in 1Password's
SSH agent sign on the public key's behalf. Add a new SSH identity by adding a
line here, not by committing a `.pub` file.
