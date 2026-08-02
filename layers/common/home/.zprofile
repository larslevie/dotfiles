# Homebrew — prefix differs between Apple Silicon and Intel.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [[ -x $_brew ]] && { eval "$("$_brew" shellenv)"; break; }
done
unset _brew

[[ -f $HOME/.orbstack/shell/init.zsh ]] && . "$HOME/.orbstack/shell/init.zsh" 2>/dev/null

export HOMEBREW_BUNDLE_FILE="$XDG_CONFIG_HOME/homebrew/Brewfile"
