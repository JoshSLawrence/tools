# Azure Role Assignment Cleanse

This tool removes all role assignments for a given assignee under a given subscription
*except* for the `Reader` role.

The role to be retained can be modified by passing the display name of the role
you wish to retain via the `-r` argument.

## Requirements

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)
- The ability to alert role assignments for the target Azure Subscription
  - Owner
  - User Access Administrator

> [!NOTE]
> If you have a condition applied to a role such as `Owner`, ensure your
> conditional allows all you to modify all roles in scope for removal.

## Usage

```bash
git clone "https://github.com/JoshSLawrence/tools"
cd tools
chmod +x "microsoft/azure-role-assignment-cleanse/script.sh"
./microsoft/azure-role-assignment-cleanse/script.sh
```

### Supported Flags

- `--id` - PrincipalId/ObjectId to receive the permission update
- `-s` - The subscription context in which permissions should be updated
- `-r` - The only role to retain after the cleanse - defaults to `Reader`
- `-o` - Set the path and file name for the output - defaults to `original_assignments.csv`
- `--dry` - Skips the actual permission removal - useful if you would like to review
    the output.csv for current assignments first.

E.G.

```bash
./microsoft/azure-role-assignment-cleanse/script.sh \
    --id <principalId> \
    -s <subscriptionId> \
    -r "Reader" \
    -o "original_assignments.csv" \
    --dry
```
