---
name: dotfiles
description: Manage this user's dotfiles repo (default location `~/dotfiles`) through its `bin/dot` CLI — GNU Stow underneath, layered common/profile/host. Use this skill whenever the user asks to add, move, back up, or "track" a config file in their dotfiles, whenever setting up or troubleshooting a machine (`dot bootstrap`, `dot doctor`, broken symlinks, "my config isn't syncing"), and — critically — right after you create, edit, or move ANY file under `$HOME` that plausibly belongs in dotfiles (shell config, git config, ssh config, editor/terminal config, Claude Code settings, Homebrew Brewfiles, skills), even if the user never says the word "dotfiles". Also trigger on mentions of GNU Stow, `machines.conf`, or paths under `layers/common`, `layers/profiles`, `layers/hosts`.
---

This user's dotfiles are managed by a small custom CLI, `bin/dot`, not by
editing the repo and symlinking by hand. Wherever a task touches a file under
`$HOME` that a dotfiles repo would plausibly own, prefer working through `dot`
over ad hoc `ln -s` or `cp` — it knows which layer owns each path and keeps
`git status` honest.

**You have no terminal.** Every `dot` command below runs through a
non-interactive shell tool. `dot doctor`'s untracked-file prompt (`[a]dopt
[i]gnore [s]kip`) only appears on a real tty, so you will never see it — you
always get its report-only listing instead. Where a workflow below would
normally rely on that prompt, it gives you the manual equivalent instead.

## Find the repo

`dot` is not on `$PATH` — invoke it by path. Try, in order:

1. Walk up from the current working directory looking for a directory that
   contains `bin/dot` — that's the repo root; invoke it as
   `<root>/bin/dot ...`.
2. Otherwise try `~/dotfiles/bin/dot` — the default clone location.
3. If neither exists, ask the user where their dotfiles repo lives rather
   than guessing further.

All commands below assume you've resolved this path; they're written as
`dot <subcommand>` for brevity.

## The layer model, briefly

Files live under `layers/{common,profiles/<name>,hosts/<hostname>}/home/`,
mirroring their path under `$HOME`. `dot apply` stows each layer into `$HOME`
in order — common, then the machine's profile, then its host overlay — so a
later layer's file wins if two would otherwise collide.

| The file is true for...  | Layer                                |
| ------------------------- | ------------------------------------- |
| every machine              | `layers/common/home/...`              |
| every machine on one profile | `layers/profiles/<profile>/home/...` |
| exactly one machine        | `layers/hosts/<hostname>/home/...`    |

Profile names: `ls layers/profiles`. This machine's profile and active
layers: `dot info`.

**Two layers must never claim the same path** — stow can't merge two files
onto one target. Before adding a file, check whether its relative path
already exists in another layer:

```sh
find layers -path '*/home/<relpath>'
```

If it does, don't add a second copy in a different layer to "override" it.
Instead let the tool's own include mechanism layer the values: git
`[include]`, ssh `Include`, zsh `conf.d/*.zsh` fragments, `dot brew`'s
common-then-profile Brewfile order. Add a *differently named* file that the
existing mechanism already loads later, and put the override there.

## Is a given `$HOME` file already tracked?

Check what it resolves to before deciding what to do:

```sh
readlink "$HOME/.zshrc"
find layers -path '*/home/.zshrc'    # does some layer own this relative path?
```

- **`readlink` resolves into the dotfiles repo** → already tracked and
  correctly linked. Edit it in place (through the symlink, or the repo file
  directly — same inode); the change is live immediately and shows up as an
  ordinary `git diff` in the repo. No further `dot` command needed.
- **`readlink` finds nothing (it's a real file), and `find layers -path`
  finds a match** → **detached**: this path is tracked, but the live file has
  become disconnected from its symlink (typically a tool that saves via
  write-temp-then-rename, which replaces the symlink with a plain file).
  `dot doctor` also reports this as `detached`. See the "detached file"
  workflow below before touching it — reconnecting it can discard local
  content if you're not careful.
- **`readlink` finds nothing, and `find layers -path` finds nothing either**
  → genuinely new. See "adding a new file" below.
- **`readlink` resolves to a real path, but not inside the dotfiles repo** →
  something else manages this symlink (an app, another tool); leave it alone
  unless the user asked you to take it over.
- **Exception:** `~/.claude/settings.json` is *generated*, not stowed, so it
  is never a symlink even when fully tracked. See "Claude Code settings"
  below.

## Workflows

**Adding a file that doesn't exist under `$HOME` yet.** Create it directly
inside the right layer's `home/` (mirroring its `$HOME` path), then run `dot
apply` (or `dot check` first for a dry run) to link it in.

**Bringing an existing, untracked `$HOME` file into the repo.** This is the
case where `readlink` found nothing and `find layers -path` found nothing —
the path genuinely isn't tracked anywhere yet. There is no `dot` subcommand
that does this for you without a terminal, so do it by hand:

1. Decide the layer (see the table above).
2. `mv "$HOME/<relpath>" "<root>/layers/<layer>/home/<relpath>"`
3. `dot apply` to symlink it back into place.
4. Confirm git will actually track it:
   `git -C <root> check-ignore -q layers/<layer>/home/<relpath> && echo "gitignored — add an exception" || echo "tracked"`

**A tracked file has gone detached** (real file, no symlink, but a layer
already owns the path — see the check above). `dot adopt` reconnects it, but
it does so by **backing up the live file and replacing it with the repo's
version** — it does not merge the two. Before running it:

1. Diff the live file against the repo's copy
   (`diff "$HOME/<relpath>" "<root>/layers/<layer>/home/<relpath>"`).
2. If the live file has changes worth keeping, merge them into the repo copy
   *first* (edit the repo file directly, or `cp` the live file over it), then
   `dot apply` — a plain restow now succeeds since the repo file already has
   the wanted content.
3. Only run `dot adopt` directly (skipping step 2) if the live file's
   drift is *not* worth keeping — it moves the live file into
   `backups/<timestamp>/` and relinks, so nothing is destroyed outright, but
   the change stops being live until someone goes and looks in `backups/`.

**You (the agent) just created, edited, or moved a file under `$HOME`.**
Before calling the task done:

1. Run the `readlink` / `find layers -path` check above.
2. If it's already a repo symlink, nothing further is needed — the edit
   already landed in git.
3. If you created a real file fresh, move it into the correct layer's
   `home/` yourself and run `dot apply` (the "adding a file" workflow above)
   — don't leave a duplicate real file sitting next to what should become a
   symlink.
4. Run `dot doctor` once at the end of a batch of `$HOME` changes. It's
   report-only for you (no tty), but it's the one command that surfaces
   drift and untracked files you didn't cause deliberately, so you can
   flag them to the user or fix them with the workflows above.

**Claude Code settings specifically.** `~/.claude/settings.json` is
*generated*, not stowed — it's merged from `layers/*/claude/settings.json` by
`bin/merge-claude-settings` because Claude Code owns that one file and has no
include mechanism. If it changed (a model/theme toggle, a new permission),
run `dot claude apply` (or plain `dot apply`, which includes it) to fold the
drift into the *host* layer. Never edit `layers/*/claude/settings.json` by
hand to chase a UI-driven change — apply does that automatically. To promote
a host-layer setting to common because it's genuinely global: move the key
from `layers/hosts/<host>/claude/settings.json` into
`layers/common/claude/settings.json`, then run `dot claude apply` and confirm
`dot claude check` reports no drift.

**Setting up or troubleshooting a machine.** New machine: `dot bootstrap
[profile]`. Machine already registered but freshly cloned or drifted: `dot
apply`. Something under `$HOME` looks wrong: `dot doctor` for a full
diagnosis (bad links, unpulled 1Password keys, settings drift, untracked
files), then the workflows above to fix what it reports.

## Command reference

| Command                          | What it does                                                    |
| ---------------------------------- | ------------------------------------------------------------------ |
| `dot bootstrap [profile]`          | New machine, start to finish: deps, register, link, brew, doctor    |
| `dot info`                         | This machine's hostname, profile, and active layers                 |
| `dot check`                        | Dry run — print every link that would be made                       |
| `dot apply`                        | Link the layers and rebuild skill views (default action)            |
| `dot adopt`                        | Like `apply`, but backs up colliding real files at tracked paths first |
| `dot doctor`                       | Diagnose: bad links, unpulled keys, settings drift, untracked files (report-only without a tty) |
| `dot claude [check\|apply\|force\|adopt]` | Just the Claude Code settings merge; bare or `apply`/`adopt` fold drift into the host layer, `force` discards local drift, `check` reports only |
| `dot brew`                         | `brew bundle` the common Brewfile, then this profile's              |
| `dot keys`                         | Pull SSH public keys from 1Password into `~/.ssh`                    |
| `dot unlink`                       | Remove all links for this machine                                    |

## Hard rules

These come from the repo's own `CLAUDE.md` and hold regardless of which
project you're working in when you touch a dotfiles-managed path:

- Never commit tool state — session logs, caches, lockfiles, sqlite files. If
  something like this needs to exist under a stowed directory, add its glob
  as a new line in `layers/common/unmanaged.conf` rather than growing a
  `.gitignore` (this is what doctor's interactive `i` answer does for a
  human at a real terminal — you can do the same edit directly).
- Never hardcode an absolute home path (`/Users/name/...`) into a tracked
  file — use `~` or `$HOME`. Usernames differ across this user's machines.
- Never commit a generated skill-view symlink (anything under
  `~/.claude/skills`, `~/.config/agents/skills`, `~/.config/goose/skills`,
  `~/.codex/skills`) — those are rebuilt by `bin/link-skills` per machine and
  are gitignored on purpose.
- Stow always runs `--no-folding` inside `dot` — don't invoke `stow` directly
  with different flags; doing so can point a whole directory at the repo
  instead of just its tracked files.

## Common mistakes

- **Running `dot adopt` on a detached file without checking for local
  drift first.** It replaces the live file with the repo's version and backs
  up the old one — content not yet in the repo copy has to be recovered from
  `backups/<timestamp>/` by hand. Diff first.
- **Assuming `dot doctor`'s untracked scan finds everything.** It scans one
  level into every ancestor directory of any already-tracked file — so a new
  file dropped into `~/.config/newapp/` is caught even though nothing at
  `~/.config/newapp` itself is tracked, as long as *some* other file under
  `~/.config/...` is. What it can't catch is a brand-new top-level path with
  no tracked file anywhere in its ancestor chain (e.g. a first-ever
  `~/.foorc`) — that needs to be placed into a layer manually.
