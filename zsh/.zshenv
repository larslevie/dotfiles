export XDG_CONFIG_HOME="$HOME/.config"
export HOMEBREW_BUNDLE_FILE="$XDG_CONFIG_HOME/Brewfile"

# Use the 1Password SSH agent instead of the built-in one
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

. "$HOME/.cargo/env"
