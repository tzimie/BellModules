param ([string]$usr, [string]$psw) 

# check user credentials
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
if (-not $DS.ValidateCredentials($usr, $psw))
  {
  "Login failed for $usr"
  exit 1
  }

# this is our company specific rules - replace !!!!!!!!!!!
$admins = ('Admins')
$allowedSQLmodifs = ('SQLDBA','IT guys')
$allowedSQLreadonly = ('Development','Consulters')
$IT = '' # Can do anything
$RW = '' # can do all ops 
$RO = '' # can query

# Get all groups where user belongs
$res = Get-ADPrincipalGroupMembership -Server 'company.com' -identity $usr # replace here company.com !!!!!!!!!!!!!!!
foreach ($g in $res) {
  if ($g.name -in $admins)             { $IT = 'Y' }
  if ($g.name -in $allowedSQLmodifs)   { $RW = 'Y' }
  if ($g.name -in $allowedSQLreadonly) { $RO = 'Y' }
  }
$groups = 'guest'
if ($RW -eq 'Y') { $groups = $groups + ';RW' }
if ($RO -eq 'Y' -or $RW -eq 'Y') { $groups = $groups + ';RO' }
if ($IT -eq 'Y') { $groups = 'RO;RW;IT' }

#line 1, return groups
$groups

#returns root elements, always in the format: friendly name,class,type,tags
'ROOT|ROOT|folder|'

