#!/bin/bash

# Set script dir as active dir
cd "$(dirname "$0")"

OUTFILE="original_assignments.csv"
RETAIN="Reader"
DRYRUN="false"

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --id)
      PRINCIPALID="$2"
      shift 2
      ;;
    -s)
      SUBSCRIPTION="$2"
      shift 2
      ;;
    -r)
      RETAIN="$2"
      shift 2
      ;;
    -o)
      OUTFILE="$2"
      shift 2
      ;;
    --dry)
      DRYRUN="true"
      shift 1
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Colors for string formatting
NOCOLOR='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'

if [ "$DRYRUN" = "true" ]; then
  DRYRUN_COLOR=$GREEN
else
  DRYRUN_COLOR=$RED
fi

if [ -z "$PRINCIPALID" ] || [ -z "$SUBSCRIPTION" ]; then
  echo -e "${RED}[ERROR] -id and -s are required parameters${NOCOLOR}"
  exit 1
fi

if [ "$DRYRUN" == "true" ]; then
  echo -e "${YELLOW}DRYRUN REQUESTED${NOCOLOR}"
fi

az account show > /dev/null 2>&1
LOGGEDIN=$?

if [ $LOGGEDIN -eq 1 ]; then
  echo "Initiating login request for subscription: $SUBSCRIPTION"
  az login --subscription $SUBSCRIPTION
fi

ACTIVE_SUB=$(az account show | jq -r ".id")
ACTIVE_SUB_NAME=$(az account show | jq -r ".name")

PRINCIPAL_NAME=$(
  # Try user
  az ad user show --id "$PRINCIPALID" --query "displayName" -o tsv 2>/dev/null ||
  # Try group
  az ad group show --group "$PRINCIPALID" --query "displayName" -o tsv 2>/dev/null ||
  # Try service principal
  az ad sp show --id "$PRINCIPALID" --query "displayName" -o tsv 2>/dev/null
)

if [ "$ACTIVE_SUB" != "$SUBSCRIPTION" ]; then
  echo -e "${YELLOW}Switching to subscription: $SUBSCRIPTION - (from sub: $ACTIVE_SUB)${NOCOLOR}"
  az account set -s $SUBSCRIPTION
  ACTIVE_SUB=$(az account show | jq -r ".id")
  ACTIVE_SUB_NAME=$(az account show | jq -r ".name")
fi

echo
echo -e "${YELLOW}[SUBID]${NOCOLOR}         $ACTIVE_SUB"
echo -e "${YELLOW}[SUBNAME]${NOCOLOR}       $ACTIVE_SUB_NAME"
echo -e "${YELLOW}[PRINCIPALID]${NOCOLOR}   $PRINCIPALID"
echo -e "${YELLOW}[PRINCIPALNAME]${NOCOLOR} $PRINCIPAL_NAME"
echo -e "${YELLOW}[RETAINROLE]${NOCOLOR}    $RETAIN"
echo -e "${YELLOW}[OUTFILE]${NOCOLOR}       $OUTFILE"
echo -e "${YELLOW}[DRYRUN]${NOCOLOR}        ${DRYRUN_COLOR}$DRYRUN${NOCOLOR}"
echo

echo "principalName,roleDefinitionName,scope,id,subscription" > $OUTFILE
az role assignment list --all --assignee $PRINCIPALID | \
  jq -r --arg subscription $SUBSCRIPTION '
  .[] | [.principalName, .roleDefinitionName, .scope, .id, $subscription] | @csv
' >> $OUTFILE

az role assignment list --all --assignee $PRINCIPALID | \
  jq -c --arg retain $RETAIN '.[] | select(.roleDefinitionName != $retain)' | \
  while read -r assignment; do
    id=$(echo "$assignment" | jq -r '.id')
    name=$(echo "$assignment" | jq -r '.roleDefinitionName')
    if [ "$DRYRUN" == "true" ]; then
      echo -e "${YELLOW}[SKIPPED] Deleting role assignment: ${NOCOLOR}${GREEN}$name ${NOCOLOR}ID: $id"
    else
      echo -e "${YELLOW}Deleting role assignment: ${NOCOLOR}${GREEN}$name ${NOCOLOR}ID: $id"
      az role assignment delete --ids "$id"
    fi
  done

echo -e "\n${GREEN}Complete${NOCOLOR}"
