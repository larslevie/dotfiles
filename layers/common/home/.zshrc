# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Loader only — real config lives in ~/.config/zsh/conf.d/*.zsh, sourced in
# filename order. Fragments are numbered because order matters here: fpath must
# be final before the deferred compinit runs, and the tool init at the end
# depends on PATH being complete.
for _f in "$ZDOTDIR_CONF"/conf.d/*.zsh(N); do . "$_f"; done
unset _f

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
