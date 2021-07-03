param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/postgreODBC.ps1

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split(";")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$dsn = $tagval.DSN

# root groups
$res = ODBCquery $dsn "select * from vpxv_vmgroups as O where not exists(select * from vpxv_vmgroups as I where I.vmgroupid=O.parentid)"
# user databases
foreach ($s in $res) {
  "$($s.name),VMwareGroup,folder,$tags;vmgroupid=$($s.vmgroupid)"
}
