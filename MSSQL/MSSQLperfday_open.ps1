param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1
parse $tags

$conn = $tagval.Conn -Replace '{sem}', ';' -Replace '{eq}','=' -Replace '{comma}',',' -Replace '{', '''' -Replace '}', '''' 
$day = $tagval.day

@"
SQL ErrorLog|MSSQLerrorlog|text|$tags
"@

$hasREP  = MSSQLscalar $conn "select count(*) as cnt from master.dbo.sysdatabases where name='ReportServer'"
if ($hasREP -gt 0) { 
  "Report Server Data|MSSQLreportserver|html|$tags" 
}
