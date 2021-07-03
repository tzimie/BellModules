param ([string]$usr, [string]$grp, [string]$name, [string]$tags, [int]$execstatus) 

# quietly appends audit log
$cmd = "sqlcmd -S BellAuditServer -E -d BellAuditDb -Q ""exec DoAudit '$usr','$grp','$name','$tags','$execstatus'"" "
Invoke-Expression $cmd
