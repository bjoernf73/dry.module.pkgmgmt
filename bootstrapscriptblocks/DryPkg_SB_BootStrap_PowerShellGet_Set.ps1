[scriptblock]$DryPkg_SB_BootStrap_PowerShellGet_Set = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory)]
        [system.version]$MinimumModuleVersion,

        [Parameter(HelpMessage="If using an in-house nuget source, a hashtable containing the  
        params Name and Location of the PackageProvider. I'll provide the rest of the params  
        to splat to Register-PackageSource. If not present, I'll be using PSGallery")]
        [hashtable]$PackageSource
    )

    <#[
        "$PowerShellGetMinVersion = [system.version]\"2.2.5\"",
        "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12",
        "Install-Module -Name PowerShellGet -MinimumVersion $PowerShellGetMinVersion -Scope AllUsers -AllowClobber -Repository PSGallery -Confirm:$false -Force -WarningAction Continue",
        "Remove-Module -Name PowerShellGet -ErrorAction Ignore",
        "Remove-Module -Name PackageManagement -ErrorAction Ignore",
        "$ModulesToDelete = @(Get-Module -Name PowerShellGet -ListAvailable | Where-Object Version -lt $PowerShellGetMinVersion)",
        "foreach ($m in $ModulesToDelete) { Remove-Item -Path (Split-Path -Path $m.Path) -Recurse -Force }"
      ],#>

    try {
        [string]$PackageSourceName = 'PSGallery'
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        
        if ($PackageSource) {
            [String]$PackageSourceName = $PackageSource["Name"]
            if (-not (Get-PackageSource -Name $PackageSourceName -ErrorAction 'SilentlyContinue')) {
                # Register-PackageSource -Name MyNuGet -Location https://www.nuget.org/api/v2 -ProviderName NuGet
                Register-PackageSource @PackageSourceParams -ErrorAction 'Stop' -ProviderName 'Nuget' | Out-Null
            }
        }
        $Modules = @(Get-Module -Name 'PowerShellGet' -ListAvailable -ErrorAction Stop | Sort-Object -Property 'Version' -Descending -ErrorAction Stop)
        if ($Modules[0].Version -lt $MinimumModuleVersion) {
            $InstallModuleParams = @{
                Name           = 'PowerShellGet' 
                MinimumVersion = $MinimumModuleVersion
                Scope          = 'AllUsers'
                AllowClobber   = $true 
                Repository     = $PackageSourceName 
                Confirm        = $false
                Force          = $true
            }
            Remove-Module -Name 'PackageManagement','PowerShellGet' -Force -ErrorAction SilentlyContinue
            Install-Module @InstallModuleParams | Out-Null
        }
        
        $Modules = @(Get-Module -Name 'PowerShellGet' -ListAvailable -ErrorAction Stop | Sort-Object -Property 'Version' -Descending -ErrorAction Stop)
        $ModulesToRemove = $Modules | Where-Object { 
            $_.Version -lt $Modules[0].Version
        }
        Remove-Module -Name 'PowerShellGet' -Force -ErrorAction SilentlyContinue
        foreach ($ModuleToRemove in $ModulesToRemove) {
            Remove-Item -Path (Split-Path -Path $ModuleToRemove.Path) -Recurse -Confirm:$false
        }
        return $true
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}