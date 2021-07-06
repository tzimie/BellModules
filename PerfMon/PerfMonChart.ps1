param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$path = $tagval.path
$machine = $tagval.server

@"
Line
Perfmon chart for $path
X - Time
Y - Value
DT,Value
"@

$c = (Get-Counter -Counter $path -maxSamples 30 -SampleInterval 1 -ComputerName $machine)
foreach ($st in $c.CounterSamples) {
  $dtstr = $st.TimeStamp.ToString('yyyy-MM-ddThh:mm:ss')
  $valstr = $st.CookedValue.ToString('#.##')
  "$dtstr,$valstr"
}
