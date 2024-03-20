<# 
 This module provides functions for bootstrapping package management, 
 registering package sources and package installations for use with 
 DryDeploy. ModuleConfigs may specify dependencies in it's root config
 that this module processes.

 Copyright (C) 2024  Bjorn Henrik Formo (bjornhenrikformo@gmail.com)
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
[scriptblock]$DryPkg_SB_BootStrap_PowerShellGet_Get = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory)]
        [system.version]$MinimumModuleVersion
    )

    try {
        $Providers = @(Get-PackageProvider -Name 'PowerShellGet' -ListAvailable -ErrorAction Ignore | Sort-Object -Property 'Version' -Descending -ErrorAction Ignore)

        if ($Providers.count -gt 1) {
            # Multiple PowerShellGet modules found on the system 
            if ($Providers | Where-Object {$_.Version -lt $Providers[0].Version}) {
                # lower versioned PowerShellGet module(s) found on the system
                return $false
            }
            elseif ($Providers[0].Version -ge $MinimumModuleVersion) {
                # multiple, but no lower versioned PowerShellGet module(s) found on the system
                return $true
            }
            else {
                # all PowerShellGet module(s) found on the system are outdated
                return $false
            }
        }
        elseif ($Providers.count -eq 0) {
            # no PowerShellGet module found on the system
            return $false
        }
        elseif ($Providers[0].Version -ge $MinimumModuleVersion) {
            # one PowerShellGet module found on the system, and it's up to date
            return $true
        }
        else {
            # one PowerShellGet module found on the system, but it's aged
            return $false
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        Remove-Module -Name 'PowershellGet' -Force -ErrorAction Ignore -WarningAction SilentlyContinue
    }
}