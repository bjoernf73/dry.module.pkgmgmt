[scriptblock]$DryPkg_SB_BootStrap_PackageManagement_Get = {
    [CmdLetBinding()]
    [OutputType([Boolean],[System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory)]
        [system.version]$MinimumModuleVersion
    )

    try {
        $Modules = @(Get-Module -Name 'PackageManagement' -ListAvailable -ErrorAction Ignore | Sort-Object -Property 'Version' -Descending -ErrorAction Ignore)

        if ($Modules.count -gt 1) {
            # Multiple PackageManagement modules found on the system 
            if ($Modules | Where-Object {$_.Version -lt $Modules[0].Version}) {
                # lower versioned PackageManagement module(s) found on the system
                return $false
            }
            elseif ($Modules[0].Version -ge $MinimumModuleVersion) {
                # multiple, but no lower versioned PackageManagement module(s) found on the system
                return $true
            }
            else {
                # all PackageManagement module(s) found on the system are outdated
                return $false
            }
        }
        elseif ($Modules.count -eq 0) {
            # no PackageManagement module found on the system
            return $false
        }
        elseif ($Modules[0].Version -ge $MinimumModuleVersion) {
            # one PackageManagement module found on the system, and it's up to date
            return $true
        }
        else {
            # one PackageManagement module found on the system, but it's aged
            return $false
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}