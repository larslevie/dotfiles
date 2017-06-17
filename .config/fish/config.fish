alias c! "atom $HOME/.config/fish"
alias r! "source $HOME/.config/fish/config.fish"

# Specially configured git command for dotfiles
alias cfg "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Configure GPG Agent
set -e SSH_AUTH_SOCK
set -gx SSH_AUTH_SOCK $HOME/.gnupg/S.gpg-agent.ssh
# set -gx GPG_TTY (tty)

# Dev-related Shortcuts
abbr ga "git add"
abbr gb "git branch"
abbr gc "git commit"
abbr go "git checkout"
abbr gs "git status -sb"
