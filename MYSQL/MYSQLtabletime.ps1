param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/ODBC.ps1
parse $tags
if (-not $tagval.Conn) { exit }

$conn = $tagval.Conn 
$col = $tagval.col
$table = $tagval.table

@"
Line
Number of records per day for the table $table
X - day
Y - Number of rows
"@

ODBCchart $conn "SELECT cast(``$col`` as date) as DT,count(*) as Count from ``$table`` where $col is not null group by cast(``$col`` as date) order by 1"
