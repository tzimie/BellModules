param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$region = $tagval.Region
$buckets = Get-S3Bucket -Region $region
foreach ($b in $buckets) {
  $name = $b.BucketName
  "$name|AWSbucket|folder|Region=$region~bucket=$name"
}
