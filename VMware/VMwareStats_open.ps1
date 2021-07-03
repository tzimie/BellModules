param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/postgreODBC.ps1

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split(";")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$dsn = $tagval.DSN
$vmid = $tagval.vmid
$range = $tagval.range

# machines
$res = ODBCquery $dsn "select distinct concat(stat_group,'.',stat_name) as statname from vpxv_hist_stat_$range where entity='vm-$vmid' order by 1"
foreach ($s in $res) {
  "$($s.statname),VMwareChart,chart,$tags;stat=$($s.statname)"
}
