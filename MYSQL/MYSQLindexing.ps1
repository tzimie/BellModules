param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/ODBC.ps1
parse $tags
if (-not $tagval.Conn) { exit }

$conn = $tagval.Conn 
$dbname = $tagval.dbname
$table = $tagval.table

$Header = @"
<style>
.X-yellow { color: black; background-color: #FFFFE0; }
.X-blue1 { color: white; background-color: #0000FF; }
.X-blue2 { color: white; background-color: #4444FF; }
.X-blue3 { color: white; background-color: #6666FF; }
.X-blue4 { color: white; background-color: #8888FF; }
.X-blue5 { color: white; background-color: #9999FF; }
.X-blue6 { color: black; background-color: #AAAAFF; }
.X-blue7 { color: black; background-color: #BBBBFF; }
.X-blue8 { color: black; background-color: #CCCCFF; }
.X-blue9 { color: black; background-color: #DDDDFF; }
.X-blue10 { color: black; background-color: #DDEEFF; }
.X-blue11 { color: black; background-color: #EEEEFF; }
.X-default { color: black; background-color: white; }
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

$d = ODBCquery $conn "SELECT INDEX_NAME,SEQ_IN_INDEX,COLUMN_NAME FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_NAME = '$table' order by INDEX_NAME,SEQ_IN_INDEX;"

# pass 1, assign column names
$coln = @{}
$num = 0
foreach ($s in $d) { 
  $col = $s.COLUMN_NAME;
  if ($coln[$col] -eq $Null) {
    $coln[$col] = $num
    $num++
    }
}

# pass 2, generate csv header
$csvfile = "INDEX NAME"
foreach ($col in $coln.Keys) { 
  $csvfile = $csvfile + "," +$col
  }

# pass 3, generate csv lines per index
$d = ODBCquery $conn "SELECT DISTINCT INDEX_NAME FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_NAME = '$table'"
foreach ($s in $d) { 
  $iname = $s.INDEX_NAME
  $thiscols = @{}
  $d1 = ODBCquery $conn "SELECT SEQ_IN_INDEX,COLUMN_NAME FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_NAME = '$table' and INDEX_NAME='$iname'"
  foreach ($col in $d1) { 
    $colname = $col.COLUMN_NAME
    $thiscols[$colname] = $col.SEQ_IN_INDEX
    }
  $csv = $iname
  foreach ($col in $coln.Keys) { 
    if ($thiscols[$col] -eq $Null) { $csv=$csv+',' }
    else { $csv=$csv+",$($thiscols[$col])" }
  }
  $csvfile = $csvfile + "`n" + $csv
}
$html = $csvfile | ConvertFrom-Csv | ConvertTo-Html -Title "Indexed columns" -Head $Header -body '<h2>Index coverage report</h2>' 
$html = $html -Replace '<td>(\d+)</td>', '<td class="X-blue$1">$1</td>'
$html


