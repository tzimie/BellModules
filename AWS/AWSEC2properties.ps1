param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@  

$region = $tagval.Region
$id = $tagval.Id

$region = $tagval.Region
$ec2 = (Get-EC2instance -Region $region -InstanceId $Id).Instances
$e = $ec2[0]

$State = ([string] $e.State.Name).ToUpper()
$Id = $e.InstanceId
$InstanceType = $e.InstanceType
$LaunchTime = $e.launchtime  
[string] $Platform = (Get-EC2Image -ImageId $e.ImageId -Region $region).Name
$PrivateIP = $e.PrivateIpAddress
$SubnetId = $e.SubnetId
$MAC = $e.networkinterfaces.MacAddress
$AZ = $e.placement.AvailabilityZone
$SG = $e.SecurityGroups.GroupName

$csv = @"
Property,Value
Id,$Id
InstanceType,$InstanceType
LaunchTime,$LaunchTime
Platform,$Platform 
PrivateIP,$PrivateIP
MAC,$MAC
AvailabilityZone,$AZ
SecurityGroupsName,$SG
"@

$html = $csv | ConvertFrom-Csv | ConvertTo-Html -Title "EC2" -Head $Header -body '<h2>EC2 properties</h2>' 
$html