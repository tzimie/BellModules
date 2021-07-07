param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/postgreODBC.ps1

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$dsn = $tagval.DSN
$vmid = $tagval.vmid
$range = $tagval.range
$statgroup = ($tagval.stat).Split('.')[0]
$statname = ($tagval.stat).Split('.')[1]
$friendly = $statgroup + '_' + $statname

# machines
$res = ODBCchart $dsn "select sample_time as DT,stat_value as $friendly from vpxv_hist_stat_$range where entity='vm-$vmid' and stat_group='$statgroup' and stat_name='$statname' order by 1"
foreach ($s in $res) {
  "$($s.statname),VMwareChart,chart,$tags;stat=$($s.statname)"
}
