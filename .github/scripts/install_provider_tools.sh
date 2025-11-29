#!/usr/bin/env bash
# Usage: install_provider_tools.sh <provider>
# Installs system packages and Vagrant plugins for the given provider
set -e
provider="$1"
if [[ -z "$provider" ]]; then
  echo "Error: provider required" >&2
  exit 1
fi
case "$provider" in
  virtualbox)
    if ! command -v vboxmanage >/dev/null 2>&1; then
      sudo apt-get update
      sudo apt-get install -y virtualbox || { echo "Error: Failed to install VirtualBox." >&2; exit 1; }
    fi
    if ! command -v vboxmanage >/dev/null 2>&1; then
      echo "Error: VirtualBox not available after install." >&2
      exit 1
    fi
    if ! vagrant plugin list | grep -q vagrant-vbguest; then
      vagrant plugin install vagrant-vbguest || { echo "Error: Failed to install vagrant-vbguest plugin." >&2; exit 1; }
    fi
    if ! vagrant plugin list | grep -q vagrant-vbguest; then
      echo "Error: vagrant-vbguest plugin not available after install." >&2
      exit 1
    fi
    ;;
  # docker)
  #   if ! command -v docker >/dev/null 2>&1; then
  #     sudo apt-get update
  #     sudo apt-get install -y docker.io || { echo "Error: Failed to install Docker." >&2; exit 1; }
  #   fi
  #   if ! command -v docker >/dev/null 2>&1; then
  #     echo "Error: Docker not available after install." >&2
  #     exit 1
  #   fi
  #   if ! vagrant plugin list | grep -q vagrant-docker-compose; then
  #     vagrant plugin install vagrant-docker-compose || { echo "Error: Failed to install vagrant-docker-compose plugin." >&2; exit 1; }
  #   fi
  #   if ! vagrant plugin list | grep -q vagrant-docker-compose; then
  #     echo "Error: vagrant-docker-compose plugin not available after install." >&2
  #     exit 1
  #   fi
  #   ;;
  # qemu)
  #   if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
  #     sudo apt-get update
  #     sudo apt-get install -y qemu-system-x86 qemu-system-arm qemu-system-aarch64 qemu-user-static qemu-utils ovmf qemu-kvm || { echo "Error: Failed to install QEMU." >&2; exit 1; }
  #   fi
  #   if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
  #     echo "Error: QEMU not available after install." >&2
  #     exit 1
  #   fi
  #   if ! vagrant plugin list | grep -q vagrant-qemu; then
  #     vagrant plugin install vagrant-qemu || { echo "Error: Failed to install vagrant-qemu plugin." >&2; exit 1; }
  #   fi
  #   if ! vagrant plugin list | grep -q vagrant-qemu; then
  #     echo "Error: vagrant-qemu plugin not available after install." >&2
  #     exit 1
  #   fi
  #   ;;
  # libvirt)
  #   if ! command -v virsh >/dev/null 2>&1; then
  #     sudo apt-get update
  #     sudo apt-get install -y libvirt-daemon-system libvirt-clients bridge-utils ebtables dnsmasq-base libvirt-dev || { echo "Error: Failed to install libvirt and dependencies." >&2; exit 1; }
  #   fi
  #   if ! command -v virsh >/dev/null 2>&1; then
  #     echo "Error: libvirt/virsh not available after install." >&2
  #     exit 1
  #   fi
  #   if ! vagrant plugin list | grep -q vagrant-libvirt; then
  #     vagrant plugin install vagrant-libvirt || { echo "Error: Failed to install vagrant-libvirt plugin." >&2; exit 1; }
  #   fi
  #   if ! vagrant plugin list | grep -q vagrant-libvirt; then
  #     echo "Error: vagrant-libvirt plugin not available after install." >&2
  #     exit 1
  #   fi
  #   ;;
  *)
    echo "Warning: Unknown or unsupported provider '$provider', skipping installation." >&2
    exit 1
    ;;
esac
