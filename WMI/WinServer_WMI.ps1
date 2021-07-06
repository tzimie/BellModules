param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

@"
Services Running|WinServices|html|$tags~filter=Running
Services Stopped|WinServices|html|$tags~filter=Stopped
Services Automatic|WinServices|html|$tags~filter=Automatic
Services Manual|WinServices|html|$tags~filter=Manual
Services Disabled|WinServices|html|$tags~filter=Disabled
Services Automatic Stopped|WinServices|html|$tags~filter=AutoStopped
Disk Drives|WinDrives|html|$tags
Process List|WinProcess|html|$tags
Process CPU delta|WinProcessDelta|html|$tags
"@  

