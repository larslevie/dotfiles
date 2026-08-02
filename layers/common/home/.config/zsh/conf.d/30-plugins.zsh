ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d $ZINIT_HOME ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

zinit ice depth=1; zinit light romkatv/powerlevel10k

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light olets/zsh-abbr

export ZSH_DOTENV_FILE=$XDG_CONFIG_HOME/env
export ZSH_DOTENV_PROMPT=false

# Load a snippet only when the tool backing it exists. Several OMZ plugins
# print a warning on every shell start otherwise, and a machine is expected to
# be missing tools before `dot brew` runs, or on purpose.
snippet_if() { command -v "$1" >/dev/null && zinit snippet "$2"; }

zinit snippet OMZP::git
zinit snippet OMZP::command-not-found
zinit snippet OMZP::dotenv
snippet_if direnv OMZP::direnv
snippet_if docker OMZP::docker
snippet_if docker OMZP::docker-compose
