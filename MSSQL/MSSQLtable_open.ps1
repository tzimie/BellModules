param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1
parse $tags
if (-not $tagval.Conn) { exit }

$conn = $tagval.Conn 
$dbname = $tagval.dbname
$name = $tagval.name

$d = MSSQLquery $conn "SELECT name FROM syscolumns where id=object_id('$name') and xtype=61"
foreach ($s in $d) {
  "Chart by column $($s.name)|MSSQLtabletime|chart|$tags~col=$($s.name)"
}

@"
Fragmentation report|MSSQLfrag|html|$tags
Column selectivity report|MSSQLselectivity|html|$tags
"@
