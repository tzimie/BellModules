param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1
parse $tags

$Header = @"
<style>
.X-red { color: red; background-color: yellow; }
.X-green { color: green; background-color: white; }
.X-yellow { color: black; background-color: #FFFFE0; }
.X-default { color: black; background-color: white; }
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@  

$q = @"
SELECT name
         ,DATEADD(S,(run_time/10000)*60*60 /* hours */  
          +((run_time - (run_time/10000) * 10000)/100) * 60 /* mins */  
          + (run_time - (run_time/100) * 100)  /* secs */
           ,CONVERT(DATETIME,RTRIM(run_date),113)) AS Executed
		 ,run_duration/100000*60*60 
		    +((run_duration - (run_duration/10000) * 10000)/100) * 60
			+ run_duration%100 as DurationS
         ,CASE WHEN SJH.run_status=0 THEN '{red}Failed'
                     WHEN SJH.run_status=1 THEN '{green}Succeeded'
                     WHEN SJH.run_status=2 THEN '{yellow}Retry'
                     WHEN SJH.run_status=3 THEN '{yellow}Cancelled'
               ELSE '{yellow}Unknown'  
          END Status
into #j
FROM   msdb.dbo.sysjobhistory SJH  
JOIN   msdb.dbo.sysjobs SJ  
ON     SJH.job_id=sj.job_id  
WHERE  step_id=0  and Enabled=1
select *,ROW_NUMBER() over (PARTITION BY name order by Executed desc) as RunNumber into #j1 from #j
select 
    name,
    convert(varchar,max(Executed),102)+' '+convert(varchar,max(Executed),108) as LastRun,
	avg(DurationS) as AvgDuration,
    max(case when RunNumber=1 then DurationS else -1 end) as LastDuration,
    max(case when RunNumber=1 then Status else '' end) as LastStatus
from #j1 group by name
"@

$conn = $tagval.Conn 
$d = MSSQLquery $conn $q | Select-Object -Property * -ExcludeProperty "ItemArray", "RowError", "RowState", "Table", "HasErrors"
$html = $d | ConvertTo-HTML -Title "Rows" -Head $Header -body '<h2>SQL server jobs status</h2>' 
$html = $html -Replace '<td>{(.*?)}', '<td class="X-$1">'
$html
