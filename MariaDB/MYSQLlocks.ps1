param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/ODBC.ps1
parse $tags

$Header = @"
<style>
.X-red { color: red; background-color: yellow; }
.X-green { color: green; background-color: white; }
.X-yellow { color: black; background-color: #FFFFE0; }
.X-default { color: black; background-color: white; }
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@  

$q = @"
SELECT 
    pl.id
    ,pl.user
    ,pl.state
    ,it.trx_id 
    ,it.trx_mysql_thread_id 
    ,it.trx_query AS query
    ,it.trx_id AS blocking_trx_id
    ,it.trx_mysql_thread_id AS blocking_thread
    ,it.trx_query AS blocking_query
FROM information_schema.processlist AS pl 
INNER JOIN information_schema.innodb_trx AS it
    ON pl.id = it.trx_mysql_thread_id
INNER JOIN information_schema.innodb_lock_waits AS ilw
    ON it.trx_id = ilw.requesting_trx_id 
        AND it.trx_id = ilw.blocking_trx_id;
"@

$conn = $tagval.Conn 
$d = ODBCquery $conn $q | Select-Object -Property * -ExcludeProperty "ItemArray", "RowError", "RowState", "Table", "HasErrors"
$html = $d | ConvertTo-HTML -Title "Rows" -Head $Header -body '<h2>Current server locks</h2>' 
$html
