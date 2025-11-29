#!/usr/bin/env bash
set -e
aptHash() {
	local pkg="$1"
	local candidate
	candidate=$(apt-cache policy "$pkg" | grep -oP '(?<=Candidate:\s)(.+)') || { echo "Error: Failed to get candidate version for $pkg" >&2; exit 1; }
	if [[ -z "$candidate" ]]; then
		echo "Error: No candidate version found for $pkg" >&2
		exit 1
	fi
	echo "$pkg-$candidate"
}
export -f aptHash
hash=$(echo "qemu-system-x86 qemu-system-arm qemu-system-aarch64 qemu-user-static qemu-utils ovmf" | xargs -rI {} bash -c 'aptHash {}') || { echo "Error: Failed to calculate apt cache hash" >&2; exit 1; }
hash=$(echo "$hash" | tr '\n' '-' | md5sum | cut -f 1 -d ' ')
if [[ -z "$hash" ]]; then
	echo "Error: Failed to generate hash for apt cache key" >&2
	exit 1
fi
echo "key=apt-cache-$hash" >> "$GITHUB_OUTPUT"
