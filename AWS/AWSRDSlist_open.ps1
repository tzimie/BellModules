param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$region = $tagval.Region
$rds = Get-RDSDBInstance -Region $region
foreach ($r in $rds) {
  $cid = $r.DBClusterIdentifier
  $iid = $r.DBInstanceIdentifier
  $engine = $r.EngineVersion
  $cluster = Get-RDSDBCluster -Region $region -DBClusterIdentifier $cid
  $status = $cluster.Status.ToUpper()
  "$iid ($engine) $status|AWSRDS|folder|Region=$region~Cluster=$cid~Id=$iid"
}

