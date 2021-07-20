param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$region = $tagval.Region
$bucket = $tagval.bucket
$files = Get-S3object -Region $region -BucketName $bucket
foreach ($f in $files) {
  $name = $f.key
  "$name|AWSfile|html|$tags~file=$name"
}
