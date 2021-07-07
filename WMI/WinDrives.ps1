param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$Header = @"
<style>
.X-red { color: red; background-color: yellow; }
.X-green { color: green; background-color: white; }
.X-yellow { color: black; background-color: #FFFFE0; }
.X-default { color: black; background-color: white; }
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@  

$srv = $tagval.Server
$res = get-wmiobject -class win32_logicaldisk -ComputerName $srv
$csv = 'Drive,Size Gb,Used Gb,Free Gb,PctFree'
foreach ($item in $res) {
  $drive = $item.DeviceID
  if ($item.FreeSpace -eq $null) { continue }
  $free = $item.FreeSpace / 1024 / 1024. / 1024.
  $size = $item.Size / 1024 / 1024. / 1024.
  $pct = 100. * $free/$size
  $csv = $csv + "`n$drive," + $size.ToString("#.##") + ',' + ($size-$free).ToString("#.##") + ',' + $free.ToString("#.##") + ',' 
  if ($pct -lt 10.) { $csv = $csv + '{red}' }
  elseif ($pct -lt 15.) { $csv = $csv + '{yellow}' }
  $csv = $csv + $pct.ToString('##')+'%'
}
$html = $csv | ConvertFrom-Csv | ConvertTo-Html -Title "Services" -Head $Header -body '<h2>Server Drive Information</h2>' 
$html = $html -Replace '<td>{(.*?)}', '<td class="X-$1">'
$html
