param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$region = $tagval.Region
$id = $tagval.Id

$logs = Get-RDSDBLogFiles -region $region -DBInstanceIdentifier $id
foreach ($r in $logs) {
  "$($r.LogFileName) ($($r.Size) bytes)|AWSRDSlog|text|$tags~Log=$($r.LogFileName)"
}

