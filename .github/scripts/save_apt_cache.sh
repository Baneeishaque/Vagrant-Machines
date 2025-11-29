#!/usr/bin/env bash
set -e
mkdir -p .aptcache
if compgen -G "/var/cache/apt/archives/*.deb" > /dev/null; then
	if ! sudo cp -l /var/cache/apt/archives/*.deb .aptcache; then
		echo "Error: Failed to save .deb files to .aptcache" >&2
		exit 1
	fi
fi
