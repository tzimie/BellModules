param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/pgODBC.ps1
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
    pid
    ,datname
    ,usename
    ,application_name
    ,client_hostname
    ,client_port
    ,backend_start
    ,query_start
    ,query  
FROM pg_stat_activity
WHERE state <> 'idle'
"@
#AND pid<>pg_backend_pid();

$conn = $tagval.Conn 
$d = ODBCquery $conn $q | Select-Object -Property * -ExcludeProperty "ItemArray", "RowError", "RowState", "Table", "HasErrors"
$html = $d | ConvertTo-HTML -Title "Rows" -Head $Header -body '<h2>Current server conenctions</h2>' 
$html = $html -Replace '<td>{(.*?)}', '<td class="X-$1">'
$html
