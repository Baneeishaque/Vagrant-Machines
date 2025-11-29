#!/usr/bin/env bash
# Usage: vagrant_test_matrix.sh <vagrantfile> <host_arch>
# 1. Parse box name/version from Vagrantfile
# 2. Get supported providers for box/arch
# 3. For each provider: install tools/plugins, run vagrant up/halt/destroy
set -e
vagrantfile="$1"
host_arch="$2"
if [[ -z "$vagrantfile" || -z "$host_arch" ]]; then
  echo "Usage: $0 <vagrantfile> <host_arch>" >&2
  exit 1
fi
box_name=$(grep -Eo 'config.vm.box\s*=\s*"[^"]+"' "$vagrantfile" | head -1 | cut -d'"' -f2)
box_version=$(grep -Eo 'config.vm.box_version\s*=\s*"[^"]+"' "$vagrantfile" | head -1 | cut -d'"' -f2)
if [[ -z "$box_name" ]]; then
  echo "Error: No box name found in $vagrantfile" >&2
  exit 1
fi
providers=$(.github/scripts/get_supported_providers.sh "$box_name" "$box_version" "$host_arch")
for provider in $providers; do
  echo "Installing tools/plugins for provider: $provider"
  .github/scripts/install_provider_tools.sh "$provider"
  dir=$(dirname "$vagrantfile")
  cd "$dir"
  echo "Running Vagrant for provider: $provider in $dir"
  vagrant up --provider=$provider || { echo "vagrant up failed for $provider in $dir"; exit 1; }
  vagrant status
  vagrant halt || { echo "vagrant halt failed for $provider in $dir"; exit 1; }
  vagrant destroy -f || { echo "vagrant destroy failed for $provider in $dir"; exit 1; }
  cd -
done
