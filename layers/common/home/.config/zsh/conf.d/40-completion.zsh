fpath=("$HOME/.zsh/completions" "$XDG_DATA_HOME/zsh/site-functions" $fpath)

# compinit runs here rather than being deferred into turbo, so that compdef is
# defined before any fragment sources a generated completion file. -C skips the
# security audit of fpath (which stats every entry); the dump is rebuilt at most
# once a day, when the glob below finds it older than 24h.
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
if [[ -n ${_zcompdump}(#qN.mh+24) ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi
unset _zcompdump

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
