param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/pgODBC.ps1
parse $tags
if (-not $tagval.Conn) { exit }

$conn = $tagval.Conn 
$schema = $tagval.schema
$table = $tagval.table

$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

# CREATE EXTENSION pgstattuple;
$q = "SELECT * FROM pgstattuple('$schema.$table');"
$d = ODBCquery $conn $q | Select-Object -Property * -ExcludeProperty "ItemArray", "RowError", "RowState", "Table", "HasErrors"
$d | ConvertTo-HTML -Title "Rows" -Head $Header -body '<h2>Table fragmentation</h2>' 
