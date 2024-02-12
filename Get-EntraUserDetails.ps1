function Get-EntraUserDetails {
    <#
    .SYNOPSIS
        Gets Entra/Azure AD account details from a provided email address
    .DESCRIPTION
        Gets Entra/Azure AD account details from a provided email address
        Given an email address, filters the list of accounts in Azure AD by checking the Mail and UPN fields
    .PARAMETER Email
        The email address you are searching for.  This should be the primary email, or the UPN
    .NOTES
        Author: Joel Ashman
        v0.1 - (2023-12-18) Initial version
    .EXAMPLE
        Get-EntraUserDetails -Email elaine.benes@jpetermancatalog.com
    #>

    #requires -version 7

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Email
    )
    # Test if the Beta module is installed
    $BetaInstalled = get-installedmodule "Microsoft.Graph.Beta"
    if ($BetaInstalled.count -eq 0){
        Write-Warning "This function currently uses the V2 API, via the Get-MgBetaUsercmdlet. You need to install the Beta module with:"
        Write-Host -ForegroundColor Cyan "Install-Module Microsoft.Graph.Beta"
    }
    # Function within a function?  Not sure if this is the best way, or if I should be using Process.  In any case, it works.
    function Get-UserInfo{ 
    # Set up the list of Properties that we want retrieved.  We can add more here as needed.  Presented as a list for readability.
        $Properties = @(
            'DisplayName',
            'Id',
            'EmployeeId',
            'EmployeeType',
            'AccountEnabled',
            'UserType',
            'UserPrincipalName',
            'Mail',
            'ImAddress',
            'GivenName',
            'Surname',
            'JobTitle',
            'UsageLocation',
            'OfficeLocation',
            'Department',
            'CompanyName',
            'MobilePhone',
            'BusinessPhones',
            'StreetAddress',
            'City',
            'State',
            'PostalCode',
            'Country',
            'OnPremisesSyncEnabled',
            'OnPremisesDomainName',
            'OnPremisesSamAccountName',
            'OnPremisesSecurityIdentifier',
            'OnPremisesDistinguishedName'
        )

        # Add some calculated properties for the Manager details (Important: The expressions here are case sensitive)
        $AllProperties = $Properties += @{Name = 'Manager'; Expression = {$_.Manager.AdditionalProperties.displayName}}, @{Name = 'ManagerEmail'; Expression = {$_.Manager.AdditionalProperties.mail}}, @{Name = 'ManagerUserPrincipalName'; Expression = {$_.Manager.AdditionalProperties.userPrincipalName}}, @{Name = 'ManagerIM'; Expression = {$_.Manager.AdditionalProperties.imAddresses}}

        # Grab the user details via the Mail or UserPrincipalName properties in AzureAD, then calculate the properties for the Manager, and store it all as a variable
        #$UserInfo = Get-MgUser -Filter "Mail eq '$($Email)' or UserPrincipalName eq '$($Email)'" -Property $properties -ExpandProperty Manager | Select-Object $AllProperties
        $UserInfo = Get-MgBetaUser -Filter "Mail eq '$($Email)' or UserPrincipalName eq '$($Email)'" -Property $properties -ExpandProperty Manager | Select-Object $AllProperties
      
        # Display User detail to console.  This is an object, so we can tweak it to pass properties to the pipeline
        $UserInfo
    }

    # Check if the user is connected to Microsoft Graph first
    $ConnectedCheck = Get-MgContext

    if($ConnectedCheck -eq $null){
        Write-Host -ForegroundColor Yellow "Not connected to MS Graph API"

        # If there's no connection to Microsoft Graph, connect, prompt for auth, then run as normal
        try{
            Write-Host -ForegroundColor Cyan "Running Connect-Graph cmdlet and attempting authentication.  Use Sys account"
            Connect-Graph
            Get-UserInfo
        }
        # Bail out if we didn't authenticate properly
        catch{
            Write-Host -ForegroundColor Red "Something went wrong.  Not authenticated to MS Graph API.  Exiting"
        }
    }

    # If we are already authenticated, then run as normal
    else{
        Write-Host -ForegroundColor Green "Connected to MS Graph API"
        Write-Host -ForegroundColor Cyan "Authentication Type: $($ConnectedCheck.AuthType)"
        Get-UserInfo        
    }
 }
