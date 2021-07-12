param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/pgODBC.ps1
parse $tags
if (-not $tagval.Conn) { exit }

$conn = $tagval.Conn 
$col = $tagval.col
$schema = $tagval.schema
$table = $tagval.table

@"
Line
Number of records per day for the table $schema.$table
X - day
Y - Number of rows
"@

ODBCchart $conn "SELECT $col::date as DT,count(*) as Count from $schema.$table where $col is not null group by $col::date order by 1"
