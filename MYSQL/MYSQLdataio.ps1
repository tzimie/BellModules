param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/ODBC.ps1
parse $tags

$conn = $tagval.Conn 
$q1 = "select VARIABLE_VALUE as cnt from performance_schema.global_status where variable_name like 'innodb_data_reads'";
$q2 = "select VARIABLE_VALUE as cnt from performance_schema.global_status where variable_name like 'innodb_data_writes'";

@"
Line
Live metrics
X - time
Y - Innodb data reads and writes
DT,Reads,Writes
"@

$r = ODBCint $conn $q1
$w = ODBCint $conn $q2

for ($lp=0; $lp -lt 30; $lp++) {
  Start-Sleep -Seconds 1
  $r1 = ODBCint $conn $q1
  $w1 = ODBCint $conn $q2
  $deltar = $r1 - $r
  $deltaw = $w1 - $w
  $r = $r1
  $w = $w1
  $dt = (Get-Date).ToString('yyyy-MM-ddThh:mm:ss')
  "$dt,$deltar,$deltaw"
}

