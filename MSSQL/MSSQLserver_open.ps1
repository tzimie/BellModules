param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1

parse $tags
$srv = $tagval.Server
$conn = $tagval.Conn

@"
SQL jobs status|MSSQLjobs|html|$tags
SQL server CPU - last few minutes|MSSQLinstantcpu|chart|$tags
SQL current activity - 10secs|MSSQLcurrentactivity|html|$tags
SQL locks in progress|MSSQLlocks|html|$tags
SQL active expensive queries|MSSQLactiveq|html|$tags
SQL Performance|MSSQLperf|folder|$tags
SQL database size and free space|MSSQLspace|html|$tags
"@

$d = MSSQLquery $conn "select DB_NAME(DbId) as name,sum(BytesOnDisk/1000/1000./1000.) as Gb from ::fn_virtualfilestats(null,null) where DbId>4 group by DbId"

# user databases
foreach ($s in $d) {
  $first = $conn.Split(';')[0] # server = ...
  $newtag = "Server=$srv~Conn=Server=$srv;Database=$($s.name);" + $conn.Substring($first.length+1)
  "db $($s.name) ($($s.Gb.toString("0.#"))Gb)|MSSQLdatabase|folder|$newtag~dbname=$($s.name)"
}


