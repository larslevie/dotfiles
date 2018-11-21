function port-forward --description "port-forward"
  set -l options (fish_opt -r --short=c --long=kube-context)
  set options $options (fish_opt -r --short=n --long=namespace)
  set options $options (fish_opt -r --short=l --long=label)
  set options $options (fish_opt -r --short=y --long=port --long-only)
  set options $options (fish_opt -r --short=x --long=local-port --long-only)
  
  argparse --name port-forward $options -- $argv

  if test $argv
    set -l app $argv
  else
    echo "App name is required"
    return 1
  end

  set -l context_arg ""
  set -l namespace_arg ""
  set -l label_arg ""

  if set -q _flag_c
    set context_arg "--context $_flag_c"
  end

  if set -q _flag_n
    set namespace_arg "--namespace $_flag_n"
  end

  if set -q _flag_l
    set label_arg "-l $_flag_l"
  else
    set label_arg "-l 'app=$argv,release=$argv'"
  end

  if not test $_flag_port
    echo "--port is required"
    return 1
  end

  if not test $_flag_local_port
    echo "--local-port is required"
    return 1
  end

  set -l id (eval "kubectl $context_arg get pod $namespace_arg $label_arg -o json | jq -r '.items[0].metadata.name'")
  eval "kubectl $context_arg $namespace_arg port-forward $id $_flag_local_port:$_flag_port"
  echo Forwarding $argv at http://localhost:$_flag_local_port
end