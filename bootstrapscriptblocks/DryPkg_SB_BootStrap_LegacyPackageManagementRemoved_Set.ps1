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