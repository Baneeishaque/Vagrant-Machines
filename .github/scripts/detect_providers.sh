#!/usr/bin/env bash
providers=""
if command -v vboxmanage >/dev/null 2>&1; then
  vagrant plugin install vagrant-vbguest || true
  providers="virtualbox"
fi
if command -v docker >/dev/null 2>&1; then
  vagrant plugin install vagrant-docker-compose || true
  if [[ -n "$providers" ]]; then
    providers="$providers docker"
  else
    providers="docker"
  fi
fi
if command -v qemu-system-x86_64 >/dev/null 2>&1; then
  vagrant plugin install vagrant-qemu || true
  if [[ -n "$providers" ]]; then
    providers="$providers qemu"
  else
    providers="qemu"
  fi
fi
if command -v virsh >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y libvirt-dev
  vagrant plugin install vagrant-libvirt || true
  if [[ -n "$providers" ]]; then
    providers="$providers libvirt"
  else
    providers="libvirt"
  fi
fi
echo "providers=$providers" >> "$GITHUB_OUTPUT"
