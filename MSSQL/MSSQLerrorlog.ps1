param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1
parse $tags

$conn = $tagval.Conn -Replace '{sem}', ';' -Replace '{eq}','=' -Replace '{comma}',',' -Replace '{', '''' -Replace '}', '''' 
$day = $tagval.day

$q = @"
create table #log (LogDate datetime,Procinfo varchar(64), msg varchar(4000))
insert into #log exec xp_readerrorlog
select LogDate,msg as [Text] from #log 
where LogDate>=convert(datetime,'$day') and LogDate<convert(datetime,'$day')+1 
  and ((msg like '%error%' and msg not like '%ErrorReporting%') or 
           msg like '%could not%' or 
           msg like '%DBCC database corruption%' or 
           msg like '%BEGIN STACK DUMP%' or 
           msg like '%Database mirroring will be suspended%' or 
           msg like '%significant part of sql server process memory has been paged out%' or 
           msg like '%I/O requests taking longer than%' or 
           msg like '%memory pressure%' or 
           msg like '%The device is not ready%' or 
           msg like '%failed%')
         and msg not like '%Login failed%'
         and msg not like '%finished without errors%'
         and msg not like '%error%severity%state%'
         and msg not like 'Logging SQL Server messages in file%'  
         and msg not  like '%-e D:\Apps%'  -- this is startup message, in your case it is not D:\
         and msg not  like '%Registry startup%'  
         and msg not  like '%found 0 errors and%'
order by LogDate
"@

$cnt = 0
$d = MSSQLquery $conn $q
foreach ($l in $d) {
  "$($l.LogDate) $($l.Text)"
  $cnt++
}
if ($cnt -eq 0) { "No non-informational error messages found for $day" }
