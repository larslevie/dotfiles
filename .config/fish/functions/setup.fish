function setup
  abbr c! "atom $HOME/.config"
  abbr r! "source $HOME/.config/fish/config.fish"

  abbr wks cd $HOME/workspace

  abbr gf git fetch
  abbr gs git status -sb
  abbr gc git commit -m
  abbr ga git add
  abbr go git checkout
  abbr dc docker-compose
  abbr kc kubectl
end
