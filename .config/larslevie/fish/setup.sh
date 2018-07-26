#! /usr/bin/env sh

if [ "$1" == "-chsh" ]; then
  sudo bash -c "echo /usr/local/bin/fish >> /etc/shells"
  sudo chsh -s /usr/local/bin/fish $(whoami)

  if ! [ -d "$HOME/.config/fisherman" ]; then
    curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs https://git.io/fisher
  fi

  fisher
fi
