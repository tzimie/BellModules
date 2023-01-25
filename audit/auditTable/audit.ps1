param ([string]$usr, [string]$grp, [string]$name, [string]$tags, [string]$execstatus) 

# quietly appends audit log
$execstatus = $execstatus.replace("'","''")
$cmd = "sqlcmd -S ReplaceServer -E -d BellAuditDb -Q ""exec DoAudit '$usr','$grp','$name','$tags','$execstatus'"" "
Invoke-Expression $cmd
