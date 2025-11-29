#!/usr/bin/env bash
sudo apt-get update
if ! sudo apt-get install -y \
  qemu-system-x86 qemu-system-arm qemu-system-aarch64 qemu-user-static qemu-utils ovmf \
  qemu-kvm \
  libvirt-daemon-system libvirt-clients \
  bridge-utils ebtables dnsmasq-base; then
  echo "Error: Failed to install QEMU/libvirt and dependencies." >&2
  echo "success=false" >> "$GITHUB_OUTPUT"
  exit 1
fi
if command -v qemu-system-x86_64 >/dev/null 2>&1; then
  echo "QEMU installed via apt-get."
  echo "success=true" >> "$GITHUB_OUTPUT"
else
  echo "QEMU install via apt-get failed."
  echo "success=false" >> "$GITHUB_OUTPUT"
  exit 1
fi
