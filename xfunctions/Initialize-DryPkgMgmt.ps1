Using NameSpace System.Management.Automation
<# 
 This module provides functions for bootstrapping package management, 
 registering package sources and package installations for use with 
 DryDeploy. ModuleConfigs may specify dependencies in it's root config
 that this module processes.

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

function Initialize-DryPkgMgmt {
    [CmdletBinding(DefaultParameterSetName = 'Local')]
    param (
        [Parameter(Mandatory,ParameterSetName = 'RemoteCustom')]
        [Parameter(Mandatory,ParameterSetName = 'LocalCustom')]
        [PSObject]$PackageSources,

        [Parameter(Mandatory, ParameterSetName = 'Remote')]
        [Parameter(Mandatory,ParameterSetName = 'RemoteCustom')]
        [String]$Computername,

        [Parameter(Mandatory, ParameterSetName = 'Remote')]
        [Parameter(Mandatory,ParameterSetName = 'RemoteCustom')]
        [PSCredential]$Credential,

        [Parameter(Mandatory, ParameterSetName = 'Remote')]
        [Parameter(Mandatory,ParameterSetName = 'RemoteCustom')]
        [PSObject]$SessionConfig
    )
    
    try {
        ol i 'Initializing DryPkgMgmt' -sh
        ol v 'PkgMgmtInit Parameterset',$PSCmdlet.ParameterSetName
        
        $MinimumVersions = [PSCustomObject]@{
            Nuget             = [System.Version]"2.8.5.208"
            PackageManagement = [System.Version]"1.4.7"
            PowerShellGet     = [System.Version]"2.2.5"
            Chocolatey        = [System.Version]"0.12.0"
            Foil              = [System.Version]"0.1.0"
            ChocolateyGet     = [System.Version]"4.0.0.0"
            Git               = [System.Version]"2.33.1"
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
            $NewDrySessionParams = @{
                ComputerName  = $Computername
                Credential    = $Credential
                SessionConfig = $SessionConfig
                SessionType   = 'PSSession'
            }
            $PSSession = New-DrySession @NewDrySessionParams
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
            ($DryPkgMgmtBootstrapStatus.ChocolateyGet) -and
            ($DryPkgMgmtBootstrapStatus.Git) -and
            ($DryPkgMgmtBootstrapStatus.GitAutomation)) {

            ol i 'PkgMgmt status','Bootstrapped'
        }
        else {
            ol i 'PkgMgmt status','Requires Bootstrapping'
 
            # Nuget provider
            if (-not ($DryPkgMgmtBootstrapStatus.Nuget)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'Nuget' @InitDryPkgParams
                if ($Status -eq $true) {
                    ol i 'Updating Nuget Provider','Success' -fore Green
                    $DryPkgMgmtBootstrapStatus.Nuget = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    ol i 'Updating Nuget Provider','Failed' -fore Red
                    throw 'Failed to update Nuget provider'
                }
            }
            else {
                ol i 'Updating Nuget Provider','Already OK' -fore Green
            }

            # PackageManagement PowerShell module
            if (-not ($DryPkgMgmtBootstrapStatus.PackageManagement)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'PackageManagement' @InitDryPkgParams
                if ($Status -eq $true) {
                    ol i 'Updating PackageManagement','Success' -fore Green
                    $DryPkgMgmtBootstrapStatus.PackageManagement = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    ol i 'Updating PackageManagement','Failed' -fore Red
                    throw 'Failed to install the updated PackageManagement PowerShell module'
                }
            }
            else {
                ol i 'Updating PackageManagement','Already OK' -fore Green
            }

            # Remove Legacy PackageManagement PowerShell module
            if (-not ($DryPkgMgmtBootstrapStatus.LegacyPackageManagementRemoved)) {
                If ($PSCmdlet.ParameterSetName -in 'Remote','RemoteCustom') {
                    $PSSession | Remove-PSSession -Confirm:$false
                    $InitDryPkgParams['PSSession'] = New-DrySession @NewDrySessionParams
                    $GetSaveDryPkgMgmtBootstrapStatusParams['PSSession'] = $InitDryPkgParams['PSSession']
                }
                
                $Status = Initialize-DryPkgMgmtComponent -Component 'LegacyPackageManagementRemoved' @InitDryPkgParams
                if ($Status -eq $true) {
                    ol i 'Remove Legacy PackageManagement','Success' -fore Green
                    $DryPkgMgmtBootstrapStatus.PackageManagement = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    ol i 'Remove Legacy PackageManagement','Failed' -fore Red
                    throw 'Failed to Remove Legacy PackageManagement'
                }
            }
            else {
                ol i 'Remove Legacy PackageManagement','Already OK' -fore Green
            }

            # PowerShellGet PowerShell module
            if (-not ($DryPkgMgmtBootstrapStatus.PowerShellGet)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'PowerShellGet' @InitDryPkgParams
                if ($Status -eq $true) {
                    ol i 'Updating PowershellGet','Success' -fore Green
                    $DryPkgMgmtBootstrapStatus.PowerShellGet = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    ol i 'Updating PowershellGet','Failed' -fore Red
                    throw 'Failed to install the updated PowerShellGet PowerShell module'
                }
            }
            else {
                ol i 'Updating PowershellGet','Already OK' -fore Green
            }

            # Chocolatey choco.exe
            if (-not ($DryPkgMgmtBootstrapStatus.Chocolatey)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'Chocolatey' @InitDryPkgParams
                if ($Status -eq $true) {
                    ol i 'Installing Chocolatey','Success' -fore Green
                    $DryPkgMgmtBootstrapStatus.Chocolatey = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    ol i 'Installing Chocolatey','Failed' -fore Red
                    throw 'Failed to install or upgrade Chocolatey'
                }
            }
            else {
                ol i 'Installing Chocolatey','Already OK' -fore Green
            }

            # Foil PowerShell module
            if (-not ($DryPkgMgmtBootstrapStatus.Foil)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'Foil' @InitDryPkgParams
                if ($Status -eq $true) {
                    ol i 'Installing Foil','Success' -fore Green
                    $DryPkgMgmtBootstrapStatus.Foil = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    ol i 'Installing Foil','Failed' -fore Red
                    throw 'Failed to install or upgrade the Foil chocolatey helper module'
                }
            }
            else {
                ol i 'Installing Foil','Already OK' -fore Green
            }

            # PowershellGet Package Provider
            if (-not ($DryPkgMgmtBootstrapStatus.ChocolateyGet)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'ChocolateyGet' @InitDryPkgParams
                if ($Status -eq $true) {
                    ol i 'Installing ChocolateyGet','Success' -fore Green
                    $DryPkgMgmtBootstrapStatus.ChocolateyGet = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    ol i 'Installing ChocolateyGet','Failed' -fore Red
                    throw 'Failed to install or upgrade the Foil chocolatey helper module'
                }
            }
            else {
                ol i 'Installing ChocolateyGet','Already OK' -fore Green
            }

            # Git Client
            if (-not ($DryPkgMgmtBootstrapStatus.Git)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'Git' @InitDryPkgParams
                if ($Status -eq $true) {
                    ol i 'Installing Git Client','Success' -fore Green
                    $DryPkgMgmtBootstrapStatus.Git = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    ol i 'Installing Git Client','Failed' -fore Red
                    throw 'Failed to install or upgrade Git client'
                }
            }
            else {
                ol i 'Installing Git Client','Already OK' -fore Green
            }

            # Git Automation PowerShell module
            if (-not ($DryPkgMgmtBootstrapStatus.GitAutomation)) {
                $Status = Initialize-DryPkgMgmtComponent -Component 'GitAutomation' @InitDryPkgParams
                if ($Status -eq $true) {
                    ol i 'Installing GitAutomation','Success' -fore Green
                    $DryPkgMgmtBootstrapStatus.GitAutomation = $true
                    Save-DryPkgMgmtBootstrapStatus @GetSaveDryPkgMgmtBootstrapStatusParams -DryPkgBootstrapStatus $DryPkgMgmtBootstrapStatus
                }
                else {
                    ol i 'Installing GitAutomation','Failed' -fore Red
                    throw 'Failed to install or upgrade the GitAutomation PowerShell module'
                }
            }
            else {
                ol i 'Installing GitAutomation','Already OK' -fore Green
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}