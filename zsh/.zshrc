export PATH=/Users/allen.leviefnf.com/bin:$PATH


source "/opt/homebrew/opt/spaceship/spaceship.zsh"


# initialize autocompletion
autoload -U compinit && compinit


# history setup
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data


# # autocompletion using arrow keys (based on history)
# bindkey '\e[A' history-search-backward
# bindkey '\e[B' history-search-forward


# never beep
setopt NO_BEEP


# setup zplug
export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "momo-lab/zsh-abbrev-alias"

if ! zplug check; then
    zplug install
fi

zplug load

# set up abbreviations
alias c!="code ~/.zshrc"
alias r!="source ~/.zshrc"
alias wks!="cd ~/werk"

abbrev-alias -g ga="git add"
abbrev-alias -g gb="git branch"
abbrev-alias -g gc="git commit"
abbrev-alias -g gk="git checkout"
abbrev-alias -g gs="git status -sb"

abbrev-alias -g dc="docker compose"

abbrev-alias -g tower="gittower"

abbrev-alias -g tf="terraform"

abbrev-alias -g k="kubectl"
abbrev-alias -g kctx="kubectx"
abbrev-alias -g kns="kubens"

export GPG_TTY=$(tty)
