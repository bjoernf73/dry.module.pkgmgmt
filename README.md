# dry.module.pkgmgmt

A PSmodule to
 1. bootstrap package management 
 1. manage package source registrations
 1. install packages

## Bootstrapping package management
For some reason, at the time of writing at least, most Windows variants ships with outdated components for proper package management. The exported function `Initialize-DryPkgMgmt` fixes that (bootstraps packagemanagement). 
Anyways:

```powershell
$MinimumVersions = [PSCustomObject]@{
    Nuget             = [System.Version]"2.8.5.201";
    PackageManagement = [System.Version]"1.4.7";
    PowerShellGet     = [System.Version]"2.2.5";
    Chocolatey        = [System.Version]"0.12.0";
    Foil              = [System.Version]"0.1.0";
    Git               = [System.Version]"2.33.1";
    GitAutomation     = [System.Version]"0.14.0" 
}
```
The Nuget-provider, and the PackageManagement and PowerShellGet PSModules, are the components vital to packagemenagement on Windows, that I'm referring to above. The rest of the components are enhancement modules that enables easier chocolatey and git management for this module. 

The bootstrapping does the following: 

- if the Nuget packageprovider version is less than the minimum, the newest version found is installed.
- if the PackageManagement (a.k.a 'OneGet') PowerShell module installed version is less than the minimum, the newest version found is installed. Aged versions are sought, and physically removed (from the filesystem), since there's no telling if that version of the module is implicitly loaded when a PackageManagement function is called.
- if the PowerShellGet PowerShell module installed version is less than the minimum, the newest version found is installed. Aged versions are sought, and physically removed (from the filesystem), since there's no telling if that version of the module is implicitly loaded when a PowerShellGet function is called.
- if Chocolatey ('choco.exe') is not found in the environment's path, or it's version is less than the minimum, latest version is installed. 
- if the PowerShell module *Foil* is not found, or it's version is less than the minimum, the latest version is installed. 
- if the Git client is not found, or it's version is less than the minimum, latest version found is installed.
- if the PowerShell module *GitAutomation* is not found, or it's version is less than the minimum, the latest version is installed. 

## Package Source registration
Register and unregister package sources. Supports the source types:

1. Nugets
1. Chocolateys
1. Gits


## Package Installations
Installs packages, using PackageManagement (a.k.a OneGet). Supports packages of the following types: 

- PowerShell modules (nuget)
- Chocolatey packages (nuget)
- Git-repos as PowerShell modules (git, cloned into the system PSModulePath)
- Git-repos (cloned into any folder)
- Windows Roles and Features
- Windows Optional Components


## Package Management bootstrapping in Packer
If you use Packer to create images, the following powershell-provisioner config (in json-format) will enable proper package management in your win-images. This only takes care of the 3 vital components Nuget-provider, PackageManagement PSModule and the PowerShellGet PSModule. Run this first in your packer-config: 

```json
....
"provisioners": [
    {
      "type": "powershell",
      "inline": [
        "$NugetProviderMinVersion = [system.version]\"2.8.5.201\"",
        "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12",
        "Set-PackageSource -Name PSGallery -Trusted",
        "Install-PackageProvider -Name Nuget -MinimumVersion $NugetProviderMinVersion -Scope AllUsers -Confirm:$false -Force"],
      "elevated_user": "{{user `winrm_username`}}",
      "elevated_password": "{{user `winrm_password`}}"
    },
     {
      "type": "windows-restart",
      "restart_check_command": "powershell -command \"& {Write-Output 'restarted.'}\""
    },
    {
      "type": "powershell",
      "inline": [
        "$PackageManagementMinVersion = [system.version]\"1.4.7\"",
        "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12",
        "Install-Module -Name PackageManagement -MinimumVersion $PackageManagementMinVersion -Scope AllUsers -AllowClobber -Repository PSGallery -Confirm:$false -Force"],
      "elevated_user": "{{user `winrm_username`}}",
      "elevated_password": "{{user `winrm_password`}}"
    },
    {
      "type": "windows-restart",
      "restart_check_command": "powershell -command \"& {Write-Output 'restarted.'}\""
    },
    {
      "type": "powershell",
      "inline": [
        "$PowerShellGetMinVersion = [system.version]\"2.2.5\"",
        "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12",
        "Install-Module -Name PowerShellGet -MinimumVersion $PowerShellGetMinVersion -Scope AllUsers -AllowClobber -Repository PSGallery -Confirm:$false -Force -WarningAction Continue",
        "Remove-Module -Name PowerShellGet -ErrorAction Ignore",
        "Remove-Module -Name PackageManagement -ErrorAction Ignore",
        "$ModulesToDelete = @(Get-Module -Name PowerShellGet -ListAvailable | Where-Object Version -lt $PowerShellGetMinVersion)",
        "foreach ($m in $ModulesToDelete) { Remove-Item -Path (Split-Path -Path $m.Path) -Recurse -Force }"
      ],
      "elevated_user": "{{user `winrm_username`}}",
      "elevated_password": "{{user `winrm_password`}}"
    },
    {
      "type": "windows-restart",
      "restart_check_command": "powershell -command \"& {Write-Output 'restarted.'}\""
    },
    ...
```

## Example

```json
{
  "package_management": {
    "sources": [
      {

      },
      {

      }
    ],
    "packages": [

    ],
    "components": [
      // windows roles, features, optional components etc
    ]
  }
}
```