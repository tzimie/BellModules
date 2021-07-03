param ([string]$usr, [string]$grp, [string]$name, [string]$tags, [int]$execstatus) 

# quietly appends audit log
$dir = [System.Environment]::GetEnvironmentVariable('HOMEPATH')
Add-Content "$dir\bell.log" "$usr|$grp|$name|$tags|$execstatus"
