param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/pgODBC.ps1

parse $tags
$srv = $tagval.server
$conn = $tagval.Conn

$q = @"
select n.nspname as schema_name, p.proname
  from pg_proc p
  left join pg_namespace n on p.pronamespace = n.oid
  where n.nspname not in ('pg_catalog', 'information_schema') and p.prokind = 'f';
"@

$d = ODBCquery $conn $q

foreach ($s in $d) { 
  $prc = "$($s.schema_name).$($s.proname)"
  "$prc|PGfunc|html|$tags~schema=$($s.schema_name)~proname=$($s.proname)"
}

