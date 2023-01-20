from bell import *
from MSSQLquery import *

usr, grp, name, tags, tagval = bellparams()

Header = """<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

q = """DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info WITH (NOLOCK)); 
SELECT TOP(256) DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [DT],  
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
ORDER BY 1 OPTION (RECOMPILE);"""

print("""Instant SQL server cpu for the last seconds
X - time
Y - CPU pct""")

conn = tagval['Conn']
MSSQLchart(conn,q)

