#! /usr/bin/env sh

if [ "$1" == "-chsh" ]; then
  sudo bash -c "echo /usr/local/bin/fish >> /etc/shells"
  sudo chsh -s /usr/local/bin/fish lars
  curl -L https://get.oh-my.fish | fish
  setup
  fisher
fi
