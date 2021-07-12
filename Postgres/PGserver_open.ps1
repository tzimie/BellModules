param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/pgODBC.ps1

parse $tags
$srv = $tagval.server
$conn = $tagval.Conn

@"
Current activity|PGcurrentactivity|html|$tags
Current locks|PGlocks|html|$tags
Database stats|PGdatabasestats|html|$tags
"@

$d = ODBCquery $conn "select datname from pg_database;"

# user databases
foreach ($s in $d) {
  $newtag = $tags -Replace ";Port=", ";Database=$($s.datname);Port="
  $sz = ODBCstring $conn "SELECT pg_size_pretty( pg_database_size('$($s.datname)')) as str;"
  "db $($s.datname) - $sz|PGdatabase|folder|$newtag~dbname=$($s.name)"
}


