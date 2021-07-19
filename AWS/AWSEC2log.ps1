param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

$region = $tagval.Region
$id = $tagval.Id

$a=(Get-EC2ConsoleOutput -InstanceId $id -regio $region).Output
$b = [System.Convert]::FromBase64String($a.ToString()); 
[System.Text.Encoding]::UTF8.GetString($b)
