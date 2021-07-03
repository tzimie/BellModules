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

$srv = $tagval.server
$flt = $tagval.filter
$res = Get-Service -ComputerName $srv
$csv = 'Status,Startup,Name,DisplayName'
foreach ($item in $res) {
  $run = Get-Service $item.Name -ComputerName $srv
  $startup = $run.StartType
  if ($flt -eq "Running" -and $item.Status -ne "Running") { continue }
  if ($flt -eq "Stopped" -and $item.Status -ne "Stopped") { continue }
  if ($flt -eq "Automatic" -and $startup -ne "Automatic") { continue }
  if ($flt -eq "Manual" -and $startup -ne "Manual") { continue }
  if ($flt -eq "Disabled" -and $startup -ne "Disabled") { continue }
  if ($flt -eq "AutoStopped" -and -not ($startup -eq "Automatic" -and $item.Status -eq "Stopped")) { continue }
  $csv = $csv + "`n" + $item.Status + ',' + $startup + ',' + $item.Name + ',' + $item.DisplayName
}
$html = $csv | ConvertFrom-Csv | ConvertTo-Html -Title "Services" -Head $Header -body '<h2>Service information</h2>' 
$html
