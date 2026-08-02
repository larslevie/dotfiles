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

**Never commit tool state.** Session logs, caches, lockfiles, `hosts.yml`,
sqlite files, gcloud sentinels. If `.gitignore` starts growing again, something
is being tracked that shouldn't be.

**No absolute home paths.** Use `~` or `$HOME`. Machines differ:
`/Users/lars.levie` here, `/Users/larslevie` on another. Hardcoded paths are
what silently broke git signing and the k9s dump dir before.

## Layout

```
bin/dot           entry point: bootstrap | info | check | apply | adopt | doctor | brew | unlink
bin/link-skills   rebuilds the generated skill views (idempotent)
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
./bin/dot doctor    # detached / missing / dangling links
zsh -i -c 'echo ok' # shell still starts clean
```

For git changes, confirm identity resolves in both directions — inside `~/werk`
and outside it — with `git config --get user.email`.

## Secrets

1Password holds SSH keys and injects `~/.config/env.secrets` at runtime; AWS
uses SSO. Public keys and `allowed_signers` are tracked deliberately. Never
commit private keys, tokens, or credential files.
