# Added by Homebrew installation
eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Configure dotenv plugin
export ZSH_DOTENV_FILE=$HOME/.config/env
export ZSH_DOTENV_PROMPT=false
