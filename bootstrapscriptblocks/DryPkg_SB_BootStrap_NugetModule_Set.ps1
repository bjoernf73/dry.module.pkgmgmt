[scriptblock]$DryPkg_SB_BootStrap_NugetModule_Set = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory)]
        [system.version]$MinimumModuleVersion,

        [Parameter(Mandatory)]
        [string]$Module,

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
                $PackageSource['ErrorAction'] = 'Stop'
                if ($null -eq $PackageSource['ProviderName']) { $PackageSource['ProviderName'] = 'Nuget' }
                if ($null -eq $PackageSource['Trusted'])      { $PackageSource['Trusted'] = $true }
                Register-PackageSource @PackageSource | Out-Null
            }
        }
        $Modules = @(Get-Module -Name $Module -ListAvailable -ErrorAction Stop | Sort-Object -Property 'Version' -Descending -ErrorAction Stop)
        if ($Modules[0].Version -lt $MinimumModuleVersion) {
            $InstallModuleParams = @{
                Name           = $Module 
                MinimumVersion = $MinimumModuleVersion
                Scope          = 'AllUsers'
                AllowClobber   = $true 
                Repository     = $PackageSourceName 
                Confirm        = $false
                Force          = $true
            }
            Install-Module @InstallModuleParams | Out-Null
        }
        
        $Modules = @(Get-Module -Name $Module -ListAvailable -ErrorAction Stop | Sort-Object -Property 'Version' -Descending -ErrorAction Stop)
        $ModulesToRemove = $Modules | Where-Object { 
            $_.Version -lt $Modules[0].Version
        }
        Remove-Module -Name $Module -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        foreach ($ModuleToRemove in $ModulesToRemove) {
            Remove-Item -Path (Split-Path -Path $ModuleToRemove.Path) -Recurse -Force -Confirm:$false
        }
        return $true
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}