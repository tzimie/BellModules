# this is a stub.
# it exposes this machine as WMI target

param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

$srv = $env:computername
"$srv|WinServer|folder|server=$srv"
