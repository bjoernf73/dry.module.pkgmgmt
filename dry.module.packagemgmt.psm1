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

# scriptblocks to bootstrap package management
$BootStrapScriptBlocksPath = "$PSScriptRoot\bootstrapscriptblocks\*.ps1"
$BootStrapScriptBlocks     = Resolve-Path -Path $BootStrapScriptBlocksPath -ErrorAction Stop
foreach ($BootStrapScriptBlock in $BootStrapScriptBlocks) {
    . $BootStrapScriptBlock.Path
}

# scriptblocks to perform package installations 
$PkgMgmtScriptBlocksPath = "$PSScriptRoot\pkgmgmtscriptblocks\*.ps1"
$PkgMgmtScriptBlocks     = Resolve-Path -Path $PkgMgmtScriptBlocksPath -ErrorAction Stop
foreach ($PkgMgmtScriptBlock in $PkgMgmtScriptBlocks) {
    . $PkgMgmtScriptBlock.Path
}

# internal functions
$InternalFunctionsPath = "$PSScriptRoot\functions\*.ps1"
$InternalFunctions     = Resolve-Path -Path $InternalFunctionsPath -ErrorAction Stop
foreach ($InternalFunction in $InternalFunctions) {
    . $InternalFunction.Path
}

# exported functions
$ExportedFunctionsPath = "$PSScriptRoot\xfunctions\*.ps1"
$ExportedFunctions     = Resolve-Path -Path $ExportedFunctionsPath -ErrorAction Stop
foreach ($ExportedFunction in $ExportedFunctions) {
    . $ExportedFunction.Path
}