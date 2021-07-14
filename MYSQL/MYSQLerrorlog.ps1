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

$conn = $tagval.Conn 
$day1 = $tagval.day
[datetime] $dt = $day1
$day2 = $dt.AddDays(1).ToString('yyyy-MM-dd')

$q = "select * from performance_schema.error_log where LOGGED>='$day1' and LOGGED<'$day2'"

$d = ODBCquery $conn $q | Select-Object -Property * -ExcludeProperty "ItemArray", "RowError", "RowState", "Table", "HasErrors"
$html = $d | ConvertTo-HTML -Title "Rows" -Head $Header -body '<h2>Events in error log</h2>' 
$html = $html -Replace '<td>Error</td>', '<td class="X-error">Error</td>'
$html = $html -Replace '<td>Warning</td>', '<td class="X-yellow">Warning</td>'
$html = $html -Replace '<td>System</td>', '<td class="X-green">System</td>'
$html
