param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/ODBC.ps1

parse $tags
$srv = $tagval.server
$conn = $tagval.Conn

$q = @"
SELECT routine_name FROM information_schema.routines
  WHERE  routine_type = 'FUNCTION'
    AND routine_schema = database();
"@

$d = ODBCquery $conn $q

foreach ($s in $d) { 
  $prc = "$($s.routine_name)"
  "$prc|MYSQLfunc|html|$tags~proname=$prc"
}

