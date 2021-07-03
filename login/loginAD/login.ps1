param ([string]$usr, [string]$psw) 

# check user credentials
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
if (-not $DS.ValidateCredentials($usr, $psw))
  {
  "Login failed for $usr"
  exit 1
  }

#line 1, return groups
'RO;RW'

#returns root elements, always in the format: friendly name,class,type,tags
'BIMS|BIMS|folder|'

