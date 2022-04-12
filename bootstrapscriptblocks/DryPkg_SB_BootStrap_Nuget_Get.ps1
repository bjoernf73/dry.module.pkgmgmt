[scriptblock]$DryPkg_SB_BootStrap_Nuget_Get = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory,HelpMessage="At the time of writing, this is 2.8.5.201")]
        [system.version]$MinimumProviderVersion
    )

    try {
        $HighestVersionedNugetProvider = @(Get-PackageProvider -Name 'Nuget' -ListAvailable -ErrorAction Ignore | Sort-Object -Property 'Version' -Descending -ErrorAction Ignore)[0]
        if ($null -eq $HighestVersionedNugetProvider) {
            return $false
        }
        elseif ($HighestVersionedNugetProvider.Version -lt $MinimumProviderVersion) {
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