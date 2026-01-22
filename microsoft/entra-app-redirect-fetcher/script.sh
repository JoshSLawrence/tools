#!/bin/bash

# Set script dir as active dir
cd "$(dirname "$0")"
WORKING_DIR=$(pwd)

az account show > /dev/null 2>&1

if [ $? -eq 1 ]; then
  az login
fi

# NOTE: This may take a while to execute as the az cli is not aggresive on
# fetching results in tenants with a large app total
echo "displayName,id,type,redirectUri" > redirects.csv
az ad app list --all | jq -r '
  .[] |
    (
      .spa.redirectUris[]? as $uri
        | [.displayName, .id, "spa", $uri]
    ),
    (
      .web.redirectUris[]? as $uri
        | [.displayName, .id, "web", $uri]
    ),
    (
      .publicClient.redirectUris[]? as $uri
        | [.displayName, .id, "publicClient", $uri]
    )
  | @csv
' >> redirects.csv
