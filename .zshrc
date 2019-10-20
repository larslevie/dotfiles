source ~/.config/zsh/zplug

alias c!="code ~/.zshrc"
alias r!="source ~/.zshrc"
alias wks="cd $HOME/werk"
alias config="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"

abbrev-alias -g dc="docker-compose"
abbrev-alias -g k="kubectl"

abbrev-alias -g ga="git add"
abbrev-alias -g gb="git branch"
abbrev-alias -g gc="git commit"
abbrev-alias -g gf="git fetch"
abbrev-alias -g gm="git merge"
abbrev-alias -g gk="git checkout"
abbrev-alias -g gs="git status -sb"
abbrev-alias -g gr="git pull --rebase"

abbrev-alias -g tf="terraform"

export SSH_AUTH_SOCK=$HOME/.gnupg/S.gpg-agent.ssh
export GPG_TTY=$(tty)
gpgconf --launch gpg-agent
