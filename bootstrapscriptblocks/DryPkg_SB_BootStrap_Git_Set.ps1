[scriptblock]$DryPkg_SB_BootStrap_Git_Set = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory)]
        [system.version]$MinimumModuleVersion,

        [Parameter(HelpMessage="Not in use")]
        [hashtable]$PackageSource
    )

    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        & choco upgrade git -y | Out-Null
        $Git = Get-Command -Name "$($env:ProgramFiles)\Git\bin\git.exe" -ErrorAction Stop
        if ($Git.Version -ge $MinimumModuleVersion) {
            return $true
        } 
        else {
            throw "Git was not updated"
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}