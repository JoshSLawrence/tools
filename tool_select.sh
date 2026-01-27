#!/bin/bash

TOOL_REGISTRY="registry.json"

# Target this (script's) directory
cd "$(dirname "$0")"

# Prompt user for tool selection
tool=$(cat $TOOL_REGISTRY | jq ".[].name" | fzf)

# Determine how to run selected tool
LOCATION=$(cat $TOOL_REGISTRY | jq -r ".[] | select(.name == $tool) | .location")
COMMAND=$(cat $TOOL_REGISTRY | jq -r ".[] | select(.name == $tool) | .command")
ARGS=$(cat $TOOL_REGISTRY | jq -r ".[] | select(.name == $tool) | .args.[]" 2>/dev/null) || echo "No args to process for this tool"

# If tool takes args, prompt for arg values
PROCESSED_ARGS=""
for arg in $ARGS; do
  read -p "Value for $arg (press enter to skip): " value
  if [ -n "$value" ]; then
    PROCESSED_ARGS+="$arg $value "
  fi
done

# Tool execution
$COMMAND $LOCATION $PROCESSED_ARGS
