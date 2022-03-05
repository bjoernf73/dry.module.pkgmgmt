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

function Save-DryPkgMgmtBootstrapStatus {
    [CmdletBinding(DefaultParameterSetName = 'Local')]
    param (
        [Parameter(Mandatory, ParameterSetName='Remote')]
        [System.Management.Automation.Runspaces.PSSession] $PSSession,

        [Parameter(Mandatory, ParameterSetName='Remote')]
        [Parameter(Mandatory, ParameterSetName='Local')]
        [PSObject]$DryPkgBootstrapStatus
    )

    try {
        $SaveScriptBlock = {
            param(
                [PSObject]$DryPkgBootstrapStatus
            )
            try {
                $DryDeployLocalAppData = "$($env:LOCALAPPDATA)\DryDeploy"
                $ComputerName   = "$($env:COMPUTERNAME)"
                $StatusJsonPath = Join-Path -Path $DryDeployLocalAppData -ChildPath "DryPkgBootstrapStatus-$($ComputerName).json"
                if (-not (Test-Path -Path $DryDeployLocalAppData)) {
                    New-Item -Path $DryDeployLocalAppData -ItemType Directory -Force -ErrorAction Stop | Out-Null
                }
                $DryPkgBootstrapStatus | 
                    ConvertTo-Json -ErrorAction Stop | 
                    Out-File -FilePath $StatusJsonPath -Force -Encoding Default
                return $true
            }
            catch {
                return $_
            }
        }

        $SaveArgumentList = @($DryPkgBootstrapStatus)
        $InvokeParams = @{
            ScriptBlock  = $SaveScriptBlock
            ArgumentList = $SaveArgumentList
        }

        if ($PSCmdlet.ParameterSetName -eq 'Remote') {
            $InvokeParams += @{
                Session = $PSSession
            }
        }  
        $InvokeResult = Invoke-Command @InvokeParams
        
        switch ($InvokeResult) {
            $true {
                ol d "The Bootstrap Status was saved"
            }
            { $InvokeResult -is [System.Management.Automation.ErrorRecord] } {
                $PSCmdlet.ThrowTerminatingError($InvokeResult)
            }
            default {
                ol i "The object returned from Invoke-Command is an object of type [$($InvokeResult.gettype().ToString())]"
                throw "An Error occured $($InvokeResult.ToString())"
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}