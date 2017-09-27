function setup
  abbr c! "atom $HOME/.config"
  abbr r! "source $HOME/.config/fish/config.fish"

  abbr wks cd $HOME/workspace

  abbr ga git add
  abbr gb git branch
  abbr gc git commit -m
  abbr gf git fetch
  abbr go git checkout
  abbr gs git status -sb

  abbr dc docker-compose

  abbr kc kubectl
  abbr kcc kubectl --context
  abbr kcpx kubectl --context prd proxy -p 8003
  abbr kcsx kubectl --context stg proxy -p 8023

  abbr va vault auth -method github
end
