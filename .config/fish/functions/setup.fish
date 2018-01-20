function setup
  abbr c! "atom $HOME/.config"
  abbr r! "source $HOME/.config/fish/config.fish"

  abbr wks cd $HOME/workspace

  abbr ga git add
  abbr gb git branch
  abbr gc git commit
  abbr gf git fetch
  abbr gm git merge
  abbr go git checkout
  abbr gs git status -sb

  abbr dc docker-compose
  abbr tc triton-compose
  abbr td triton-docker
  abbr te triton-env

  abbr kc kubectl
  abbr kcc kubectl --context
  abbr kcs kubectl --context stg
  abbr kcp kubectl --context prd

  abbr va vault auth -method github
end
