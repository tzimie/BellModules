param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

$srv = $env:computername
"$srv|MYSQLserver|folder|server=$srv~Conn=Driver={MySQL ODBC 8.0 Unicode Driver};Server=localhost;Port=3306;Uid=root;Pwd=###mypassword###"
