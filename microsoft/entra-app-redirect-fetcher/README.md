# Entra App Redirect Fetcher

Fetches all app registrations in a given tenant and their registered redirects
and outputs the result to a csv next to `script.sh` named `redirects.csv`.

The intent is to use this report to audit redirects and drive clean up.

## Requirements

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)
- The ability to read App Registration manifests from Entra

## Usage

```bash
git clone "https://github.com/JoshSLawrence/tools"
cd tools
chmod +x "microsoft/entra-app-redirect-fetcher"
./microsoft/entra-app-redirect-fetcher
```

### Supported Flags

- `-t` - Target a specific Entra tenant
- `-o` - Set the path and file name for the output

E.G.

```bash
./microsoft/entra-app-redirect-fetcher -t <tenant guid>
./microsoft/entra-app-redirect-fetcher -o <filename or path/filename>
```
