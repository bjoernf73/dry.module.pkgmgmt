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