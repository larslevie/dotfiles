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

zinit snippet OMZP::git
zinit snippet OMZP::command-not-found
zinit snippet OMZP::dotenv
zinit snippet OMZP::direnv
zinit snippet OMZP::docker
zinit snippet OMZP::docker-compose
