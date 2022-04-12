[scriptblock]$DryPkg_SB_BootStrap_LegacyPackageManagementRemoved_Set = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(HelpMessage="Ignored")]
        [system.version]$MinimumProviderVersion,

        [Parameter(HelpMessage="Ignored")]
        [hashtable]$PackageSource
    )

    try {
        $LegacyPackageManagementPath = "$($env:ProgramFiles)\WindowsPowershell\Modules\PackageManagement\1.0.0.1"
        
        $MaxLoops = 2
        $Loops = 0
        $AllFilesRemoved = $false
        do {
            $Loops++
            if (Test-Path -Path $LegacyPackageManagementPath -ErrorAction Ignore) {
                Remove-Item -Path $LegacyPackageManagementPath -Recurse -Force -Confirm:$false -ErrorAction Ignore
                Start-Sleep -Seconds 1 
            }
            else {
                $AllFilesRemoved = $true
            }
        }
        while (($Loops -le $MaxLoops) -and ($AllFilesRemoved -eq $false))
    
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