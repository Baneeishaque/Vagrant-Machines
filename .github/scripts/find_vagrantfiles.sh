#!/usr/bin/env bash
set -e
if [[ "$GITHUB_EVENT_NAME" == "workflow_dispatch" ]]; then
  if [[ -n "$BOX_NAME" ]]; then
    mkdir -p .ci-tmp
    cat > .ci-tmp/Vagrantfile <<EOF
Vagrant.configure("2") do |config|
  config.vm.box = "$BOX_NAME"
  $( [[ -n "$BOX_VERSION" ]] && echo "config.vm.box_version = \"$BOX_VERSION\"")
end
EOF
    echo "Manual run: using generated Vagrantfile for box $BOX_NAME version $BOX_VERSION"
    echo "files=.ci-tmp/Vagrantfile" >> "$GITHUB_OUTPUT"
  elif [[ -n "$VAGRANTFILE_PATH" ]]; then
    echo "Manual run: using input Vagrantfile path"
    echo "files=$VAGRANTFILE_PATH" >> "$GITHUB_OUTPUT"
  else
    echo "Error: On workflow_dispatch, either vagrantfile_path or box_name must be provided." >&2
    exit 1
  fi
else
  if ! git fetch origin "$GITHUB_BEFORE"; then
    echo "Error: git fetch failed for $GITHUB_BEFORE" >&2
    exit 1
  fi
  git diff --name-only "$GITHUB_BEFORE" "$GITHUB_SHA" | grep 'Vagrantfile$' > changed_vagrantfiles.txt || true
  if [[ ! -s changed_vagrantfiles.txt ]]; then
    echo "Error: No changed Vagrantfiles found between $GITHUB_BEFORE and $GITHUB_SHA" >&2
    exit 1
  fi
  cat changed_vagrantfiles.txt
  echo "files=$(cat changed_vagrantfiles.txt | xargs)" >> "$GITHUB_OUTPUT"
fi
