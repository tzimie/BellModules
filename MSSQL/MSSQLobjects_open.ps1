param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1
parse $tags

$conn = $tagval.Conn
$dbname = $tagval.dbname
$obj = $tagval.Obj

if ($obj -eq 'U') {
  $d = MSSQLquery $conn "SELECT S.name+'.'+O.name as name,'['+S.name+'].['+O.name+']' as fullname,(select max(rowcnt) from dbo.sysindexes I where I.id=O.object_id) as rowcnt FROM $dbname.sys.objects O left outer join sys.schemas S on S.schema_id=O.schema_id WHERE type ='$obj'"
  foreach ($s in $d) {
    "$($s.name) : $($s.rowcnt) rows|MSSQLtable|folder|$tags~name=$($s.fullname)"
  }
} else {
  $d = MSSQLquery $conn "SELECT S.name+'.'+O.name as name,'['+S.name+'].['+O.name+']' as fullname FROM sys.objects O left outer join sys.schemas S on S.schema_id=O.schema_id WHERE type ='$obj'"
  foreach ($s in $d) {
    "$($s.name)|MSSQLproc|html|$tags~name=$($s.fullname)"
  }
}
