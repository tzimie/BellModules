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

[datetime] $d1 = $tagval.day
[datetime] $d2 = $d1.AddDays(1)
$cat = Get-Eventlog -LogName Application -EntryType Error -After $d1 -Before $d2 -Source $tagval.cat -ComputerName $tagval.server
$cat = $cat | Select-Object Index,TimeGenerated,EntryType,Message,UserName 
$cat = $cat | Sort-Object -Property "Index"

foreach ($el in $cat) { 
  $el.TimeGenerated = $el.TimeGenerated.ToString("hh:MM:ss")
  }
$html = $cat | ConvertTo-Html -Title "Errors in Event Log" -Head $Header -body '<h2>Sorted by time desc</h2>' 
$html