function update
    sudo softwareupdate -i -a
    brew update
    brew upgrade --force --all
    brew cleanup
    npm install npm -g
    npm update -g
    mas upgrade
end
