param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/ODBC.ps1

parse $tags
$srv = $tagval.server
$conn = $tagval.Conn
$table = $tagval.table

@"
Size and fragmentation|MYSQLfrag|html|$tags
Selectivity|MYSQLselectivity|html|$tags
Index coverage|MYSQLindexing|html|$tags
"@

$d = ODBCquery $conn @"
SELECT COLUMN_NAME,DATA_TYPE 
  FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = database() AND TABLE_NAME = '$table'
    AND (DATA_TYPE LIKE 'date%' or DATA_TYPE = 'timestamp');
"@

foreach ($s in $d) {
  "Chart by column $($s.COLUMN_NAME)|MYSQLtabletime|chart|$tags~col=$($s.COLUMN_NAME)"
}

