param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/postgreODBC.ps1

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

@"
Configuration,VMwareConfig,html,$tags
Perf Stats Daily,VMwareStats,folder,$tags;range=daily
Perf Stats Weekly,VMwareStats,folder,$tags;range=weekly
Perf Stats Monthly,VMwareStats,folder,$tags;range=monthly
"@
