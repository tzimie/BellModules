param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/pgODBC.ps1

parse $tags
$srv = $tagval.server
$conn = $tagval.Conn


$d = ODBCquery $conn "SELECT schemaname,tablename FROM pg_catalog.pg_tables where schemaname != 'pg_catalog' AND schemaname != 'information_schema';"
foreach ($s in $d) {
  $tab = "$($s.schemaname).$($s.tablename)"
  $sz = ODBCstring $conn "select pg_size_pretty (pg_relation_size('$tab')) as str;"
  "$tab - $sz|PGtable|folder|$tags~schema=$($s.schemaname)~table=$($s.tablename)"
}