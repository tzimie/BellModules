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
select job_id,max(convert(varchar,run_date)+convert(varchar,run_time)) as last
  into #l from msdb.dbo.sysjobhistory where step_id=0
  group by job_id
SELECT name
         ,DATEADD(S,(run_time/10000)*60*60 /* hours */  
          +((run_time - (run_time/10000) * 10000)/100) * 60 /* mins */  
          + (run_time - (run_time/100) * 100)  /* secs */
           ,CONVERT(DATETIME,RTRIM(run_date),113)) AS Executed
		 ,run_duration/100000*60*60 
		    +((run_duration - (run_duration/10000) * 10000)/100) * 60
			+ run_duration%100 as DurationS
         ,CASE WHEN SJH.run_status=0 THEN convert(varchar(100),'{red}Failed')
                     WHEN SJH.run_status=1 THEN '{green}Succeeded'
                     WHEN SJH.run_status=2 THEN '{yellow}Retry'
                     WHEN SJH.run_status=3 THEN '{yellow}Cancelled'
               ELSE '{yellow}Unknown'  
          END Status, sj.job_id, 0 as NOK, 0 as OK
into #j
FROM   msdb.dbo.sysjobhistory SJH  
INNER JOIN msdb.dbo.sysjobs SJ  ON SJH.job_id=sj.job_id  
WHERE  step_id=0  and Enabled=1 
update #j set OK=(select count(*) from msdb.dbo.sysjobhistory IH , #l
  where IH.job_id=#j.job_id and step_id>0 and run_status=1 and #l.job_id=IH.job_id 
    and convert(varchar,IH.run_date)+convert(varchar,IH.run_time)>=#l.last)
update #j set NOK=(select count(*) from msdb.dbo.sysjobhistory IH , #l
  where IH.job_id=#j.job_id and step_id>0 and run_status=0 and #l.job_id=IH.job_id 
    and convert(varchar,IH.run_date)+convert(varchar,IH.run_time)>=#l.last)
update #j set Status='{yellow}Failed '+convert(varchar,NOK)+' of '+convert(varchar,NOK+OK) 
  where Status='{green}Succeeded' and NOK>0
update #j set Status=Status+' ('+convert(varchar,OK)+' step'+case when OK>1 then 's' else '' end+')'
  where Status='{green}Succeeded'  
select *,ROW_NUMBER() over (PARTITION BY name order by Executed desc) as RunNumber into #j1 from #j
select 
    name,
    convert(varchar,max(Executed),102)+' '+convert(varchar,max(Executed),108) as LastRun,
	avg(DurationS) as AvgDuration,
    max(case when RunNumber=1 then DurationS else -1 end) as LastDuration,
    max(case when RunNumber=1 then Status else '' end) as LastStatus
from #j1 group by name order by 1
"@

$f = @"
select job_id,max(convert(varchar,run_date)+convert(varchar,run_time)) as last
  into #l from msdb.dbo.sysjobhistory H where step_id=0
  group by job_id
select J.name as job_name, H.step_name, H.message
  from msdb.dbo.sysjobhistory H
  INNER JOIN msdb.dbo.sysjobs J  ON H.job_id=J.job_id 
  INNER JOIN #l on #l.job_id=H.job_id 
  WHERE  H.step_id>0  and Enabled=1  and run_status<>1
    and convert(varchar,H.run_date)+convert(varchar,H.run_time)>=#l.last
"@

$conn = $tagval.Conn

$d1 = MSSQLquery $conn $q | Select-Object -Property * -ExcludeProperty "ItemArray", "RowError", "RowState", "Table", "HasErrors"
$html1 = $d1 | ConvertTo-HTML -Title "Rows" -Head $Header -body '<h2>SQL server jobs status</h2>' 
$html1 = $html1 -Replace '<td>{(.*?)}', '<td class="X-$1">'

$d2 = MSSQLquery $conn $f | Select-Object -Property * -ExcludeProperty "ItemArray", "RowError", "RowState", "Table", "HasErrors"
$html2 = $d2 | ConvertTo-HTML -Title "Rows" -Head $Header -body '<h2>Fails in last executions</h2>' 

$html = $html1 + '<br><br>' + $html2
$html