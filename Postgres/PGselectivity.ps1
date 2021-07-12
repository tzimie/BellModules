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
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

$csv = "Column,DistinctValues,RowsPerValueAvg,RecordsInMostFreqVal,PctInTop"
$rows = ODBCint $conn "select count(*) as cnt from $schema.$table"
if ($rows -eq 0) { $rows = 1 }

$q = @"
SELECT column_name,data_type,character_maximum_length 
  FROM information_schema.columns 
  WHERE table_schema='$schema' and table_name='$table'
    and (data_type like '%int%' or (data_type like 'char%' and character_maximum_length<=128))
"@
$d = ODBCquery $conn $q
foreach ($s in $d) { 
  $col = $s.column_name
  $distinct = ODBCint $conn "select count(distinct $col) as cnt from $schema.$table"
  if ($distinct -eq 0) { $distinct = 1 }
  $topone   = ODBCint $conn "select count(*) as cnt from $schema.$table group by $col order by 1 desc limit 1"
  $csv = $csv + "`n" + "$col,$distinct," + ([int] ($rows/$distinct)) + ",$topone," +  ([int] (100*$topone/$rows))
}

$html = $csv | ConvertFrom-Csv | ConvertTo-HTML -Title "Rows" -Head $Header -body '<h2>Selectivity on int/char columns and irregular selectivity values</h2>' 
$html
