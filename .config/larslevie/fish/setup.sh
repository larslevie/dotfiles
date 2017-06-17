#! /usr/bin/env sh

if [ "$1" == "-chsh" ]; then
  sudo bash -c "echo /usr/local/bin/fish >> /etc/shells"
  sudo chsh -s /usr/local/bin/fish larslevie
  curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
  fisher
fi
