param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/ODBC.ps1
parse $tags

$conn = $tagval.Conn 
$qi = "select VARIABLE_VALUE as cnt from performance_schema.global_status where variable_name like 'innodb_rows_inserted'";
$qd = "select VARIABLE_VALUE as cnt from performance_schema.global_status where variable_name like 'innodb_rows_deleted'";
$qr = "select VARIABLE_VALUE as cnt from performance_schema.global_status where variable_name like 'innodb_rows_read'";
$qu = "select VARIABLE_VALUE as cnt from performance_schema.global_status where variable_name like 'innodb_rows_updated'";

@"
Line
Live metrics
X - time
Y - Innodb rows operations
DT,Inserted,Deleted,Read,Updated
"@

$i = ODBCint $conn $qi
$d = ODBCint $conn $qd
$r = ODBCint $conn $qr
$u = ODBCint $conn $qu

for ($lp=0; $lp -lt 30; $lp++) {
  Start-Sleep -Seconds 1
  $i1 = ODBCint $conn $qi
  $d1 = ODBCint $conn $qd
  $r1 = ODBCint $conn $qr
  $u1 = ODBCint $conn $qu
  $deltai = $i1 - $i
  $deltad = $d1 - $d
  $deltar = $r1 - $r
  $deltau = $u1 - $u
  $i = $i1
  $d = $d1
  $r = $r1
  $u = $u1
  $dt = (Get-Date).ToString('yyyy-MM-ddThh:mm:ss')
  "$dt,$deltai,$deltad,$deltar,$deltau"
}

