#!/usr/bin/env bash
if command -v docker >/dev/null 2>&1; then
  echo "Docker available"
else
  echo "Docker not available"
fi
