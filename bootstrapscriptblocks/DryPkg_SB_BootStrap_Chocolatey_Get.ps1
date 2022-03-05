[scriptblock]$DryPkg_SB_BootStrap_Chocolatey_Get = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory)]
        [system.version]$MinimumModuleVersion
    )

    try {
        $CustomCommands = $null
        $Commands = $null
        
        # The .version property of chocolatey is not idential to the 
        # version when running choco --version
        [array]$CustomCommands = @()
        $Commands = @(Get-Command -Name 'choco' -ErrorAction Ignore)
        foreach ($Command in $Commands) {
            $CustomCommands += (New-Object -TypeName PSObject -Property @{
                Name    = $Command.Name
                Path    = $Command.Path
                Version = [system.version](& $($Command.Path) --version)
            })
        }
        $CustomCommands = @($CustomCommands | Sort-Object -Property 'Version' -Descending -ErrorAction Ignore)

        if ($CustomCommands.count -eq 0) {
            return $false
        } 
        elseif ($CustomCommands[0].Version -ge $MinimumModuleVersion) {
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