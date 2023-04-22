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
[scriptblock]$DryPkg_SB_BootStrap_NugetModule_Set = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory)]
        [system.version]$MinimumModuleVersion,

        [Parameter(Mandatory)]
        [string]$Module,

        [Parameter(HelpMessage="If using an in-house nuget source, a hashtable containing the  
        params Name and Location of the PackageProvider. I'll provide the rest of the params  
        to splat to Register-PackageSource. If not present, I'll be using PSGallery")]
        [hashtable]$PackageSource
    )

    try {
        [string]$PackageSourceName = 'PSGallery'
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        
        if ($PackageSource) {
            [String]$PackageSourceName = $PackageSource["Name"]
            if (-not (Get-PackageSource -Name $PackageSourceName -ErrorAction 'SilentlyContinue')) {
                # Register-PackageSource -Name MyNuGet -Location https://www.nuget.org/api/v2 -ProviderName NuGet
                $PackageSource['ErrorAction'] = 'Stop'
                if ($null -eq $PackageSource['ProviderName']) { $PackageSource['ProviderName'] = 'Nuget' }
                if ($null -eq $PackageSource['Trusted'])      { $PackageSource['Trusted'] = $true }
                Register-PackageSource @PackageSource | Out-Null
            }
        }
        $Modules = @(Get-Module -Name $Module -ListAvailable -ErrorAction Stop | Sort-Object -Property 'Version' -Descending -ErrorAction Stop)
        if ($Modules[0].Version -lt $MinimumModuleVersion) {
            $InstallModuleParams = @{
                Name           = $Module 
                MinimumVersion = $MinimumModuleVersion
                Scope          = 'AllUsers'
                AllowClobber   = $true 
                Repository     = $PackageSourceName 
                Confirm        = $false
                Force          = $true
            }
            Install-Module @InstallModuleParams | Out-Null
        }
        
        $Modules = @(Get-Module -Name $Module -ListAvailable -ErrorAction Stop | Sort-Object -Property 'Version' -Descending -ErrorAction Stop)
        $ModulesToRemove = $Modules | Where-Object { 
            $_.Version -lt $Modules[0].Version
        }
        Remove-Module -Name $Module -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        foreach ($ModuleToRemove in $ModulesToRemove) {
            Remove-Item -Path (Split-Path -Path $ModuleToRemove.Path) -Recurse -Force -Confirm:$false
        }
        return $true
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}