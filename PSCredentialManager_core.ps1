# Implement your module commands in this script.


# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
#Export-ModuleMember -Function *-CredMan*

Function Initialize-CredMan{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Path = (Join-Path $env:HOMESHARE "Documents\CredManager.config")
    )

    $Config = Get-Content $Path  | ConvertFrom-Json -AsHashtable
    $Config

}

function Get-CredManValue {
    param (
        [string] $Application,
        [string] $Environment ="PRD",
        [string] $Property
    )

    $Config = Initialize-CredMan
    if($Config.ContainsKey($application) ){
        if($Config[$Application].ContainsKey($Environment)){
            $Config[$Application][$Environment][$Property]
        }else{
            Write-Warning "Environment not found ($Environment)"

        }

    }else{
        Write-Warning "application not found ($application)"

    }
}


function Get-CredManCredential {
    param (
        [string] $Application,
        [string] $Environment
    )

    $Username =  Get-CredManValue -Application $Application -Environment $Environment -Property "UserName"
    $Password =  Get-CredManValue -Application $Application -Environment $Environment -Property "Password"

    if(-not [string]::isnullorEmpty($Username ) -and -not [string]::isnullorEmpty($Password ) ){
        $PasswordSecure = $Password | ConvertTo-SecureString

        New-Object System.Management.Automation.PsCredential($Username,$PasswordSecure)

    }
}

<#
get-CredManCredential -Application IdentityManager -Environment TST
get-CredManValue -Application IdentityManager -Environment TST Value "UserName"
get-CredManValue -Application IdentityManager -Environment TST Value "Password"

#>