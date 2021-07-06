param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

[int] $lev = $tagval.level 
$machine = $tagval.server

# on a top level, we serach by counter set name
if ($lev -eq 0) {
  $a = Get-Counter -ListSet * -ComputerName $machine
  foreach ($i in $a) { 
    "$($i.CounterSetname)|PerfMonList|folder|server=$($tagval.server)~level=$($lev+1)~cat=$($i.CounterSetname)"
  }
  exit
}

# then get counter names
if ($lev -eq 1) {
  $cat = $tagval.cat
  $a = (Get-Counter -ListSet $cat -ComputerName $machine).Paths
  foreach ($i in $a) { 
    $name = $i.Split('\')[-1]
    "$name|PerfMonList|folder|server=$($tagval.server)~level=$($lev+1)~cat=$cat~path=$i"
  }
  exit
}

# select instance
if ($lev -eq 2) {
  $val = 0
  $instanceHash = @{} # to avoid duplicates
  $cat = $tagval.cat
  $endpath = $tagval.path.Split('\')[-1]
  $a = (Get-Counter -ListSet $cat).PathsWithInstances
  foreach ($i in $a) { 
    if( $i.Split('\')[-1] -ne $endpath) { continue; }
    $name = $i.Split('(')[1].Split(')')[0]
    if ($instanceHash[$name] -ne $Null) { continue; } # skip duplicate
    $instanceHash[$name] = 'Y'
    # add value not more than 15 times, otherwise if would be too long
    $val++
    $cstr = ''
    if ($val -le 15) {
      $cstr = ' - counter is null'
      $counter = Get-Counter -Counter $i -maxSamples 1 -ComputerName $machine
      if ($counter -ne $Null) {
        $c = (Get-Counter -Counter $i -maxSamples 1 -ComputerName $machine)[0].CounterSamples[0].CookedValue
        $cstr = " - current value " + $c.ToString('#.##')
        }
      }
    "$name$cstr|PerfMonChart|chart|server=$($tagval.server)~level=$($lev+1)~cat=$cat~path=$i"
  }
  exit
}
