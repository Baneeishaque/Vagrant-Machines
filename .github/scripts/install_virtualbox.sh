#!/usr/bin/env bash
set +e
sudo apt-get update
if ! sudo apt-get install -y virtualbox; then
  echo "Error: VirtualBox install failed or not supported." >&2
  exit 1
fi
set -e
if command -v vboxmanage >/dev/null 2>&1; then
  echo "VirtualBox available"
else
  echo "Error: VirtualBox not available after install." >&2
  exit 1
fi
