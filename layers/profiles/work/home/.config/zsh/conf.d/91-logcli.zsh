# logcli ships no completion file; generate once and refresh when the binary moves.
if command -v logcli >/dev/null; then
  _comp="$XDG_CACHE_HOME/logcli-completion.zsh"
  if [[ ! -f $_comp || $(command -v logcli) -nt $_comp ]]; then
    mkdir -p "$XDG_CACHE_HOME"
    logcli --completion-script-zsh > "$_comp" 2>/dev/null
  fi
  [[ -s $_comp ]] && . "$_comp"
  unset _comp
fi
