param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$region = $tagval.Region
$id = $tagval.Cluster

Import-Module -Name AWS.Tools.CloudWatch
$dimension = New-Object Amazon.CloudWatch.Model.Dimension
$dimension.set_Name("DBClusterIdentifier")
$dimension.set_Value($id)

$d2 = [System.DateTime]::UtcNow
$d1 = $d2.AddDays(-1)

@"
Line
CPU for $Cluster
X - time
Y - AVG CPU
DT,CPU Pct
"@

$points = (Get-CWMetricStatistic -region $region -period 6000 -utcendtime $d2 -utcstarttime $d1 `
  -MetricName CPUUtilization -Namespace AWS/RDS -Statistic Average -dimension $dimension).Datapoints
foreach ($p in $points) {
  $dt = $p.Timestamp.ToString('yyyy-MM-ddThh:mm:ss')
  "$dt,$($p.Average)"
}
