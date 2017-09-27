# Load secrets
source $HOME/.config/env

set -gx TERM "xterm-256color"
set -gx EDITOR "atom -w"

set -gx theme_color_scheme terminal2

# Specially configured git command for dotfiles
alias cfg "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Configure GPG Agent
set -e SSH_AUTH_SOCK
set -gx SSH_AUTH_SOCK $HOME/.gnupg/S.gpg-agent.ssh
set -gx GPG_TTY (tty)

set -gx VAULT_ADDR "https://vault.campuslabs.io"
set -gx VAULT_AUTH_GITHUB_TOKEN $GITHUB_TOKEN
set -gx CAMPUS_LABS_VAULT_GITHUB_TOKEN $GITHUB_TOKEN

status --is-interactive; and source (rbenv init -|psub)
