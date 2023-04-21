from bell import *
from MSSQLquery import *

usr, grp, name, tags, tagval = bellparams()

Header = """<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

q0 = """select D.name,S.FileId,case S.Fileid when 1 then 'Data' when 2 then 'Log' else 'Data' /* actually index */ end as [Type],
  BytesOnDisk/1024/1024/1024. as Gb 
  into #dbs 
  from sysdatabases D,
  (select * from ::fn_virtualfilestats(null,null)) S
where D.Dbid=S.Dbid
-- loop by dbs
-- 
create table #pct (dbname sysname, file_id int, Gbfree float)
declare @dbname sysname
DECLARE db CURSOR FOR SELECT name FROM master.dbo.sysdatabases
  where DATABASEPROPERTYEX(Name, 'Status')='ONLINE'
  --and name not in ('master','tempdb','msdb','model')
OPEN db;  
  FETCH NEXT FROM db into @dbname
  WHILE @@FETCH_STATUS = 0  
  BEGIN  
     exec('use ['+@dbname+'] insert into #pct select '''+@dbname+''',file_id, (size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0)/1024.0
          FROM sys.database_files')
     FETCH NEXT FROM db into @dbname;  
  END  
CLOSE db;  
DEALLOCATE db;
select name,
  SUM(case when [Type]='Data'  then Gb else 0.0 end) as DataGb,
  SUM(case when [Type]='Data'  then #pct.Gbfree/(Gb+0.001) else 0.0 end) as DataFree,
  SUM(case when [Type]='Log'   then Gb else 0.0 end) as LogGb,
  SUM(case when [Type]='Log'   then #pct.Gbfree/(Gb+0.001) else 0.0 end) as LogFree
  into #gr 
  from #dbs
  left outer join #pct on #pct.dbname=#dbs.name and #dbs.fileid=#pct.file_id
  group by name
"""

q1 = """select name,convert(money,round(DataGb,3)) as DataGb,
       round(100*DataFree,2) as PctFree,
       convert(money,round(LogGb,3)) as LogGb,
       round(100*LogFree,2) as PctFree
       from #gr order by (DataGb+LogGb) desc"""

conn = tagval['Conn']

d1 = MSSQLqueryHB(conn, q1, q0)
print('<h1>Database sizes and free space inside</h1>')
print(Header)
print(makegrid(d1))


