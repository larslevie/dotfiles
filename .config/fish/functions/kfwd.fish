function kfwd -a cmd namespace label local_port port
  set -l id (eval "$cmd get pod -n $namespace -l $label -o json | jq -r '.items[0].metadata.name'")
  echo Forwarding at http://localhost:$local_port
  eval "$cmd -n $namespace port-forward $id $local_port:$port"
end
