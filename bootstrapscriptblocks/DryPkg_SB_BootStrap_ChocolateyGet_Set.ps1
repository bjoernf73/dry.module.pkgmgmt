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
[scriptblock]$DryPkg_SB_BootStrap_ChocolateyGet_Set = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory,HelpMessage="At the time of writing, this is 4.0.0.0")]
        [system.version]$MinimumProviderVersion,

        [Parameter(HelpMessage="If using an in-house ChocolateyGet source, a hashtable containing the  
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
                # Register-PackageSource -Name MyChocolateyGet -Location https://www.ChocolateyGet.org/api/v2 -ProviderName ChocolateyGet
                Register-PackageSource @PackageSourceParams -ErrorAction 'Stop' -ProviderName 'nuget' | Out-Null
            }
        }
        Set-PackageSource -Name $PackageSourceName -Trusted -ErrorAction 'Stop' | Out-Null
        Install-PackageProvider -Name 'ChocolateyGet' -MinimumVersion $MinimumProviderVersion -Scope AllUsers -Source $PackageSourceName -Confirm:$false -Force | Out-Null
        return $true
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}