#!/bin/bash

source ~/.bashrc
UTIL_DIR=/pyperf_util

if [ -z "$PYPERF_INSTANCE_ID" ]; then
    echo "Error: PYPERF_INSTANCE_ID is not set." >&2
    exit 1
fi

# Read the swe-bench-test-lite.json file and extract the required item based on instance_id
item=$(jq --arg INSTANCE_ID "$PYPERF_INSTANCE_ID" '.[] | select(.instance_id == $INSTANCE_ID)' $UTIL_DIR/eval_data/instances/pyperf-instance.json)

if [[ -z "$item" ]]; then
  echo "No item found for the provided instance ID."
  exit 1
fi

WORKSPACE_NAME=$(echo "$item" | jq -r '(.repo | tostring) | gsub("/"; "__")')

echo "WORKSPACE_NAME: $WORKSPACE_NAME"

# Clear the workspace
if [ -d /workspace ]; then
    rm -rf /workspace/*
else
    mkdir /workspace
fi
# Copy repo to workspace
if [ -d /workspace/$WORKSPACE_NAME ]; then
    rm -rf /workspace/$WORKSPACE_NAME
fi
mkdir -p /workspace
cp -r /testbed /workspace/$WORKSPACE_NAME
