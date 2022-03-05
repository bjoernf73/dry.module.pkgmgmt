<# 
 This module provides functions for bootstrapping package management, 
 registering package sources and package installations for use with 
 DryDeploy. ModuleConfigs may specify dependencies in it's root config
 that this module processes.

 Copyright (C) 2021  Bjorn Henrik Formo (bjornhenrikformo@gmail.com)
 LICENSE: https://raw.githubusercontent.com/bjoernf73/dry.module.packagemgmt/main/LICENSE
 
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

function Get-DryPkgMgmtBootstrapStatus {
    [CmdletBinding(DefaultParameterSetName = 'Local')]
    param (
        [Parameter(Mandatory, ParameterSetName='Remote')]
        [System.Management.Automation.Runspaces.PSSession] $PSSession,

        [Parameter(ParameterSetName='Remote')]
        [Parameter(ParameterSetName='Local')]
        [Switch] $Force
    )

    try {
        $GetScriptblock = {
            try {
                $DryDeployLocalAppData = "$($env:LOCALAPPDATA)\DryDeploy"
                $ComputerName   = "$($env:COMPUTERNAME)"
                $StatusJsonPath = Join-Path -Path $DryDeployLocalAppData -ChildPath "DryPkgBootstrapStatus-$($ComputerName).json"
                if (-not (Test-Path -Path $DryDeployLocalAppData)) {
                    New-Item -Path $DryDeployLocalAppData -ItemType Directory -Force -ErrorAction Stop | Out-Null
                }
                
                $DefaultPackageMgmtBootstrapStatusJson = @"
                {
                    "Nuget":             false,
                    "PackageManagement": false,
                    "PowerShellGet":     false,
                    "Chocolatey":        false,
                    "Foil":              false,
                    "Git":               false,
                    "GitAutomation":     false
                }
"@       
                If (-not (Test-Path -Path $StatusJsonPath -ErrorAction Continue)) {
                    [PSObject]$PackageManagementBootstrapStatus = $DefaultPackageMgmtBootstrapStatusJson | 
                    ConvertFrom-Json -ErrorAction Stop
                    $PackageManagementBootstrapStatus | 
                        ConvertTo-Json -ErrorAction Stop | 
                        Out-File -FilePath $StatusJsonPath -Force -Encoding Default 
                }
                Else {
                    [PSObject]$PackageManagementBootstrapStatus = Get-Content -Path $StatusJsonPath -Raw -ErrorAction Stop | 
                    ConvertFrom-Json -ErrorAction Stop
                }
                return $PackageManagementBootstrapStatus
            }
            catch {
                return $_
            }
        }

        $InvokeParams = @{
            ScriptBlock  = $GetScriptblock
        }
        if ($PSSession) {
            $InvokeParams += @{
                Session = $PSSession
            }
        }  
        $InvokeResult = Invoke-Command @InvokeParams
        switch ($InvokeResult) {
            { $InvokeResult -is [PSObject] } {
                return $InvokeResult
            }
            { $InvokeResult -is [System.Management.Automation.ErrorRecord] } {
                $PSCmdlet.ThrowTerminatingError($InvokeResult)
            }
            default {
                ol i "The object returned from Invoke-Command is an object of type [$($InvokeResult.gettype().ToString())]"
                Throw "An Error occured $($InvokeResult.ToString())"
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}