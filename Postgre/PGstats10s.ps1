param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/pgODBC.ps1
parse $tags

$Header = @"
<style>
.X-red { color: red; background-color: yellow; }
.X-green { color: green; background-color: white; }
.X-yellow { color: black; background-color: #FFFFE0; }
.X-default { color: black; background-color: white; }
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@  

$conn = $tagval.Conn 
$dbid = ODBCint $conn "select oid from pg_database where datname=current_database();"
$q = @"
select 
  pg_stat_get_db_xact_commit($dbid) as xact_commit,
  pg_stat_get_db_xact_rollback($dbid) as xact_rollback,
  pg_stat_get_db_blocks_fetched($dbid) as blocks_fetched,
  pg_stat_get_db_blocks_hit($dbid) as blocks_hit,
  pg_stat_get_db_tuples_returned($dbid) as tuples_returned,
  pg_stat_get_db_tuples_fetched($dbid) as tuples_fetched,
  pg_stat_get_db_tuples_inserted($dbid) as tuples_inserted,
  pg_stat_get_db_tuples_updated($dbid) as tuples_updated,
  pg_stat_get_db_tuples_deleted($dbid) as tuples_deleted
"@

$p1 = ODBCquery $conn $q
Start-Sleep -Seconds 10
$p2 = ODBCquery $conn $q

$csv = "xact_commit,xact_rollback,blocks_fetched,blocks_hit,tuples_returned,tuples_fetched,tuples_inserted,tuples_updated,tuples_deleted"
foreach ($s in $p1) { 
  $xact_commit=$s.xact_commit
  $xact_rollback=$s.xact_rollback
  $blocks_fetched=$s.blocks_fetched
  $blocks_hit=$s.blocks_hit
  $tuples_returned=$s.tuples_returned
  $tuples_fetched=$s.tuples_fetched
  $tuples_inserted=$s.tuples_inserted
  $tuples_updated=$s.tuples_updated
  $tuples_deleted=$s.tuples_deleted
}
foreach ($s in $p2) { 
  $xact_commit=$s.xact_commit - $xact_commit
  $xact_rollback=$s.xact_rollback - $xact_rollback
  $blocks_fetched=$s.blocks_fetched - $blocks_fetched
  $blocks_hit=$s.blocks_hit - $blocks_hit
  $tuples_returned=$s.tuples_returned - $tuples_returned
  $tuples_fetched=$s.tuples_fetched - $tuples_fetched
  $tuples_inserted=$s.tuples_inserted - $tuples_inserted
  $tuples_updated=$s.tuples_updated - $tuples_updated
  $tuples_deleted=$s.tuples_deleted - $tuples_deleted
}
$csv=$csv + "`n" + "$xact_commit,$xact_rollback,$blocks_fetched,$blocks_hit,$tuples_returned,$tuples_fetched,$tuples_inserted,$tuples_updated,$tuples_deleted"

$html = $csv | ConvertFrom-Csv | ConvertTo-HTML -Title "Rows" -Head $Header -body '<h2>Activity for the last 10 seconds</h2>' 
$html
