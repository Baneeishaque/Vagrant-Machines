#!/usr/bin/env bash
# Usage: get_supported_providers.sh <box_name> <box_version> <host_arch>
set -e
box_name="$1"
box_version="$2"
host_arch="$3"
if [[ -z "$box_name" ]]; then
  echo "Error: box_name required" >&2
  exit 1
fi

# Install jq if missing (Linux: apt, macOS: brew)
if ! command -v jq >/dev/null 2>&1; then
  if [[ "$(uname)" == "Darwin" ]]; then
    brew install jq || { echo "Error: Failed to install jq (brew)." >&2; exit 1; }
  else
    sudo apt-get update && sudo apt-get install -y jq || { echo "Error: Failed to install jq (apt)." >&2; exit 1; }
  fi
fi

api_url="https://vagrantcloud.com/api/v2/vagrant/${box_name}"
box_json=$(curl -s "$api_url" | tr -d '\n\r')
if [[ -n "$box_version" ]]; then
  version_json=$(echo "$box_json" | jq -c --arg ver "$box_version" '.versions[] | select(.version==$ver)')
else
  version_json=$(echo "$box_json" | jq -c '.versions[0]')
fi
if [[ -z "$version_json" ]]; then
  echo "Error: No version found for $box_name $box_version" >&2
  exit 1
fi
providers=$(echo "$version_json" | jq -r --arg arch "$host_arch" '.providers[] | select(.architecture==$arch) | .name' | xargs)
if [[ -z "$providers" ]]; then
  echo "Error: No supported providers for $box_name $box_version on $host_arch" >&2
  exit 1
fi
echo "$providers"
