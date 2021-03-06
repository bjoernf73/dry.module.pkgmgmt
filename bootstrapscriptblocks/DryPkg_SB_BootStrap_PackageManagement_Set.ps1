[scriptblock]$DryPkg_SB_BootStrap_PackageManagement_Set = {
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
        $Modules = @(Get-Module -Name 'PackageManagement' -ListAvailable -ErrorAction Stop | Sort-Object -Property 'Version' -Descending -ErrorAction Stop)
        if ($Modules[0].Version -lt $MinimumModuleVersion) {
            $InstallModuleParams = @{
                Name           = 'PackageManagement' 
                MinimumVersion = $MinimumModuleVersion
                Scope          = 'AllUsers'
                AllowClobber   = $true 
                Repository     = $PackageSourceName 
                Confirm        = $false
                Force          = $true
            }
            Install-Module @InstallModuleParams | Out-Null
        }
        
        Remove-Module -Name 'PowershellGet','PackageManagement' -Force -ErrorAction Ignore -WarningAction SilentlyContinue
        $Modules = @(Get-Module -Name 'PackageManagement' -ListAvailable -ErrorAction Stop | Sort-Object -Property 'Version' -Descending -ErrorAction Stop)
        if ($Modules[0].Version -lt $MinimumModuleVersion) {
            return $false
        }
        else {
            return $true
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        Remove-Module -Name 'PowershellGet','PackageManagement' -Force -ErrorAction Ignore -WarningAction SilentlyContinue
    }
}