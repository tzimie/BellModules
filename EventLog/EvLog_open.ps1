param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

for ($d=0; $d -lt 7; $d++) {
  $day = (Get-Date).AddDays(-$d)
  $dayfmt = $day.toString("yyyy-MM-dd")
  $dayname = $dayfmt
  if ($d -eq 0) { $dayname = "$dayname (Today)" }
  if ($d -eq 1) { $dayname = "$dayname (Yesterday)" }
  "$dayname|EvLogDay|folder|$tags~day=$dayfmt~daysback=$d"
}
