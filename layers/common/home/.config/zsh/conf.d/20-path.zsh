# Prepend if the directory exists, keeping PATH free of dead entries.
_prepend_path() { [[ -d $1 ]] && path=("$1" $path); }

_prepend_path "$HOME/.local/bin"
_prepend_path "$HOME/bin"
_prepend_path "$HOME/go/bin"
_prepend_path "${KREW_ROOT:-$HOME/.krew}/bin"
_prepend_path "${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
_prepend_path "$HOMEBREW_PREFIX/opt/rustup/bin"
_prepend_path "$HOMEBREW_PREFIX/opt/libpq/bin"
_prepend_path "$HOMEBREW_PREFIX/opt/cyrus-sasl/sbin"
_prepend_path "$HOMEBREW_PREFIX/opt/postgresql@15/bin"

export PNPM_HOME="$HOME/Library/pnpm"
_prepend_path "$PNPM_HOME/bin"

export PYENV_ROOT="$HOME/.pyenv"
_prepend_path "$PYENV_ROOT/bin"

unfunction _prepend_path
typeset -U path   # dedupe, keeping first occurrence
