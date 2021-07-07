param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

[datetime] $d1 = $tagval.day
[datetime] $d2 = $d1.AddDays(1)
$cat = Get-Eventlog -LogName Application -EntryType Error -After $d1 -Before $d2  -ComputerName $tagval.server | Group-Object -Property Source -NoElement 
foreach ($i in $cat) {
  "$($i.Name) ($($i.Count))|EvLogReport|html|$tags~cat=$($i.Name)"
}
