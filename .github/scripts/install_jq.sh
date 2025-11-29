#!/usr/bin/env bash
if ! command -v jq >/dev/null 2>&1; then
  sudo apt-get update && sudo apt-get install -y jq || { echo "Error: Failed to install jq." >&2; exit 1; }
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq not found after install." >&2
  exit 1
else
  echo "jq already installed"
fi
