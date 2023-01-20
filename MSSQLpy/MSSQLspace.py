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
create table #tt (dbname sysname, tab sysname, rowcnt int)
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
     exec('use ['+@dbname+'] insert into #tt select top 3 '''+@dbname+''',O.name, max(rowcnt) as rowcnt from sysobjects O (nolock)
          inner join sysindexes I (nolock) on O.id=I.id
          where O.type=''U'' group by O.name order by 3 desc')
     FETCH NEXT FROM db into @dbname;  
  END  
CLOSE db;  
DEALLOCATE db;
delete from #tt where rowcnt<1000
update #tt set tab=left(tab,CHARINDEX('_', tab)-1) from #tt where tab like '#%'
select dbname,tab,rowcnt,row_number() over (partition by dbname order by rowcnt desc) as r into #ttr from #tt
select name,
  SUM(case when [Type]='Data'  then Gb else 0.0 end) as DataGb,
  SUM(case when [Type]='Data'  then #pct.Gbfree else 0.0 end) as DataFree,
  SUM(case when [Type]='Log'   then Gb else 0.0 end) as LogGb,
  SUM(case when [Type]='Log'   then #pct.Gbfree else 0.0 end) as LogFree,
  CONVERT(varchar(1024),'') as Tabs
  into #gr 
  from #dbs
  left outer join #pct on #pct.dbname=#dbs.name and #dbs.fileid=#pct.file_id
  group by name
update #gr set Tabs=#ttr.tab+'('+CONVERT(varchar,#ttr.rowcnt)+')' from #ttr where #ttr.dbname=#gr.name and #ttr.r=1
update #gr set Tabs=Tabs+', '+#ttr.tab+'('+CONVERT(varchar,#ttr.rowcnt)+')' from #ttr where #ttr.dbname=#gr.name and #ttr.r=2
update #gr set Tabs=Tabs+', '+#ttr.tab+'('+CONVERT(varchar,#ttr.rowcnt)+')' from #ttr where #ttr.dbname=#gr.name and #ttr.r=3"""

q1 = """select name,convert(money,round(DataGb,3)) as DataGb,
       round(100*DataFree/(DataGb+0.001),2) as PctFree,
       convert(money,round(LogGb,3)) as LogGb,
       round(100*LogFree/(LogGb+0.001),2) as PctFree,
       tabs as BiggestTables
       from #gr order by (DataGb+LogGb) desc"""

conn = tagval['Conn']

d1 = MSSQLqueryHB(conn, q1, q0)
print('<h1>Database sizes and free space inside</h1>')
print(Header)
print(makegrid(d1))


