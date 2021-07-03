param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/postgreODBC.ps1

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split(";")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$dsn = $tagval.DSN
$vmgroupid = $tagval.vmgroupid

# subgroups
$res = ODBCquery $dsn "select * from vpxv_vmgroups where parentid=$vmgroupid"
foreach ($s in $res) {
  "$($s.name),VMwareGroup,folder,DSN=$dsn;vmgroupid=$($s.vmgroupid)"
}

# machines
$res = ODBCquery $dsn "select vmid,name,guest_family,num_vcpu,mem_size_mb,power_state from vpxv_vms where vmgroupid=$vmgroupid"
foreach ($s in $res) {
  $off = ''
  if ($s.power_state -eq 'Off') { $off = ' OFFLINE' }
  "$($s.name) - $($s.num_vcpu)CPU $(($s.mem_size_mb)/1024)Gb$off,WMwareGuest,folder,$tags;vmid=$($s.vmid)"
}
