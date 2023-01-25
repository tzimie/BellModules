param ([string]$usr, [string]$grp, [string]$name, [string]$tags, [string]$execstatus) 

# quietly appends audit log
$dir = [System.Environment]::GetEnvironmentVariable('HOMEPATH')
Add-Content "$dir\bell.log" "$usr|$grp|$name|$tags|$execstatus"
