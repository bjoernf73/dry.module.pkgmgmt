[scriptblock]$DryPkg_SB_BootStrap_Chocolatey_Set = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory)]
        [system.version]$MinimumModuleVersion,

        [Parameter(HelpMessage="If using an in-house nuget source, a hashtable containing the  
        params Name and Location of the PackageProvider. I'll provide the rest of the params  
        to splat to Register-PackageSource. If not present, I'll be using public Chocolatey")]
        [hashtable]$PackageSource
    )

    try {
        [string]$InstallScript = 'https://chocolatey.org/install.ps1'
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        
        if ($PackageSource) {
            [String]$InstallScript = $PackageSource["InstallScript"]
        }

        if (Get-Command -Name 'choco' -ErrorAction Ignore) {
            & choco upgrade chocolatey -y | Out-Null
        }
        else {
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($InstallScript)) -ErrorAction 'stop' | Out-Null
        }
        $CustomCommands = $null
        $Commands = $null
        
        # The .version property of chocolatey is not idential to the 
        # version when running choco --version
        [array]$CustomCommands = @()
        $Commands = @(Get-Command -Name 'choco' -ErrorAction Stop)
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