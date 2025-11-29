#!/usr/bin/env bash
# Usage: vagrant_test_matrix.sh <vagrantfile> <host_arch> [box_version]
# 1. Parse box name/version from Vagrantfile or use provided box_version
# 2. Get supported providers for box/arch/version
# 3. For each provider: install tools/plugins, run vagrant up/halt/destroy
set -e
vagrantfile="$1"
host_arch="$2"
cli_box_version="$3"
if [[ -z "$vagrantfile" || -z "$host_arch" ]]; then
  echo "Usage: $0 <vagrantfile> <host_arch> [box_version]" >&2
  exit 1
fi
box_name=$(grep -Eo 'config.vm.box\s*=\s*"[^"]+"' "$vagrantfile" | head -1 | cut -d'"' -f2)
box_version=$(grep -Eo 'config.vm.box_version\s*=\s*"[^"]+"' "$vagrantfile" | head -1 | cut -d'"' -f2)
if [[ -n "$cli_box_version" ]]; then
  box_version="$cli_box_version"
fi
if [[ -z "$box_name" ]]; then
  echo "Error: No box name found in $vagrantfile" >&2
  exit 1
fi
providers=$(.github/scripts/get_supported_providers.sh "$box_name" "$box_version" "$host_arch")
if ! command -v vagrant >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y curl gnupg lsb-release || { echo "Error: Failed to install curl, gnupg, or lsb-release." >&2; exit 1; }
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg || { echo "Error: Failed to add HashiCorp GPG key." >&2; exit 1; }
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update
    sudo apt-get install -y vagrant || { echo "Error: Failed to install Vagrant." >&2; exit 1; }
fi
if ! vagrant --version; then
    echo "Error: Vagrant installation failed or vagrant not found in PATH." >&2
    exit 1
fi
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
