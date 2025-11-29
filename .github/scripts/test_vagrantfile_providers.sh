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
      box_json=$(curl -s "$api_url")
      if [[ -n "$box_version" ]]; then
        version_json=$(echo "$box_json" | jq -c --arg ver "$box_version" '.versions[] | select(.version==$ver)')
      else
        version_json=$(echo "$box_json" | jq -c '.versions[0]')
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
      match=$(echo "$version_json" | jq -r --arg provider "$provider" --arg arch "$host_arch" '.providers[] | select(.name==$provider and .architecture==$arch) | .architecture')
      if [[ -z "$match" ]]; then
        echo "Skipping $box_name for provider $provider on $host_arch: not supported."
        continue
      fi
    fi
    cd "$dir"
    vagrant up --provider=$provider || { echo "vagrant up failed for $provider in $dir"; exit 1; }
    vagrant status
    vagrant halt || { echo "vagrant halt failed for $provider in $dir"; exit 1; }
    vagrant destroy -f || { echo "vagrant destroy failed for $provider in $dir"; exit 1; }
    cd -
  done
fi
done
