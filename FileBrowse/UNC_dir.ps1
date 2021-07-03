# this folder element opens directories recursively
# current directory is in tag called dir
# user can view directories, and files with extensions log txt config xml, but not the other ones
# files smaller 30000 bytes can be viewed, larger can be downloaded

param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$dir = $tagval.dir
$listdir = $dir
if ($dir[-1] -eq ':') { $listdir = $dir + '\' }
$res = Get-ChildItem $listdir | Select Length,Name
foreach ($f in $res) {
  $fname = $f.Name
  if ($f.Length -eq $null) { "$fname|UNC|folder|$tags\$fname" }
  else { 
    $ext = $fname.Split('.')[-1]
    if ($ext -eq $null) { $ext = '' }
    $ext = $ext.ToLower()
    if ($ext -eq 'log' -or $ext -eq 'txt' -or $ext -eq 'config' -or $ext -eq 'xml') {
      if ($f.Length -gt 30000) { Write-Host "$fname|UNCdownload|file|$tags\$fname" }
      elseif ($ext -eq 'config' -or $ext -eq 'xml') { 
        Write-Host "$fname|UNCviewxml|html|$tags\$fname" 
      } else { Write-Host "$fname|UNCviewtext|text|$tags\$fname" }
    }
  }
}
