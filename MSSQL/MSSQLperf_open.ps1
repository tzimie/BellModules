param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1
parse $tags

for ($d=0; $d -lt 7; $d++) {
  $day = (Get-Date).AddDays(-$d)
  $dayfmt = $day.toString("yyyy-MM-dd")
  $dayname = $dayfmt
  if ($d -eq 0) { $dayname = "$dayname (Today)" }
  if ($d -eq 1) { $dayname = "$dayname (Yesterday)" }
  "$dayname|MSSQLperfday|folder|$tags~day=$dayfmt~daysback=$d"
}
