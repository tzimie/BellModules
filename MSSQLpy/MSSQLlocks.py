from bell import *
from MSSQLquery import *

usr, grp, name, tags, tagval = bellparams()

Header = """<style>
.X-red { color: red; background-color: yellow; }
.X-green { color: green; background-color: white; }
.X-yellow { color: black; background-color: #FFFFE0; }
.X-default { color: black; background-color: white; }
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}</style>"""

q0 = """SELECT 
   DB_NAME(database_id) as DatabaseName,
   session_id as spid
   , blocking_session_id as blocker
   , start_time, wait_time, wait_type
   , sql_handle, statement_start_offset, statement_end_offset
into #p1 FROM sys.dm_exec_requests
where blocking_session_id>0 or session_id in (select blocking_session_id FROM sys.dm_exec_requests)

select req.spid,
    substring
      (REPLACE
        (REPLACE
          (SUBSTRING
            (ST.text
            , (req.statement_start_offset/2) + 1
            , (
               (CASE statement_end_offset
                  WHEN -1
                  THEN DATALENGTH(ST.text)  
                  ELSE req.statement_end_offset
                  END
                    - req.statement_start_offset)/2) + 1)
       , CHAR(10), ' '), CHAR(13), ' '), 1, 512)  AS statement_text  
into #p2 FROM #p1 AS req CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) as ST"""

q1 = """select DatabaseName,
  case when blocker>0 then '{yellow}' else '{red}' end+convert(varchar,#p1.spid) as spid,
  convert(varchar,blocker) as blockedby,
  start_time,wait_time,wait_type,isnull(#p2.statement_text,'') as SQL from #p1 left outer join #p2 on #p1.spid=#p2.spid"""

conn = tagval['Conn']

d1 = MSSQLqueryHB(conn, q1, q0)
print('<h1>SQL server locks in progress right now</h1>')
print(Header)
print(makegrid(d1))



