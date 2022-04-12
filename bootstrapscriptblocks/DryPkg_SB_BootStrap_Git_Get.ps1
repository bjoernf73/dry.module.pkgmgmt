[scriptblock]$DryPkg_SB_BootStrap_Git_Get = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory)]
        [system.version]$MinimumModuleVersion
    )

    try {
        $Commands = $null
        $Commands = @(Get-Command -Name 'git' -ErrorAction Ignore | Sort-Object -Property 'Version' -Descending -ErrorAction Ignore)

        if ($Commands.count -eq 0) {
            return $false
        } 
        elseif ($Commands[0].Version -ge $MinimumModuleVersion) {
            return $true
        } 
        else {
            return $false
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}