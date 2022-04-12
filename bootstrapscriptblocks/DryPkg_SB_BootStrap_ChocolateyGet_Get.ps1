[scriptblock]$DryPkg_SB_BootStrap_ChocolateyGet_Get = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory,HelpMessage="At the time of writing, this is 4.0.0.0")]
        [system.version]$MinimumProviderVersion
    )

    try {
        $HighestVersionedChocolateyGetProvider = @(Get-PackageProvider -Name 'ChocolateyGet' -ListAvailable -ErrorAction Ignore | Sort-Object -Property 'Version' -Descending -ErrorAction Ignore)[0]
        if ($null -eq $HighestVersionedChocolateyGetProvider) {
            return $false
        }
        elseif ($HighestVersionedChocolateyGetProvider.Version -lt $MinimumProviderVersion) {
            return $false
        }
        else {
            return $true
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}