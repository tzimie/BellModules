param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

$srv = $env:computername
"$srv|PGserver|folder|server=$srv~Conn=Driver={PostgreSQL UNICODE};Server=localhost;Port=5432;Uid=postgres;Pwd=Dm1try00"
