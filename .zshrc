eval "$(starship init zsh)"

# dotenv config
export ZSH_DOTENV_FILE=$HOME/.config/env
export ZSH_DOTENV_PROMPT=false


# Homebrew autocomplete
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi


source ~/.config/zsh/zplug


bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line


# ZSH config options
# set history size
export HISTSIZE=10000
# save history after logout
export SAVEHIST=10000
# append into history file
setopt INC_APPEND_HISTORY
# save only one command if 2 common are same and consistent
setopt HIST_IGNORE_DUPS
# add timestamp for each entry
setopt EXTENDED_HISTORY


# Abbreviations config
alias c!="code ~/.zshrc"
alias r!="source ~/.zshrc"
alias wks="cd $HOME/werk"
alias config="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

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

abbrev-alias -g tower="gittower"

abbrev-alias -g tf="terraform"
abbrev-alias -g tf11="/usr/local/opt/terraform@0.11/bin/terraform"

abbrev-alias -g kctx="kubectx"
abbrev-alias -g kns="kubens"

abbrev-alias -g ecr-login="aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 558529356944.dkr.ecr.us-east-1.amazonaws.com"


# GPG Config
export SSH_AUTH_SOCK=$HOME/.gnupg/S.gpg-agent.ssh
export GPG_TTY=$(tty)
gpgconf --launch gpg-agent


# Add krew to PATH
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"


# fpath+=~/.zfunc


# thefuck config
eval $(thefuck --alias)


# NVM Config
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion


# Terraform config
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache" # share Terraform plugin installs across statefiles
complete -o nospace -C /Users/larslevie/bin/terraform terraform # install autocomplete


# Configure pyenv and pyenv-virtualenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi


# rbenv config
eval "$(rbenv init - zsh)"


# direnv config
eval "$(direnv hook zsh)"


# Homebrew options
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_AUTO_UPDATE=1


# Spaceship prompt config
export SPACESHIP_KUBECTL_SHOW=false
export SPACESHIP_KUBECTL_VERSION_SHOW=false


# . /usr/local/etc/profile.d/z.sh


export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"


# tfswitch has trouble writing to its default bin (/usr/local/bin/), use $HOME/bin
export PATH="$HOME/bin:$PATH"


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/mc mc
export PATH="/opt/homebrew/opt/kubernetes-cli@1.22/bin:$PATH"
