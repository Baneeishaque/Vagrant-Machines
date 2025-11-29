#!/usr/bin/env bash
set -e
sudo apt-get clean -yq
if compgen -G ".aptcache/*.deb" > /dev/null; then
  if ! sudo cp -l .aptcache/*.deb /var/cache/apt/archives; then
    echo "Error: Failed to restore cached .deb files to /var/cache/apt/archives" >&2
    exit 1
  fi
fi
