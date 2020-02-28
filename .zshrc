export ZSH_DOTENV_FILE=$HOME/.config/env

source ~/.config/zsh/zplug

alias c!="code ~/.zshrc"
alias r!="source ~/.zshrc"
alias wks="cd $HOME/werk"
alias config="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line

#set history size
export HISTSIZE=10000
#save history after logout
export SAVEHIST=10000
#append into history file
setopt INC_APPEND_HISTORY
#save only one command if 2 common are same and consistent
setopt HIST_IGNORE_DUPS
#add timestamp for each entry
setopt EXTENDED_HISTORY

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

abbrev-alias -g kctx="kubectx"
abbrev-alias -g kns="kubens"

export SSH_AUTH_SOCK=$HOME/.gnupg/S.gpg-agent.ssh
export GPG_TTY=$(tty)
gpgconf --launch gpg-agent

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:/usr/local/opt/python/libexec/bin:$PATH"


# # eval "$(hub alias -s)"
eval $(thefuck --alias)

export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

# Configure pyenv and pyenv-virtualenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

eval "$(pyenv virtualenv-init -)"

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

eval "$(rbenv init - zsh)"
eval "$(direnv hook zsh)"
