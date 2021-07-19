param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$region = $tagval.Region
$id = $tagval.Id
$log = $tagval.Log

$log = Get-RDSDBLogFilePortion -region $region -DBInstanceIdentifier $id -logFilename $log -NoAutoIteration
foreach ($r in $log) {
  $r.LogFileData
}

