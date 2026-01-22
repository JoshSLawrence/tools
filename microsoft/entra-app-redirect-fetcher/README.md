# Entra App Redirect Fetcher

Fetches all app registrations in a given tenant and their registered redirects
and outputs the result to a csv next the `script.sh` named `redirects.csv`.

The intent is to use this report to audit redirects and drive clean up.

## Usage

```bash
git clone "https://github.com/JoshSLawrence/tools"
cd tools
chmod +x "microsoft/entra-app-redirect-fetcher"
./microsoft/entra-app-redirect-fetcher
```
