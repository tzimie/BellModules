param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/ODBC.ps1

parse $tags
$srv = $tagval.server
$conn = $tagval.Conn

$d = ODBCquery $conn @"
SELECT   
  TABLE_NAME,
  ENGINE,
  ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024) AS SizeMB
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = database();
"@

foreach ($s in $d) {
  $tab = $s.TABLE_NAME
  $sz = $s.SizeMB
  $e = $s.ENGINE
  "$tab ($e) - $sz MB|MYSQLtable|folder|$tags~table=$tab"
}