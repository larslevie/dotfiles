set -x -g TERM "xterm-256color"
set -gx EDITOR "atom -w"

fisher omf/theme-bobthefish
set -g theme_color_scheme terminal2

alias c! "atom $HOME/.config/fish"
alias r! "source $HOME/.config/fish/config.fish"

# Specially configured git command for dotfiles
alias cfg "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Configure GPG Agent
set -e SSH_AUTH_SOCK
set -gx SSH_AUTH_SOCK $HOME/.gnupg/S.gpg-agent.ssh
set -gx GPG_TTY (tty)
set -gx PINENTRY_USER_DATA "USE_CURSES=1"

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

source ~/.iterm2_shell_integration.fish
