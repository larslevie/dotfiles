# Tool init that must run after PATH is final.
#
# Subprocesses are extraordinarily expensive on Zscaler-managed machines —
# spawning `bash` once measured 10s here. So nothing in this file may shell out
# on a normal start. Init that would normally come from `eval "$(tool init)"`
# is either reproduced natively in zsh or generated once and cached.

# pyenv. `pyenv init -` is avoided entirely: it shells out to bash purely to
# strip the shims dir from PATH (zsh's `typeset -U path` already does that),
# and its output ends in `pyenv rehash`, which rebuilds every shim. Run
# `pyenv rehash` by hand after installing a Python version or an entry point.
if (( $+commands[pyenv] )); then
  export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
  path=("$PYENV_ROOT/shims" $path)
  export PYENV_SHELL=zsh
  _pyenv_comp="${commands[pyenv]:A:h:h}/completions/pyenv.zsh"
  [[ -f $_pyenv_comp ]] && source "$_pyenv_comp"
  unset _pyenv_comp
  pyenv() {
    local command=${1:-}
    (( $# > 0 )) && shift
    case "$command" in
      rehash|shell) eval "$(command pyenv "sh-$command" "$@")" ;;
      *)            command pyenv "$command" "$@" ;;
    esac
  }
fi

# Generate once, re-use until the binary changes.
cached_eval() { # cached_eval <name> <command> [args...]
  local name=$1; shift
  local bin cache="$XDG_CACHE_HOME/zsh-init/$name.zsh"
  bin=${commands[$1]} || return 0
  [[ -n $bin ]] || return 0
  if [[ ! -s $cache || $bin -nt $cache ]]; then
    mkdir -p "${cache:h}"
    "$@" > "$cache.tmp" 2>/dev/null && mv "$cache.tmp" "$cache" || { rm -f "$cache.tmp"; return 0; }
  fi
  source "$cache"
}

cached_eval fzf    fzf --zsh
cached_eval zoxide zoxide init --cmd cd zsh

if [[ -f $HOMEBREW_PREFIX/share/google-cloud-sdk/path.zsh.inc ]]; then
  . "$HOMEBREW_PREFIX/share/google-cloud-sdk/path.zsh.inc"
  . "$HOMEBREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"
fi
