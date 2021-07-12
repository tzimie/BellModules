param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/pgODBC.ps1

parse $tags
$srv = $tagval.server
$conn = $tagval.Conn
$schema = $tagval.schema
$table = $tagval.table

@"
Tuple fragmentation|PGfrag|html|$tags
Selectivity|PGselectivity|html|$tags
"@

$d = ODBCquery $conn "SELECT column_name FROM information_schema.columns WHERE table_schema='$schema' and table_name='$table' and data_type like 'time%';"
foreach ($s in $d) {
  "Chart by column $($s.column_name)|PGtabletime|chart|$tags~col=$($s.column_name)"
}