export XDG_CONFIG_HOME="$HOME/.config"
export HOMEBREW_BUNDLE_FILE=$XDG_CONFIG_HOME/Brewfile

# Use the 1Password SSH agent instead of the built-in one
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

. "$HOME/.cargo/env"

export AWS_CA_BUNDLE=~/.config/witco/ca-bundle.pem
export CURL_CA_BUNDLE=~/.config/witco/ca-bundle.pem
export GIT_SSL_CAINFO=~/.config/witco/ca-bundle.pem
export NODE_EXTRA_CA_CERTS=~/.config/witco/ca-bundle.pem
export REQUESTS_CA_BUNDLE=~/.config/witco/ca-bundle.pem
export SSL_CERT_FILE=~/.config/witco/ca-bundle.pem
