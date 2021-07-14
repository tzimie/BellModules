param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/pgODBC.ps1
parse $tags

$conn = $tagval.Conn 
$dbid = ODBCint $conn "select oid from pg_database where datname=current_database();"
$q = @"
select 
  now() as DT,
  pg_stat_get_db_tuples_returned($dbid) as tuples_returned,
  pg_stat_get_db_tuples_fetched($dbid) as tuples_fetched,
  pg_stat_get_db_tuples_inserted($dbid) as tuples_inserted,
  pg_stat_get_db_tuples_updated($dbid) as tuples_updated,
  pg_stat_get_db_tuples_deleted($dbid) as tuples_deleted
"@

$p1 = ODBCquery $conn $q
@"
Line
Live metrics
X - time
Y - Number of tuples
DT,tuples_returned,tuples_fetched,tuples_inserted,tuples_updated,tuples_deleted
"@

foreach ($s in $p1) { 
  $tuples_returned=$s.tuples_returned
  $tuples_fetched=$s.tuples_fetched
  $tuples_inserted=$s.tuples_inserted
  $tuples_updated=$s.tuples_updated
  $tuples_deleted=$s.tuples_deleted
}

for ($lp=0; $lp -lt 30; $lp++) {
  Start-Sleep -Seconds 1
  $p1 = ODBCquery $conn $q
  foreach ($s in $p1) { 
    $dt = $s.DT.ToString('yyyy-MM-ddThh:mm:ss')
    $dtuples_returned=$s.tuples_returned - $tuples_returned
    $dtuples_fetched=$s.tuples_fetched - $tuples_fetched
    $dtuples_inserted=$s.tuples_inserted - $tuples_inserted
    $dtuples_updated=$s.tuples_updated - $tuples_updated
    $dtuples_deleted=$s.tuples_deleted - $tuples_deleted

    $tuples_returned=$s.tuples_returned
    $tuples_fetched=$s.tuples_fetched
    $tuples_inserted=$s.tuples_inserted
    $tuples_updated=$s.tuples_updated
    $tuples_deleted=$s.tuples_deleted
  }
  "$dt,$dtuples_returned,$dtuples_fetched,$dtuples_inserted,$dtuples_updated,$dtuples_deleted"
}

