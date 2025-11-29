#!/usr/bin/env bash
set -e
if ! command -v vagrant >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y curl gnupg lsb-release
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update && sudo apt-get install -y vagrant
fi
vagrant --version
