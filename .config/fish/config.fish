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

status --is-interactive; and source (rbenv init -|psub)

eval (hub alias -s)
thefuck --alias | source
