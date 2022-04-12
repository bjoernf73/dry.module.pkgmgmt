[scriptblock]$DryPkg_SB_BootStrap_LegacyPackageManagementRemoved_Get = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(HelpMessage="Ignored")]
        [system.version]$MinimumProviderVersion
    )

    try {
        $LegacyPackageManagementPath = "$($env:ProgramFiles)\WindowsPowershell\Modules\PackageManagement\1.0.0.1"
        if (Test-Path -Path $LegacyPackageManagementPath -ErrorAction Ignore) {
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