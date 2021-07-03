param ([string]$usr, [string]$psw)

if ($psw -ne 'root')
  {
  "Login failed for $usr"
  exit 1
  }

#line 1, return groups
'RO;RW'

#returns root elements, always in the format: friendly name,class,type,tags
'ROOT|ROOT|folder|'
