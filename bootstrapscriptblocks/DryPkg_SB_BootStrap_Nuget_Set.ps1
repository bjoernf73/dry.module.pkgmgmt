[scriptblock]$DryPkg_SB_BootStrap_Nuget_Set = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory,HelpMessage="At the time of writing, this is 2.8.5.201")]
        [system.version]$MinimumProviderVersion,

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
        $MyPackageSource = Set-PackageSource -Name $PackageSourceName -Trusted -ErrorAction 'Stop'  #this will return the package source
        
        $InstallPackageProviderParams = @{
            Name           = 'Nuget'
            MinimumVersion = $MinimumProviderVersion 
            Scope          = 'AllUsers'
            Source         = $MyPackageSource 
            Confirm        = $false 
            Force          = $true
        }
        Install-PackageProvider @InstallPackageProviderParams | Out-Null
        return $true
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        Remove-Module -Name 'PowershellGet','PackageManagement' -Force -ErrorAction Ignore -WarningAction SilentlyContinue
    }
}