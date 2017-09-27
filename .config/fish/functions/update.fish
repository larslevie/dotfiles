function update
  sudo softwareupdate -i -a
  brew update
  brew upgrade --force
  brew cleanup
  npm install npm -g
  npm update -g
  apm update -c false
  mas upgrade
end
