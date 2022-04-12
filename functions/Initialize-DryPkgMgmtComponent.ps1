<# 
 This function makes sure a supported Nuget-provider is installed. The
 function is used to bootstrap proper package management on Windows. 

 Copyright (C) 2022  Bjorn Henrik Formo (bjornhenrikformo@gmail.com)
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

function Initialize-DryPkgMgmtComponent {
    [CmdletBinding(DefaultParameterSetName = 'Local')]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$MinimumVersions,

        [Parameter(Mandatory)]
        [ValidateSet('Nuget','PackageManagement','PowerShellGet','Chocolatey','Foil','ChocolateyGet','Git','GitAutomation','LegacyPackageManagementRemoved')]
        [String]$Component,

        [Parameter(Mandatory,ParameterSetName = 'RemoteCustom')]
        [Parameter(Mandatory,ParameterSetName = 'LocalCustom')]
        [PSObject]$PackageSources,

        [Parameter(Mandatory, ParameterSetName = 'Remote')]
        [Parameter(Mandatory,ParameterSetName = 'RemoteCustom')]
        [System.Management.Automation.Runspaces.PSSession] $PSSession
    )

    try {

        Switch ($Component) {
            {$_ -in 'Foil','GitAutomation'} {
                [scriptblock]$GetScriptblock = Get-Variable -Name "DryPkg_SB_BootStrap_NugetModule_Get" -ValueOnly -ErrorAction Stop
                [scriptblock]$SetScriptblock = Get-Variable -Name "DryPkg_SB_BootStrap_NugetModule_Set" -ValueOnly -ErrorAction Stop
                # Params to Get
                $GetArgumentList = @($MinimumVersions."$Component","$Component")

                # Params to Set
                if ($PSCmdlet.ParameterSetName -in 'LocalCustom','RemoteCustom') {
                    $PackageSource = @{
                        Name = $PackageSourceName
                        Location = $PackageSourceLocation
                    }
                    $SetArgumentList = @($MinimumVersions."$Component",$Component,$PackageSource)
                }
                else {
                    $SetArgumentList = @($MinimumVersions."$Component",$Component)
                }
            }
            Default {
                [scriptblock]$GetScriptblock = Get-Variable -Name "DryPkg_SB_BootStrap_$($Component)_Get" -ValueOnly -ErrorAction Stop
                [scriptblock]$SetScriptblock = Get-Variable -Name "DryPkg_SB_BootStrap_$($Component)_Set" -ValueOnly -ErrorAction Stop
                # Params to Get
                $GetArgumentList = @($MinimumVersions."$Component")
                
                # Params to Set
                if ($PSCmdlet.ParameterSetName -in 'LocalCustom','RemoteCustom') {
                    $PackageSource = @{
                        Name = $PackageSourceName
                        Location = $PackageSourceLocation
                    }
                    $SetArgumentList = @($MinimumVersions."$Component",$PackageSource)
                }
                else {
                    $SetArgumentList = @($MinimumVersions."$Component")
                }
            }
        }

        [bool]$NeedsBootstrap = $false
        
        $GetParams = @{
            ScriptBlock  = $GetScriptblock
            ArgumentList = $GetArgumentList
        }
        if ($PSCmdlet.ParameterSetName -in 'Remote','RemoteCustom') {
            $GetParams += @{
                Session = $PSSession
            }
        }
        $GetResult = Invoke-Command @GetParams

        switch ($GetResult) {
            $true {
                return $true
            }
            $false {
                $NeedsBootstrap = $true
            }
            { $GetResult -is [System.Management.Automation.ErrorRecord] } {
                $PSCmdlet.ThrowTerminatingError($GetResult)
            }
            default {
                throw "DryPkg_SB_BootStrap_$($Component)_Get failed: $($GetResult.ToString())"
            }
        }

        if ($NeedsBootstrap) {
            $SetParams = @{
                ScriptBlock  = $SetScriptblock
                ArgumentList = $SetArgumentList
            }
            if ($PSCmdlet.ParameterSetName -in 'Remote','RemoteCustom') {
                $SetParams += @{
                    Session = $PSSession
                }
            }
            $SetResult = Invoke-Command @SetParams
    
            switch ($SetResult) {
                $true {  
                    return $true  
                }
                { $GetResult -is [System.Management.Automation.ErrorRecord] } { 
                    $PSCmdlet.ThrowTerminatingError($SetResult)
                }
                default { 
                    throw "DryPkg_SB_BootStrap_$($Component)_Set failed: $($SetResult.ToString())" 
                }
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}