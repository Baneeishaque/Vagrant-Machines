#!/usr/bin/env bash
if ! command -v jq >/dev/null 2>&1; then
  sudo apt-get update && sudo apt-get install -y jq
else
  echo "jq already installed"
fi
