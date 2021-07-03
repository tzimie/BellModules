param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1
parse $tags
if (-not $tagval.Conn) { exit }

$conn = $tagval.Conn 
$dbname = $tagval.dbname
$name = $tagval.name
$col = $tagval.col

@"
Line
Number of records per day for the table $name
X - day
Y - Number of rows
"@

MSSQLchart $conn "SELECT convert(datetime,convert(varchar,[$col],102)) as DT,count(*) as Count from $name where [$col] is not null group by convert(datetime,convert(varchar,[$col],102)) order by 1"
