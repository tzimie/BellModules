from bell import *
from MSSQLquery import *

usr, grp, name, tags, tagval = bellparams()
conn = tagval['Conn']
day = tagval['day']

q0 = """create table #log (LogDate datetime,Procinfo varchar(64), msg varchar(4000))
insert into #log exec xp_readerrorlog"""

q1 = f"""select LogDate,msg as [Text] from #log 
where LogDate>=convert(datetime,'{day}') and LogDate<convert(datetime,'{day}')+1 
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
order by LogDate"""

d1 = MSSQLquery(conn, q1, q0)
n = 0
for r in d1:
  n += 1
  print(f'{str(r[0])[0:22]} {r[1]}')
if n==0: print(f"No non-informational error messages found for {day}")


