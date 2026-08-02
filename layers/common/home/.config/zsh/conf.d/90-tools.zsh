# Tool init that must run after PATH is final.
command -v pyenv >/dev/null && eval "$(pyenv init -)"

if [[ -f $HOMEBREW_PREFIX/share/google-cloud-sdk/path.zsh.inc ]]; then
  . "$HOMEBREW_PREFIX/share/google-cloud-sdk/path.zsh.inc"
  . "$HOMEBREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"
fi

[[ -f $XDG_CONFIG_HOME/.p10k.zsh ]] && . "$XDG_CONFIG_HOME/.p10k.zsh"

command -v fzf >/dev/null && eval "$(fzf --zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd zsh)"
