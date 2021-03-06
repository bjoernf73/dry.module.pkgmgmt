try {
    $target   = '10.0.13.20'
    $UserName = 'utv\server-admin'
    $pw = "VerySecret123456!"
    [SecureString]$SecStringPassword = ConvertTo-SecureString $pw -AsPlainText -Force
    [PSCredential]$Credential  = New-Object System.Management.Automation.PSCredential ($UserName, $SecStringPassword)

    if (($Null -ne $PSScriptRoot) -And (Test-Path -Path $PSScriptRoot -ErrorAction 'Ignore')) {
        $ScriptPath = $PSScriptRoot
    }
    elseif ((Split-Path -Path $MyInvocation.MyCommand.Path) -match "^[a-zA-Z]\:\\") {
        $ScriptPath = Split-Path -Path $MyInvocation.MyCommand.Path
    }
    else {
        throw 'Unable to determine script path'
    }

    $OriginalPSModulePath = $env:PSModulePath
    # get DryDeploy's modules into ENV:PSModulePath
    $LocalModulesDirectory = [IO.Path]::GetFullPath("$ScriptPath\..")
    if ($env:PSModulePath -notmatch ($LocalModulesDirectory -replace'\\','\\')) {
        $env:PSModulePath = "$($env:PSModulePath);$LocalModulesDirectory" 
    }

    Import-Module -Name "$ScriptPath\dry.module.pkgmgmt.psd1" -Force -ErrorAction Stop

    <#
        $SessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
        $PSSession = New-PSSession -ComputerName $target -Credential $Credential -UseSSL -SessionOption $SessionOption
    #>
    $SessionConfig = New-Object -TypeName PSobject -Property @{
        UseSSL = $true
    }

    Initialize-DryPkgMgmt -ComputerName $target -Credential $Credential -SessionConfig $SessionConfig
}
catch {
    throw $_
}
finally {
    # Reset PSModulePath
    $env:PSModulePath = $OriginalPSModulePath
    Get-PSSession | Remove-PSSession
    foreach ($DryModule in  @((Get-Module | 
        Where-Object { (($_.Name -match "^dry\.action\.") -or ($_.Name -match "^dry\.module\."))}) | 
        Select-Object Name).Name) {
        Get-Module $DryModule | Remove-Module -Verbose:$False -Force -ErrorAction Ignore
    }
}