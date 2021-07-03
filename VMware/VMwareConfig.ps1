param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/postgreODBC.ps1

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split(";")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$dsn = $tagval.DSN
$vmid = $tagval.vmid

# machines
$res = ODBCquery $dsn "select * from vpxv_vms where vmid=$vmid"
foreach ($s in $res) {
  $csv = @"
Parameter,Value
Guest Name,$name
Mem Size Mb,$($s.mem_size_mb)
vCPU,$($s.num_vcpu)
BOOT TIME,$($s.boot_time)
Power,$($s.power_state)
OS,$($s.guest_os)
DNS NAME,$($s.dns_name)
IP,$($s.ip_address)
Descr,$($s.description)
Annotation,$($s.annotation)
"@
}

$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@  
$html = $csv | ConvertFrom-Csv | ConvertTo-Html -Title "Services" -Head $Header -body '<h2>Guest information</h2>' 
$html
