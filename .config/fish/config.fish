# Load secrets
source $HOME/.config/env

set -gx TERM "xterm-256color"
set -gx theme_color_scheme terminal2

# Specially configured git command for dotfiles
alias cfg "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Configure GPG Agent
set -gx SSH_AUTH_SOCK $HOME/.gnupg/S.gpg-agent.ssh
set -gx GPG_TTY (tty)
eval (gpgconf --launch gpg-agent)

set -gx VAULT_ADDR "https://vault.dev.campuslabs.io"
set -gx VAULT_AUTH_GITHUB_TOKEN $GITHUB_TOKEN
set -gx CAMPUS_LABS_VAULT_GITHUB_TOKEN $GITHUB_TOKEN

status --is-interactive; and source (rbenv init -|psub)

eval (hub alias -s)
