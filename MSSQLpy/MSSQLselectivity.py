from bell import *
from MSSQLquery import *

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']
name = tagval['name']

Header = """<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

q0 = f"""declare @s varchar(128), @sql varchar(max), @rows bigint
select max(rowcnt) as rows into #rows from sysindexes where id=OBJECT_ID(N'{name}')
update #rows set rows=1 where rows=0 
create table #res (s varchar(128), cnt int)
create table #tp (s varchar(128), topper int)
DECLARE cols CURSOR FOR select name from syscolumns where id=OBJECT_ID(N'{name}') and xtype in (48,52,56,127,167,231,239,175,108) and length<=256
OPEN cols;
FETCH NEXT FROM cols into @s;
WHILE @@FETCH_STATUS = 0
BEGIN
  set @sql='insert into #res select '''+@s+''',(select count(distinct ['+@s+']) from {name})'
  exec (@sql)
  set @sql='insert into #tp select '''+@s+''',(select top 1 count(*) from {name} group by ['+@s+'] order by 1 desc)'
  exec (@sql)
  FETCH NEXT FROM cols into @s;
END
CLOSE cols;
DEALLOCATE cols;"""

q1 = """select 
  #res.s as [Column], 
  cnt as DistinctValues, 
  (select top 1 rows from #rows)/(case when cnt=0 then 1 else cnt end) as RowsPerValueAvg, 
  topper as RecordsInMostFreqVal, 
  convert(money,topper*100./(select top 1 rows from #rows)) as PctInTop from #res
  inner join #tp on #tp.s=#res.s
  order by 2 desc"""

d1 = MSSQLqueryHB(conn, q1, q0)
print('<h1>Selectivity on int/char columns and irregular selectivity values</h1>')
print(Header)
print(makegrid(d1))


