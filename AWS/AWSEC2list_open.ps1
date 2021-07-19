param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$region = $tagval.Region
$ec2 = (Get-EC2instance -Region $region).Instances
foreach ($e in $ec2) {
  $State = ([string] $e.State.Name).ToUpper()
  $Id = $e.InstanceId
  $InstanceType = $e.InstanceType
  $LaunchTime = $e.launchtime  
  [string] $Platform = (Get-EC2Image -ImageId $e.ImageId -Region $region).Name
  $OS = $Platform.Split('-')[0]
  "$Id ($OS $InstanceType) $State|AWSEC2|folder|Region=$region~Id=$Id"
}
