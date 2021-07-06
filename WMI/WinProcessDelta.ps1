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
$old = Get-WmiObject -Class Win32_Process -Computername $srv 
$old = $old | Select-Object ProcessId,KernelModeTime,PageFaults 
$oldcpu = @{}
$oldpf = @{}
foreach ($el in $old) {
  $oldcpu[$el.ProcessId] = $el.KernelModeTime
  $oldpf[$el.ProcessId] = $el.PageFaults
  }

Start-Sleep -Seconds 10

$prc = Get-WmiObject -Class Win32_Process -Computername $srv 
$prc = $prc |  Select-Object ProcessId,ProcessName,KernelModeTime,WorkingSetSize,ThreadCount,PageFaults,PageFileUsage
foreach ($el in $prc) { # to Mb
  $el.WorkingSetSize = [int] ($el.WorkingSetSize/1024/1024)
  $olde = $oldcpu[$el.ProcessId]
  if ($olde -ne $Null) { $el.KernelModeTime = $el.KernelModeTime - $olde }
  $ms = [bigint] ($el.KernelModeTime/1000)
  $el.KernelModeTime = $ms / 1000
  $olde = $oldpf[$el.ProcessId]
  if ($olde -ne $Null) { $el.PageFaults = $el.PageFaults - $olde }
  }
$prc = $prc | Where-Object {$_.ProcessId -gt 0 -and $_.KernelModeTime -gt 0} 
$prc = $prc | Sort-Object -Descending -Property "KernelModeTime"
$html = $prc | ConvertTo-Html -Title "Processes on $srv - CPU delta" -Head $Header -body '<h2>Processes sorted by (CPU delta) desc</h2>' 
$html = $html -Replace "WorkingSetSize","WorkingSetSize, Mb"
$html = $html -Replace "KernelModeTime","CPU for 10 seconds"
$html = $html -Replace "PageFaults","PageFaults Delta"
$html
