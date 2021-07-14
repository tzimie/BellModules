param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/ODBC.ps1
parse $tags

$conn = $tagval.Conn 
$q = "SHOW GLOBAL STATUS LIKE 'Questions';"
$p1 = ODBCquery $conn $q

@"
Line
Live metrics
X - time
Y - Number of questions
DT,Requests
"@

foreach ($s in $p1) { 
  $questions=$s.Value
}

for ($lp=0; $lp -lt 30; $lp++) {
  Start-Sleep -Seconds 1
  $p1 = ODBCquery $conn $q
  foreach ($s in $p1) { 
    $dquestions = $s.Value - $questions
    $questions = $s.Value
  }
  $dt = (Get-Date).ToString('yyyy-MM-ddThh:mm:ss')
  "$dt,$dquestions"
}

