#!/usr/bin/env bash
sudo apt-get clean -yq
if compgen -G ".aptcache/*.deb" > /dev/null; then
  sudo cp -l .aptcache/*.deb /var/cache/apt/archives
fi
