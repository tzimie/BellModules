param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/pgODBC.ps1
parse $tags
if (-not $tagval.Conn) { exit }

$conn = $tagval.Conn 
$dbname = $tagval.dbname
$schema = $tagval.schema
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

$d = ODBCquery $conn "select indexname,indexdef from pg_indexes where tablename = '$table' and schemaname='$schema';"

# pass 1, assign column names
$coln = @{}
$num = 0
foreach ($s in $d) { 
  $iname = $s.indexname
  $def = $s.indexdef.Split('(')[1].Split(')')[0].Replace(' ','')
  foreach ($col in $def.Split(',')) {
    if ($coln[$col] -eq $Null) {
      $coln[$col] = $num
      $num++
      }
  }
}

# pass 2, generate csv header
$csvfile = "INDEX NAME"
foreach ($col in $coln.Keys) { 
  $csvfile = $csvfile + "," +$col
  }


# pass 3, generate csv lines per index
foreach ($s in $d) { 
  $iname = $s.indexname
  $def = $s.indexdef.Split('(')[1].Split(')')[0].Replace(' ','')
  $thiscols = @{}
  $pos = 1;
  foreach ($col in $def.Split(',')) { 
    $thiscols[$col] = $pos
    $pos++ 
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


