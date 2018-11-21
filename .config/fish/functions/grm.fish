function grm
  git checkout master
  git pull --rebase
  git checkout -
  git rebase master
end
