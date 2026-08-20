export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

export ZDOTDIR_CONF="$XDG_CONFIG_HOME/zsh"

export VAULT_ADDR=https://vault.rg-infra.com

# 1Password SSH agent, only if this machine actually has it.
_op_sock="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
[[ -S $_op_sock ]] && export SSH_AUTH_SOCK="$_op_sock"
unset _op_sock

[[ -f $HOME/.cargo/env ]] && . "$HOME/.cargo/env"

# Profile/host env fragments. Kept in .zshenv (not .zshrc) so they apply to
# non-interactive shells too — CA bundles and proxies must be set for scripts.
for _f in "$ZDOTDIR_CONF"/env.d/*.zsh(N); do . "$_f"; done
unset _f
