param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@  

$region = $tagval.Region
$file = $tagval.file
$bucket = $tagval.bucket

$csv = "Property,Value"
$fileinfo = Get-S3object -Region $region -BucketName $bucket -Key $file
$str = $fileinfo | Out-String
foreach ($ln in $str.Split("`n")) {
  $sem = $ln.Indexof(':')
  if ($sem -lt 1) { continue }
  $l = $ln.Substring(0,$sem-1).Trim()
  $r = $ln.Substring($sem+1).Trim()
  $csv = $csv + "`n" + "$l,$r"
}
$html = $csv | ConvertFrom-Csv | ConvertTo-Html -Title "S3 file" -Head $Header -body '<h2>File properties</h2>' 
$html
