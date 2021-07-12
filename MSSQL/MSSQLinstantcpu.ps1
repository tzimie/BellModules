param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1
parse $tags

$conn = $tagval.Conn 
$q = @"
DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info WITH (NOLOCK)); 
SELECT TOP(256) 
               DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [DT],
			   SQLProcessUtilization AS [SQLCPU], 
               100 - SystemIdle - SQLProcessUtilization AS [OtherCPU]
FROM (SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
			AS [SystemIdle], 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') 
			AS [SQLProcessUtilization], [timestamp] 
	  FROM (SELECT [timestamp], CONVERT(xml, record) AS [record] 
			FROM sys.dm_os_ring_buffers WITH (NOLOCK)
			WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
			AND record LIKE N'%<SystemHealth>%') AS x) AS y 
ORDER BY 1 DESC OPTION (RECOMPILE);
"@

@"
Instant SQL server cpu for the last seconds
X - time
Y - CPU pct
"@
MSSQLchart $conn $q
