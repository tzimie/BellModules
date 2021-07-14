param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/ODBC.ps1

parse $tags
$srv = $tagval.server
$conn = $tagval.Conn

@"
Current activity|MYSQLcurrentactivity|html|$tags
Process list|MYSQLprocesslist|html|$tags
Current locks|MYSQLlocks|html|$tags
Questions live 30s|MYSQLquestions|chart|$tags
Error Log|MYSQLperf|folder|$tags
InnoDB data reads/writes 30s|MYSQLdataio|chart|$tags
InnoDB buffer pool reads/writes 30s|MYSQLpoolio|chart|$tags
InnoDB rows operations 30s|MYSQLrows|chart|$tags
"@

$d = ODBCquery $conn @"
SELECT
    table_schema AS 'DB Name',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) AS 'DB Size in MB'
FROM
    information_schema.tables
GROUP BY
    table_schema;
"@

# user databases
foreach ($s in $d) {
  $sz = $s['DB Size in MB']
  $db = $s['DB Name']
  $newtag = $tags -Replace ";Port=", ";Database=$db;Port="
  "db $db - $sz MB|MYSQLdatabase|folder|$newtag~dbname=$db"
}


