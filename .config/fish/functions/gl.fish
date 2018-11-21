function gl
  set -l sha (git rev-parse HEAD)
  echo "$sha" | tr -d "\n" | pbcopy
  echo "$sha"
end
