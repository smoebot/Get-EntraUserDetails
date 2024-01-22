# Get-EntraUserDetails
Powershell. Gets Entra/Azure AD account details from a provided email address

Given an email address, filters the list of accounts in Azure AD by checking the Mail and UPN fields

_Currently uses the Beta cmdlets, for the V2 Microsoft API_

---

**Parameters**

_Email_

The email address you are searching for.  This should be the primary email, or the UPN

---

**Examples**

```powershell
Get-EntraUserDetails -Email elaine.benes@madeupdomain.com
```
