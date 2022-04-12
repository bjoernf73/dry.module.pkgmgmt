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
        $Providers = @(Get-PackageProvider -Name 'PowerShellGet' -ListAvailable -ErrorAction Stop | Sort-Object -Property 'Version' -Descending -ErrorAction Stop)
        if ($Providers[0].Version -lt $MinimumModuleVersion) {
            $InstallPackageProviderParams = @{
                Name           = 'PowerShellGet' 
                MinimumVersion = $MinimumModuleVersion
                Scope          = 'AllUsers'
                Source         = $PackageSourceName 
                Confirm        = $false
                Force          = $true
            }
            Remove-Module -Name 'PowershellGet' -Force -ErrorAction Ignore -WarningAction SilentlyContinue
            Install-PackageProvider @InstallPackageProviderParams | Out-Null
        }
        
        $Providers = @(Get-PackageProvider -Name 'PowerShellGet' -ListAvailable -ErrorAction Stop | Sort-Object -Property 'Version' -Descending -ErrorAction Stop)
        $ProvidersToRemove = $Providers | Where-Object { 
            $_.Version -lt $Providers[0].Version
        }
        Remove-Module -Name 'PowershellGet' -Force -ErrorAction Ignore -WarningAction SilentlyContinue
        foreach ($ProviderToRemove in $ProvidersToRemove) {
            $ProviderPath = Join-Path -Path $ProviderToRemove.ProviderPath -ChildPath '..' | Resolve-Path 
            Remove-Item -Path $ProviderPath -Recurse -Confirm:$false
        }
        return $true
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        Remove-Module -Name 'PowershellGet' -Force -ErrorAction Ignore -WarningAction SilentlyContinue
    }
}