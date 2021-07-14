param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/pgODBC.ps1
parse $tags

$conn = $tagval.Conn 
$dbid = ODBCint $conn "select oid from pg_database where datname=current_database();"
$q = @"
select 
  now() as DT,
  pg_stat_get_db_blocks_fetched($dbid) as blocks_fetched,
  pg_stat_get_db_blocks_hit($dbid) as blocks_hit
"@

$p1 = ODBCquery $conn $q
@"
Line
Live metrics
X - time
Y - Number of blocks
DT,blocks_fetched,blocks_hit
"@

foreach ($s in $p1) { 
  $blocks_fetched=$s.blocks_fetched
  $blocks_hit=$s.blocks_hit
}

for ($lp=0; $lp -lt 30; $lp++) {
  Start-Sleep -Seconds 1
  $p1 = ODBCquery $conn $q
  foreach ($s in $p1) { 
    $dt = $s.DT.ToString('yyyy-MM-ddThh:mm:ss')
    $dblocks_fetched=$s.blocks_fetched - $blocks_fetched
    $dblocks_hit=$s.blocks_hit - $blocks_hit

    $blocks_fetched=$s.blocks_fetched
    $blocks_hit=$s.blocks_hit
  }
  "$dt,$dblocks_fetched,$dblocks_hit"
}

