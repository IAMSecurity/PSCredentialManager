
Function Initialize-CredMan{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Path = (Join-Path $env:HOMESHARE "Documents\CredManager.config")
    )
    $Global:CredManConfigPath = $Path
    $Global:CredManConfig = Get-Content $Path  | ConvertFrom-Json -AsHashtable
    $Global:CredManConfig

}
function Set-CredManValue{
    Param(
        $path = (Join-Path $env:HOMESHARE "Documents\CredManager.config") ,
        $Application,
        $Environnment,
        $Key,
        $Value,
        [switch] $isSecureString
    )
    if($isSecureString){   $Value =  $Value | ConvertFrom-SecureString}
    $Config = Initialize-CredMan $path
    if(-not $Config.ContainsKey($Application)){
        $Config.Add($Application , @{$Environment=@{$Key=$Value}})
    }
    if(-not $Config[$Application].ContainsKey($Environment)){
        $Config[$Application].Add($Environment,@{$Key=$Value})
    }
    if(-not $Config[$Application][$Environment].ContainsKey($Key)){
        $config[$Application][$Environment].Add($Key,$Value)
    }
    $config[$Application][$Environment][$Key] = $Value
    $Config  | ConvertTo-Json  |   Out-File $path

}
function Get-CredManValue {
    param (
        [string] $Application,
        [string] $Environment ="PRD",
        [string] $Key,
        $config =  (Initialize-CredMan),
        [switch] $isSecureString,
        [switch] $override


    )
    $returnValue = $null
    if( [string]::IsNullOrEmpty($Config[$Application][$Environment][$Key]) -or $override){
        if($isSecureString){
            $Value =  Read-Host "Fill in the value for $Application\$Environment\$Key" -AsSecureString
        }else{
            $Value =  Read-Host "Fill in the value for $Application\$Environment\$Key"

        }
        Set-CredManValue -Application $application -Environnment $Environment -Key $Key -Value $value -isSecureString:$isSecureString
        $Value

    }else{
        if($isSecureString){
            $Config[$Application][$Environment][$Key] | ConvertTo-SecureString
        }else{
            $Config[$Application][$Environment][$Key]
        }

    }

}

Function Get-CredManCredential {
    <#
    .Synops
    #>
    param (
        [string] $Application,
        [string] $Environment,
        [string] $ConfigUsername = "UserName",
        [string] $ConfigPassword = "Password"

    )

    $Username =  Get-CredManValue -Application $Application -Environment $Environment -Key $ConfigUsername
    $Password =  Get-CredManValue -Application $Application -Environment $Environment -Key $ConfigPassword -isSecret

    if(-not [string]::isnullorEmpty($Username ) -and -not [string]::isnullorEmpty($Password ) ){
        $PasswordSecure = $Password | ConvertTo-SecureString

        New-Object System.Management.Automation.PsCredential($Username,$PasswordSecure)
    }else {
        $Cred = Get-Credential -Title "Credentials for application $application ($environment)"


    }
}
