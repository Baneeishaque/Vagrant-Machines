#!/usr/bin/env bash
aptHash() { echo "$1-$(apt-cache policy "$1" | grep -oP '(?<=Candidate:\s)(.+)')"; }
export -f aptHash
hash=$(echo "qemu-system-x86 qemu-system-arm qemu-system-aarch64 qemu-user-static qemu-utils ovmf" | xargs -rI {} bash -c 'aptHash {}' | tr '\n' '-' | md5sum | cut -f 1 -d ' ')
echo "key=apt-cache-$hash" >> "$GITHUB_OUTPUT"
