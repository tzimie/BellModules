param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1
parse $tags
$day = $tagval.day

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
select (select Name from ReportServer.dbo.Catalog where ItemID=ReportID) as Name,
  UserName,Format,TimeStart,TimeEnd,datediff(ss,TimeStart,TimeEnd) as Seconds,
  case when Status<>'rsSuccess' then '{red}' else '' end +Status as Status,ByteCount,[RowCount] 
  from ReportServer.dbo.ExecutionLogStorage
  where TimeStart>=convert(datetime,'$day') and TimeStart<convert(datetime,'$day')+1
  order by TimeStart
"@

$conn = $tagval.Conn -Replace '{sem}', ';' -Replace '{eq}','=' -Replace '{comma}',',' -Replace '{', '''' -Replace '}', '''' 
$d = MSSQLquery $conn $q | Select-Object -Property * -ExcludeProperty "ItemArray", "RowError", "RowState", "Table", "HasErrors"
$html = $d | ConvertTo-HTML -Title "Rows" -Head $Header -body '<h2>MSRS report</h2>' 
$html = $html -Replace '<td>{(.*?)}', '<td class="X-$1">'
$html
