# PSAuthClient Build Instructions
To build PSAuthClient from source, run the following PowerShell scripts in order.

## 1. `.\build\1_PSAuthClient.build.ps1`
Fetches the latest `nuget.exe`, restores the required NuGet packages (WebView2) and bundles the required assemblies into the module's release directory.

## 2. `.\build\2_PSAuthClient.rollup.ps1`
Combines all the source files into a single `.psm1` module file, extracts public functions, aliases and scripts to generate a corresponding `.psd1` module manifest. 

## 3. `.\build\3_PSAuthClient.pester.ps1`
Before running this script, ensure that the `tests\config.json` file is configured with an appropriate identity provider (IdP) which supports auth code flow with (and without) PKCE, client credentials (secret and certificate), device code, implicit and hybrid grants (Entra ID supports all these flows).

The script performs the following tasks:
* Removes any previously loaded module and dot-sourced functions from the session
* Ensures Pester v5+ is installed and imported.
* Executes unit tests for module-internal functions.
* Executes integration tests for authentication logic across different client types against the configured IdP.

## 4. `.\build\4_PSAuthClient.platyPS.ps1`
Installs PlatyPS if not already present, generates the module's help documentation in markdown format, and processes the markdown files to ensure that code snippets are tagged as PowerShell.