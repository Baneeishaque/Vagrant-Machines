#!/usr/bin/env bash
set -e
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
