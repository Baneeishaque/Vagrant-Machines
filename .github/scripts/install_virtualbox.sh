#!/usr/bin/env bash
set +e
sudo apt-get update
sudo apt-get install -y virtualbox || echo "VirtualBox install failed or not supported"
set -e
if command -v vboxmanage >/dev/null 2>&1; then
  echo "VirtualBox available"
else
  echo "VirtualBox not available"
fi
