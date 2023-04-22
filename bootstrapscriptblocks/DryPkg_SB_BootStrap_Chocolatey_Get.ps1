<# 
 This module provides functions for bootstrapping package management, 
 registering package sources and package installations for use with 
 DryDeploy. ModuleConfigs may specify dependencies in it's root config
 that this module processes.

 Copyright (C) 2023  Bjorn Henrik Formo (bjornhenrikformo@gmail.com)
 LICENSE: https://raw.githubusercontent.com/bjoernf73/dry.module.pkgmgmt/main/LICENSE
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along
 with this program; if not, write to the Free Software Foundation, Inc.,
 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#>
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
        
        # The .version property of the choco.exe file object is unrelated to  
        # choco.exe --version, which is the actual version of chocolatey
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