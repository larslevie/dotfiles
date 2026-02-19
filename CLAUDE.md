# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## What This Is

Personal dotfiles managed with GNU Stow. Three stow packages (`config`, `git`,
`zsh`) symlink into `$HOME`.

## Bootstrap

```sh
xcode-select --install
# install Homebrew
brew install stow
cd ~/dotfiles && stow -S config git zsh
brew bundle  # reads ~/.config/Brewfile via HOMEBREW_BUNDLE_FILE
```

## Stow Packages

| Package   | Contains                                           | Symlinks to |
| --------- | -------------------------------------------------- | ----------- |
| `zsh/`    | `.zshenv`, `.zprofile`, `.zshrc`                   | `~/`        |
| `git/`    | `.gitconfig`                                       | `~/`        |
| `config/` | `.claude/`, `.config/`, `.aws/`, `.kube/`, `.ssh/` | `~/`        |

After editing, re-stow with `stow -R <package>` from the repo root. Use `stow -D
<package>` to unlink.

SSH files are stowed individually (not as a directory) — private keys and
`known_hosts` are gitignored.

## Shell Stack

Zsh with Zinit plugin manager, Powerlevel10k prompt (rainbow), and these
plugins: `zsh-syntax-highlighting`, `zsh-autosuggestions`, `zsh-completions`,
`fzf-tab`, `zsh-abbr`.

Environment layers load in order: `.zshenv` (exports, PATH) → `.zprofile`
(Homebrew, pyenv, OrbStack) → `.zshrc` (plugins, aliases, tool inits).

## Key Aliases

- `r!` — reload zshrc
- `bu` — brew update/upgrade/cleanup
- `cat` → `bat`
- `cd` → `zoxide`

## Git Signing

Commits are GPG-signed via 1Password SSH agent (`op-ssh-sign`). Multiple GitHub
host aliases (`github-personal`, `github-cincpro`, `github-realgeeks`) use
per-host identity files defined in `.ssh/config`.

## Secrets

1Password injects secrets at runtime into `~/.config/env.secrets` (gitignored).
AWS uses SSO via `~/.aws/config`. Never commit private keys, tokens, or
credential files.

## No Tests

No test suite exists. Validate changes by re-stowing and opening a new shell.
