# CLAUDE.md

Guidance for Claude Code working in this repository.

## What This Is

Personal dotfiles. Static files placed by GNU Stow, layered per machine.
See `README.md` for the user-facing docs; this file covers the invariants that
are easy to break.

## Invariants

**Two layers must never claim the same path.** Stow cannot overlay two packages
onto one file. Merging is always done by the target tool's own include
mechanism (git `[include]`, ssh `Include`, zsh `conf.d/*.zsh`), never by stow.
If a profile needs to override a common value, add a *differently named* file
that loads later — do not duplicate the path.

**Stow always runs with `--no-folding`.** Directories under `$HOME` stay real;
only tracked files become symlinks. Dropping this flag makes stow point whole
directories at the repo, and every tool's runtime state starts landing in git.

**Never commit generated symlinks.** The skill views under `~/.claude/skills`,
`~/.config/agents/skills`, `~/.config/goose/skills`, and `~/.codex/skills` are
built by `bin/link-skills` and gitignored. Committing them encodes one
machine's layout and breaks every other machine.

**Claude settings are generated, not stowed.** `~/.claude/settings.json` is
merged from `layers/*/claude/settings.json` by `bin/merge-claude-settings`,
because Claude Code reads one user settings file and has no include mechanism.
Those sources live in `claude/`, not `home/.claude/` — putting one under `home/`
would make stow link it and defeat the merge. Editing the live file is fine;
`dot apply` folds the change into `layers/hosts/<host>/claude/settings.json`
automatically (the host layer, not common — app-driven changes like `model` or
`theme` are per-machine, not global). Promote a change to `common` by hand if
it really is one.

**Never commit tool state.** Session logs, caches, lockfiles, `hosts.yml`,
sqlite files, gcloud sentinels. If `.gitignore` starts growing again, something
is being tracked that shouldn't be. New tool state that lands inside a stowed
directory shows up in `dot doctor` as `untracked`; list it in that layer's
`unmanaged.conf` (same convention as `op-items.conf` — outside `home/`, one
glob per line) rather than growing `.gitignore`, since these paths were never
candidates for tracking in the first place.

**No absolute home paths.** Use `~` or `$HOME`. Machines differ:
`/Users/lars.levie` here, `/Users/larslevie` on another. Hardcoded paths are
what silently broke git signing and the k9s dump dir before.

## Layout

```
bin/dot           entry point: bootstrap | info | check | apply | adopt | doctor | brew | keys | unlink
bin/link-skills   rebuilds the generated skill views (idempotent)
bin/merge-claude-settings  merges layered Claude settings into ~/.claude/settings.json
machines.conf     hostname -> profile
layers/common/home/
layers/profiles/{work,personal}/home/
layers/hosts/<hostname>/home/
```

Load order is common → profile → host. Within zsh, fragments are numbered:
common uses 00–30 and 40–90, profiles use the gaps (35, 65, 91) so a profile
fragment can land between two common ones.

## Where things go

| Kind                                             | Layer               |
| ------------------------------------------------ | ------------------- |
| Editor, terminal, shell plumbing, skills          | `common`            |
| Witco/FNF: AWS SSO, kube, k9s, witctl, CA bundle  | `profiles/work`     |
| Personal gcloud, consumer apps                    | `profiles/personal` |
| Anything true of exactly one machine              | `hosts/<hostname>`  |

Anything touching `SSL_CERT_FILE` / `REQUESTS_CA_BUNDLE` must be guarded on the
bundle existing — exporting them unconditionally breaks curl and Python TLS on
machines without the corporate bundle.

## Verifying a change

There is no test suite. After editing:

```sh
./bin/dot check     # dry run, shows every link
./bin/dot apply
./bin/dot doctor    # bad links, unpulled keys, settings drift, untracked files
zsh -i -c 'echo ok' # shell still starts clean
```

For git changes, confirm identity resolves in both directions — inside `~/werk`
and outside it — with `git config --get user.email`.

## Secrets

1Password holds SSH keys; AWS uses SSO. Environment secrets are never written
to disk — `~/.config/zsh/secrets.d/*.env` holds `op://` pointers, and `opload`
(`conf.d/80-secrets.zsh`) resolves them into the current shell on demand. Any
layer may add a file there. Put a pointer in the layer that owns the secret,
not in `common`. `allowed_signers` is tracked deliberately. SSH public keys are not
tracked — `dot keys` (part of `dot bootstrap`) pulls them from 1Password per
each layer's `op-items.conf`; add an entry there for any new IdentityFile
instead of committing a `.pub`. Never commit private keys, tokens, or
credential files.
