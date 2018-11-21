function ktoken
  set -l context (kubectl config current-context 2>/dev/null)
  set -l secret (kubectl --context $context -n kube-system get secrets | grep kube-admin | awk '{print $1}')
  set -l token (kubectl --context $context -n kube-system get secret $secret -o json | jq -r .data.token | base64 --decode)

  echo $token | pbcopy
  echo $token
end