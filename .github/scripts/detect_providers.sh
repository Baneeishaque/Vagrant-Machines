#!/usr/bin/env bash
providers=""
if command -v vboxmanage >/dev/null 2>&1; then
  vagrant plugin install vagrant-vbguest || { echo "Error: Failed to install vagrant-vbguest plugin." >&2; exit 1; }
  providers="virtualbox"
fi
if command -v docker >/dev/null 2>&1; then
  vagrant plugin install vagrant-docker-compose || { echo "Error: Failed to install vagrant-docker-compose plugin." >&2; exit 1; }
  if [[ -n "$providers" ]]; then
    providers="$providers docker"
  else
    providers="docker"
  fi
fi
if command -v qemu-system-x86_64 >/dev/null 2>&1; then
  vagrant plugin install vagrant-qemu || { echo "Error: Failed to install vagrant-qemu plugin." >&2; exit 1; }
  if [[ -n "$providers" ]]; then
    providers="$providers qemu"
  else
    providers="qemu"
  fi
fi
if command -v virsh >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y libvirt-dev || { echo "Error: Failed to install libvirt-dev." >&2; exit 1; }
  vagrant plugin install vagrant-libvirt || { echo "Error: Failed to install vagrant-libvirt plugin." >&2; exit 1; }
  if [[ -n "$providers" ]]; then
    providers="$providers libvirt"
  else
    providers="libvirt"
  fi
fi
if [[ -z "$providers" ]]; then
  echo "Error: No supported Vagrant providers detected." >&2
  exit 1
fi
echo "providers=$providers" >> "$GITHUB_OUTPUT"
