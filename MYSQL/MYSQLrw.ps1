param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/ODBC.ps1
parse $tags

$conn = $tagval.Conn 
$q = @"
select ifnull(sum(count_fetch),0) as fetches, ifnull(sum(count_write),0) as writes
  from performance_schema.table_io_waits_summary_by_table 
  where object_schema=database();
"@
$p1 = ODBCquery $conn $q

@"
Line
Live metrics
X - time
Y - Fetches and Writes
DT,Fetches,Writes
"@

foreach ($s in $p1) { 
  $fetches=$s.fetches
  $writes=$s.writes
}

for ($lp=0; $lp -lt 30; $lp++) {
  Start-Sleep -Seconds 1
  $p1 = ODBCquery $conn $q
  foreach ($s in $p1) { 
    $dfetches = $s.fetches - $fetches
    $dwrites = $s.writes - $writes
    $fetches = $s.fetches
    $writes = $s.writes
  }
  $dt = (Get-Date).ToString('yyyy-MM-ddThh:mm:ss')
  "$dt,$dfetches,$dwrites"
}

