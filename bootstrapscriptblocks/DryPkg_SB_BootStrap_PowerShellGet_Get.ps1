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