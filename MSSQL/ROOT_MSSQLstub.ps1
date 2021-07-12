# this is a stub.
# it exposes this machine as MSSQL target, integrated security                                                                         

param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

$srv = $env:computername
"$srv|MSSQLserver|folder|Server=$srv~Conn=Server=$srv;Integrated Security=True"
