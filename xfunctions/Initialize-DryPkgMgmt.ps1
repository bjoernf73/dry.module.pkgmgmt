<# 
 This module provides functions for bootstrapping package management, 
 registering package sources and package installations for use with 
 DryDeploy. ModuleConfigs may specify dependencies in it's root config
 that this module processes.

 Copyright (C) 2021  Bjorn Henrik Formo (bjornhenrikformo@gmail.com)
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

function Initialize-DryPkgMgmt {
    [CmdletBinding(DefaultParameterSetName = 'Local')]
    param (
        [Parameter(Mandatory,ParameterSetName = 'RemoteCustom')]
        [Parameter(Mandatory,ParameterSetName = 'LocalCustom')]
        [PSObject]$PackageSources,

        [Parameter(Mandatory, ParameterSetName = 'Remote')]
        [Parameter(Mandatory,ParameterSetName = 'RemoteCustom')]
        [System.Management.Automation.Runspaces.PSSession] $PSSession
    )
    
    try {
        ol i 'Initializing DryPkgMgmt' -sh
        ol i 'PkgMgmtInit Parameterset',$PSCmdlet.ParameterSetName
        
        $MinimumVersions = [PSCustomObject]@{
            Nuget             = [System.Version]"2.8.5.208";
            PackageManagement = [System.Version]"1.4.7";
            PowerShellGet     = [System.Version]"2.2.5";
            Chocolatey        = [System.Version]"0.12.0";
            Foil              = [System.Version]"0.1.0";
            Git               = [System.Version]"2.33.1";
            GitAutomation     = [System.Version]"0.14.0" 
        }
        ol i -obj $MinimumVersions -title 'Package Management minimum versions'

        # Common Parameter Set that will be thrown at each function
        $InitDryPkgParams = @{
            MinimumVersions = $MinimumVersions
        }
        if ($PSCmdlet.ParameterSetName -in 'RemoteCustom','LocalCustom') {
            $InitDryPkgParams += @{
                PackageSources = $PackageSources
            }
        }
        if ($PSCmdlet.ParameterSetName -in 'RemoteCustom','Remote') {
            $InitDryPkgParams += @{
                PSSession = $PSSession
            }
        }
        ol d -hash $InitDryPkgParams -title 'Params thrown at every PkgMgmt sub-function'

        # Common params to get and save the status object
        $GetSaveDryPkgMgmtBootstrapStatusParams = @{}
        If ($PSCmdlet.ParameterSetName -in 'Remote','RemoteCustom') {
            $GetSaveDryPkgMgmtBootstrapStatusParams += @{
                PSSession = $PSSession
            }
        }

        # Get the current status object. It tells which components of the bootstrapping is already verified
        $DryPkgMgmtBootstrapStatus = Get-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams
        
        if (($DryPkgMgmtBootstrapStatus.Nuget) -and 
            ($DryPkgMgmtBootstrapStatus.PackageManagement) -and
            ($DryPkgMgmtBootstrapStatus.PowerShellGet) -and
            ($DryPkgMgmtBootstrapStatus.Chocolatey) -and
            ($DryPkgMgmtBootstrapStatus.Foil) -and
            ($DryPkgMgmtBootstrapStatus.Git) -and
            ($DryPkgMgmtBootstrapStatus.GitAutomation)) {

            ol i 'PkgMgmt status','Bootstrapped'
        }
        else {
            ol i 'PkgMgmt status','Requires Bootstrapping'
 
            # Nuget provider
            ol i 'PkgMgmt Status: Nuget-provider',$DryPkgMgmtBootstrapStatus.Nuget
            if (-not ($DryPkgMgmtBootstrapStatus.Nuget)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'Nuget' @InitDryPkgParams
                if ($Status -eq $true) {
                    $DryPkgMgmtBootstrapStatus.Nuget = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    throw 'Failed to install the updated Nuget provider'
                }
            }

            # PackageManagement PowerShell module
            ol i 'PkgMgmt Status: PackageManagement',$DryPkgMgmtBootstrapStatus.PackageManagement
            if (-not ($DryPkgMgmtBootstrapStatus.PackageManagement)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'PackageManagement' @InitDryPkgParams
                if ($Status -eq $true) {
                    $DryPkgMgmtBootstrapStatus.PackageManagement = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    throw 'Failed to install the updated PackageManagement PowerShell module'
                }
            }

            # PowerShellGet PowerShell module
            ol i 'PkgMgmt Status: PowerShellGet',$DryPkgMgmtBootstrapStatus.PowerShellGet
            if (-not ($DryPkgMgmtBootstrapStatus.PowerShellGet)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'PowerShellGet' @InitDryPkgParams
                if ($Status -eq $true) {
                    $DryPkgMgmtBootstrapStatus.PowerShellGet = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    throw 'Failed to install the updated PowerShellGet PowerShell module'
                }
            }

            # Chocolatey PackageManagement
            ol i 'PkgMgmt Status: Chocolatey',$DryPkgMgmtBootstrapStatus.Chocolatey
            if (-not ($DryPkgMgmtBootstrapStatus.Chocolatey)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'Chocolatey' @InitDryPkgParams
                if ($Status -eq $true) {
                    $DryPkgMgmtBootstrapStatus.Chocolatey = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    throw 'Failed to install or upgrade Chocolatey'
                }
            }

            # Foil PowerShell module
            ol i 'PkgMgmt Status: Foil',$DryPkgMgmtBootstrapStatus.Foil
            if (-not ($DryPkgMgmtBootstrapStatus.Foil)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'Foil' @InitDryPkgParams
                if ($Status -eq $true) {
                    $DryPkgMgmtBootstrapStatus.Foil = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    throw 'Failed to install or upgrade the Foil chocolatey helper module'
                }
            }

            # Git Client
            ol i 'PkgMgmt Status: Git',$DryPkgMgmtBootstrapStatus.Git
            if (-not ($DryPkgMgmtBootstrapStatus.Git)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'Git' @InitDryPkgParams
                if ($Status -eq $true) {
                    $DryPkgMgmtBootstrapStatus.Git = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    throw 'Failed to install or upgrade Git client'
                }
            }

            # Git Automation PowerShell module
            ol i 'PkgMgmt Status: GitAutomation',$DryPkgMgmtBootstrapStatus.GitAutomation
            if (-not ($DryPkgMgmtBootstrapStatus.GitAutomation)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'GitAutomation' @InitDryPkgParams
                if ($Status -eq $true) {
                    $DryPkgMgmtBootstrapStatus.GitAutomation = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    throw 'Failed to install or upgrade the GitAutomation PowerShell module'
                }
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}