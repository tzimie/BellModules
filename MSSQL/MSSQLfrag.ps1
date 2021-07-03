param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1
parse $tags
if (-not $tagval.Conn) { exit }

$conn = $tagval.Conn 
$dbname = $tagval.dbname
$name = $tagval.name

$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

$q = @"
SELECT index_id,index_type_desc,avg_fragmentation_in_percent,avg_fragment_size_in_pages,page_count
  FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID(N'$name'), NULL, NULL , 'LIMITED'); 
"@

$d = MSSQLquery $conn $q | Select-Object -Property * -ExcludeProperty "ItemArray", "RowError", "RowState", "Table", "HasErrors"
$d | ConvertTo-HTML -Title "Rows" -Head $Header -body '<h2>Table fragmentation</h2>' 
