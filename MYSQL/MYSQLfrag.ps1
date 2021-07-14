param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/ODBC.ps1
parse $tags
if (-not $tagval.Conn) { exit }

$conn = $tagval.Conn 
$table = $tagval.table

$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

$q = @"
select  
  ENGINE, 
  Round( DATA_LENGTH/1024/1024) as data_length, 
  round(INDEX_LENGTH/1024/1024) as index_length, 
  round(DATA_FREE/ 1024/1024) as data_free,
  (data_free/(index_length+data_length)) as frag_ratio
  from information_schema.tables  
  where TABLE_NAME='$table';
"@

$d = ODBCquery $conn $q | Select-Object -Property * -ExcludeProperty "ItemArray", "RowError", "RowState", "Table", "HasErrors"
$d | ConvertTo-HTML -Title "Rows" -Head $Header -body "<h2>$table size and fragmentation</h2>" 

