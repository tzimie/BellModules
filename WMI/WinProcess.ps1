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
$prc = Get-WmiObject -Class Win32_Process -Computername $srv 
$prc = $prc | Select-Object ProcessId,ProcessName,KernelModeTime,WorkingSetSize,ThreadCount,PageFaults,PageFileUsage 
foreach ($el in $prc) { # to Mb
  $el.WorkingSetSize = [int] ($el.WorkingSetSize/1024/1024)
  $ms = [bigint] ($el.KernelModeTime/1000)
  $el.KernelModeTime = $ms / 1000
  }
$prc = $prc | Sort-Object -Descending -Property "WorkingSetSize"
$html = $prc | ConvertTo-Html -Title "Processes on $srv" -Head $Header -body '<h2>Processes sorted by memory size desc</h2>' 
$html = $html -Replace "WorkingSetSize","WorkingSetSize, Mb"
$html
