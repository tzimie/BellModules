# this is a stub.
# it exposes this machine as MSSQL target, integrated security                                                                         
# In connection strings, = is encoded as {eq} and ; as {sem}

param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

$srv = $env:computername
"$srv|MSSQLserver|folder|Server=$srv~Conn=Server=$srv;Integrated Security=True"
