#!/usr/bin/env bash
set -e
if [[ -z "$FILES" ]]; then
  echo "No Vagrantfiles to test."
  exit 0
fi
get_host_arch() {
  uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/'
}
host_arch=$(get_host_arch)
declare -A box_json_cache
declare -A version_json_cache
done
if [[ -z "$PROVIDERS" ]]; then
  echo "Error: No Vagrant providers detected in environment variable PROVIDERS." >&2
  exit 1
fi
for file in $FILES; do
  dir=$(dirname "$file")
  echo "Testing Vagrantfile in $dir"
  box_name=$(grep -Eo 'config.vm.box\s*=\s*"[^"]+"' "$file" | head -1 | cut -d'"' -f2)
  box_version=$(grep -Eo 'config.vm.box_version\s*=\s*"[^"]+"' "$file" | head -1 | cut -d'"' -f2)
  if [[ -z "$box_name" ]]; then
    echo "Error: No box name found in $file. Aborting." >&2
    exit 1
  fi
  box_json=""
  version_json=""
  if [[ -n "$box_name" && "$box_name" == */* ]]; then
    cache_key="$box_name|$box_version"
    if [[ -z "${version_json_cache[$cache_key]}" ]]; then
      api_url="https://vagrantcloud.com/api/v2/vagrant/${box_name}"
      echo "Checking box metadata: $api_url"
      if ! box_json=$(curl -s "$api_url"); then
        echo "Error: curl failed to fetch $api_url" >&2
        exit 1
      fi
      if [[ -n "$box_version" ]]; then
        if ! version_json=$(echo "$box_json" | jq -c --arg ver "$box_version" '.versions[] | select(.version==$ver)'); then
          echo "Error: jq failed to parse version for $box_name $box_version" >&2
          exit 1
        fi
      else
        if ! version_json=$(echo "$box_json" | jq -c '.versions[0]'); then
          echo "Error: jq failed to parse latest version for $box_name" >&2
          exit 1
        fi
      fi
      box_json_cache[$box_name]="$box_json"
      version_json_cache[$cache_key]="$version_json"
    else
      version_json="${version_json_cache[$cache_key]}"
    fi
  fi
  for provider in $PROVIDERS; do
    echo "Testing provider: $provider"
    if [[ -n "$box_name" && "$box_name" == */* ]]; then
      if ! match=$(echo "$version_json" | jq -r --arg provider "$provider" --arg arch "$host_arch" '.providers[] | select(.name==$provider and .architecture==$arch) | .architecture'); then
        echo "Error: jq failed to check provider/arch for $box_name $provider $host_arch" >&2
        exit 1
      fi
      if [[ -z "$match" ]]; then
        echo "Skipping $box_name for provider $provider on $host_arch: not supported."
        continue
      fi
    fi
    if ! cd "$dir"; then
      echo "Error: Failed to cd to $dir" >&2
      exit 1
    fi
    vagrant up --provider=$provider || { echo "vagrant up failed for $provider in $dir"; exit 1; }
    vagrant status
    vagrant halt || { echo "vagrant halt failed for $provider in $dir"; exit 1; }
    vagrant destroy -f || { echo "vagrant destroy failed for $provider in $dir"; exit 1; }
    cd -
  done
done
