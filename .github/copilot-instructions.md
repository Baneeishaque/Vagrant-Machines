# Copilot Instructions for Vagrant-Machines

## Overview
This repository manages multiple Vagrant environments for different OS and application setups. Each subdirectory contains a self-contained Vagrant project, typically with a `Vagrantfile` and, in some cases, additional automation or configuration files.

## Directory Structure
- **Odoo 12 CE/**: Vagrant box for Odoo 12 on Ubuntu 18.04, with public network and VirtualBox UART customization.
- **ubuntu-24-04/**: Minimal Ubuntu 24.04 Vagrant box setup.
- **Ubuntu-Desktop-24.04.1-LTS-ARM64-VirtualBox/**: Ubuntu Desktop ARM64 box, VirtualBox provider.
- **Windows 10.0.26100.4061/**: Windows 11 Enterprise Vagrant box, supports both VirtualBox and VMware Fusion. Includes a `codemagic.yaml` for CI automation.

## Key Patterns & Conventions
- **Each subfolder is a separate Vagrant environment.**
- **Vagrantfiles** are minimal and provider-specific customizations are common (e.g., enabling GUI, clipboard, UART, etc.).
- **No cross-folder dependencies**: Each environment is isolated; changes in one do not affect others.
- **Provider Customization**: Use `config.vm.provider` blocks for provider-specific settings (see Odoo and Windows examples).
- **Box Version Pinning**: All Vagrantfiles pin box versions for reproducibility.
- **CI/CD**: The Windows folder uses `codemagic.yaml` to automate box builds and environment setup (see that file for build steps).

## Developer Workflows
- **Start a VM**: `cd <subfolder> && vagrant up --provider=virtualbox`
- **Stop a VM**: `vagrant halt`
- **Destroy a VM**: `vagrant destroy`
- **Reprovision**: `vagrant reload --provision`
- **CI Build (Windows only)**: See `codemagic.yaml` for Mac M1 build steps (installs VirtualBox, Vagrant, then runs `vagrant up`).

## Project-Specific Notes
- **No global Vagrantfile**: All configuration is per-environment.
- **No custom plugins or scripts**: Provisioning is handled by the base boxes; no shell scripts or provisioning files are present.
- **.vagrant/** folders are ignored via `.gitignore`.
- **VS Code**: `.vscode/extensions.json` recommends Vagrant and Git-related extensions for development.

## Examples
- To launch the Odoo 12 VM with GUI and UART disconnected:
  ```sh
  cd "Odoo 12 CE"
  vagrant up --provider=virtualbox
  ```
- To build the Windows box via CI:
  See `Windows 10.0.26100.4061/codemagic.yaml` for the full workflow.

## When Adding New Environments
- Place each new Vagrant environment in its own folder.
- Pin box versions and document any provider customizations in the Vagrantfile.
- Update `.vscode/extensions.json` if new tools are required.

---
For more details, see the Vagrantfiles in each subdirectory and the `codemagic.yaml` for CI/CD automation.
