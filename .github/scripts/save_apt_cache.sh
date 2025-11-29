#!/usr/bin/env bash
mkdir -p .aptcache
sudo cp -l /var/cache/apt/archives/*.deb .aptcache || true
