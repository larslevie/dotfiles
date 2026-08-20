ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d $ZINIT_HOME ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Powerlevel10k loads eagerly — it *is* the prompt, so deferring it defeats the
# point. Everything else loads in turbo (`wait lucid`), i.e. just after the
# first prompt paints.
#
# Loading these synchronously cost ~26s of shell startup: ~16s across the nine
# oh-my-zsh snippets and ~10s in a single zsh-abbr job-queue call. None of it is
# needed before you can type.
zinit ice depth=1; zinit light romkatv/powerlevel10k

# compinit already ran in 40-completion.zsh; only the queued compdefs need
# replaying once the completion plugins are in.
zinit wait lucid for \
  atinit'zicdreplay' \
      zsh-users/zsh-syntax-highlighting \
  atload'_zsh_autosuggest_start' \
      zsh-users/zsh-autosuggestions \
  blockf \
      zsh-users/zsh-completions \
      Aloxaf/fzf-tab \
      olets/zsh-abbr

export ZSH_DOTENV_FILE=$XDG_CONFIG_HOME/env
export ZSH_DOTENV_PROMPT=false

# Load a snippet only when the tool backing it exists. Several OMZ plugins
# print a warning on every shell start otherwise, and a machine is expected to
# be missing tools before `dot brew` runs, or on purpose.
snippet_if() { command -v "$1" >/dev/null && zinit wait lucid for "$2"; }

zinit wait lucid for \
  OMZP::command-not-found \
  OMZP::dotenv

# OMZP::git's `gco` alias loads in turbo, after the `gco` function in
# 70-functions.zsh — the alias wins and shadows it. Unalias once the plugin
# lands so the function (worktree-aware) takes over again.
zinit wait lucid atload'unalias gco 2>/dev/null' for \
  OMZP::git

snippet_if direnv OMZP::direnv
snippet_if docker OMZP::docker
snippet_if docker OMZP::docker-compose
