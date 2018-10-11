function setup
  abbr c! "code $HOME/.config"
  abbr r! "source $HOME/.config/fish/config.fish"

  abbr wks cd $HOME/werk

  abbr ga git add
  abbr gb git branch
  abbr gc git commit
  abbr gf git fetch
  abbr gm git merge
  abbr gk git checkout
  abbr gs git status -sb

  abbr dc docker-compose
  abbr tc triton-compose
  abbr td triton-docker
  abbr te triton-env

  abbr kc kubectl
  abbr kcc kubectl --context
  abbr kcs kubectl --context stg
  abbr kcp kubectl --context prd

  abbr hms helm --kube-context stg
  abbr hmp helm --kube-context prd
  abbr hmc helm --kube-context

  abbr va vault auth -method github

  abbr tf terraform
end
