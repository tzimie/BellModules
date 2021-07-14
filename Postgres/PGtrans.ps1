param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/pgODBC.ps1
parse $tags

$conn = $tagval.Conn 
$dbid = ODBCint $conn "select oid from pg_database where datname=current_database();"
$q = @"
select 
  now() as DT,
  pg_stat_get_db_xact_commit($dbid) as xact_commit,
  pg_stat_get_db_xact_rollback($dbid) as xact_rollback
"@

$p1 = ODBCquery $conn $q
@"
Line
Live metrics
X - time
Y - Number of transactions
DT,xact_commit,xact_rollback
"@

foreach ($s in $p1) { 
  $xact_commit=$s.xact_commit
  $xact_rollback=$s.xact_rollback
}

for ($lp=0; $lp -lt 30; $lp++) {
  Start-Sleep -Seconds 1
  $p1 = ODBCquery $conn $q
  foreach ($s in $p1) { 
    $dt = $s.DT.ToString('yyyy-MM-ddThh:mm:ss')
    $dxact_commit=$s.xact_commit - $xact_commit
    $dxact_rollback=$s.xact_rollback - $xact_rollback

    $xact_commit=$s.xact_commit
    $xact_rollback=$s.xact_rollback
  }
  "$dt,$dxact_commit,$dxact_rollback"
}

