#!/bin/bash

OUTFILE="redirects.csv"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t)
      TENANT="$2"
      shift 2
      ;;
    -o)
      OUTFILE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Set script dir as active dir
cd "$(dirname "$0")"

az account show > /dev/null 2>&1
LOGGEDIN=$?

# NOTE: This script purely interacts with Entra so we want to pass `--allow-no-subscriptions`
# If we do not, tenants without subscriptions - or if the user doesn't have access
# to any subscriptions - will cause login to fail... even though we only care about
# Entra data and are not touching/querying subs
if [ -n "$TENANT" ]; then
  echo "Logging into requested tenant: $TENANT"
  az logout
  az login --allow-no-subscriptions -t "$TENANT"
elif [ $LOGGEDIN -eq 1 ]; then
  echo "Initiating login request"
  az login --allow-no-subscriptions
fi

TENANT=$(az account show | jq -r ".tenantId")

# NOTE: This may take a while to execute as the az cli is not aggresive on
# fetching results in tenants with a large app total
echo "displayName,id,type,redirectUri,tenantId" > "$OUTFILE"
az ad app list --all | jq -r --arg tenant $TENANT '
  .[] |
    (
      .spa.redirectUris[]? as $uri
        | [.displayName, .id, "spa", $uri, $tenant]
    ),
    (
      .web.redirectUris[]? as $uri
        | [.displayName, .id, "web", $uri, $tenant]
    ),
    (
      .publicClient.redirectUris[]? as $uri
        | [.displayName, .id, "publicClient", $uri, $tenant]
    )
  | @csv
' >> "$OUTFILE"

echo "Report generated and saved to: $OUTFILE"
