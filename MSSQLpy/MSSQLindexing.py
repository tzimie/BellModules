from bell import *
from MSSQLquery import *

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']
name = tagval['name']

Header = """<style>
.X-yellow { color: black; background-color: #FFFFE0; }
.X-blue1 { color: white; background-color: #0000FF; }
.X-blue2 { color: white; background-color: #4444FF; }
.X-blue3 { color: white; background-color: #6666FF; }
.X-blue4 { color: white; background-color: #8888FF; }
.X-blue5 { color: white; background-color: #9999FF; }
.X-blue6 { color: black; background-color: #AAAAFF; }
.X-blue7 { color: black; background-color: #BBBBFF; }
.X-blue8 { color: black; background-color: #CCCCFF; }
.X-blue9 { color: black; background-color: #DDDDFF; }
.X-blue10 { color: black; background-color: #DDEEFF; }
.X-blue11 { color: black; background-color: #EEEEFF; }
.X-default { color: black; background-color: white; }
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

q0 = f"set nocount on declare @name varchar(128)='{name}'"
q0 += """
select I.name as iname,IC.index_column_id, C.name as colname
  into #i
  from sys.index_columns IC, sys.indexes I, sys.columns C
  where IC.object_id=object_id(@name) and I.object_id=IC.object_id and I.index_id=IC.index_id and C.object_id=I.object_id and C.column_id=IC.column_id
declare @sql varchar(8000)='create table ##p (iname varchar(128) collate database_default', @c varchar(128), @blanks varchar(4000)= ''

-- create table
DECLARE servers CURSOR FOR select name from sys.columns where object_id=object_id(@name) and name in (select colname from #i) order by column_id
OPEN servers;  
FETCH NEXT FROM servers into @c  
WHILE @@FETCH_STATUS = 0  
BEGIN  
  set @sql=@sql+' , ['+@c+'] varchar(32)'
  set @blanks=@blanks+','''''
  FETCH NEXT FROM servers into @c
END  
CLOSE servers;  
DEALLOCATE servers;
set @sql=@sql+')'
exec(@sql)

set @sql='insert into ##p select distinct iname'+@blanks+' from #i '
exec(@sql)

-- create table
DECLARE servers CURSOR FOR select name from sys.columns where object_id=object_id(@name) and name in (select colname from #i) order by column_id
OPEN servers;  
FETCH NEXT FROM servers into @c  
WHILE @@FETCH_STATUS = 0  
BEGIN  
  set @sql='update ##p set ['+@c+']=convert(varchar,index_column_id) from #i where #i.colname='''+@c+''' and #i.iname=##p.iname'
  exec(@sql)
  set @sql='update ##p set ['+@c+']=''{blue''+['+@c+']+''}''+['+@c+'] where ['+@c+']>'''''  
  exec(@sql)
  FETCH NEXT FROM servers into @c
END  
CLOSE servers;  
DEALLOCATE servers;"""

q1 = "select * from ##p"

d1 = MSSQLqueryHB(conn, q1, q0)
print('<h1>Index coverage report</h1>')
print(Header)
print(makegrid(d1))


