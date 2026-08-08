# `brew shellenv` spawns brew, which is a bash script. On Zscaler-managed
# machines a single subprocess at shell start measured ~10s, so its output is
# cached and only regenerated when the brew binary changes.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [[ -x $_brew ]] || continue
  _cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-init/brew-shellenv.zsh"
  if [[ ! -s $_cache || $_brew -nt $_cache ]]; then
    mkdir -p "${_cache:h}"
    "$_brew" shellenv > "$_cache.tmp" 2>/dev/null && mv "$_cache.tmp" "$_cache"
  fi
  [[ -s $_cache ]] && source "$_cache"
  break
done
unset _brew _cache

[[ -f $HOME/.orbstack/shell/init.zsh ]] && . "$HOME/.orbstack/shell/init.zsh" 2>/dev/null

export HOMEBREW_BUNDLE_FILE="$XDG_CONFIG_HOME/homebrew/Brewfile"
