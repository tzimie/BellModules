from bell import *
from MSSQLquery import *
import plotly.express as px
import numpy as np
import pandas as pd
# also requires kaleido

usr, grp, name, tags, tagval = bellparams()
conn = tagval['Conn']

qpreR = """
create table #fl (dbname sysname, dbid int, fid int, name nvarchar(1024))
exec sp_Msforeachdb 'insert into #fl select ''?'',db_id(''?''),fileid,filename from [?].dbo.sysfiles'
create table #res (drv varchar(2), name varchar(1024), val bigint)
insert into #res 
  select upper(left(name,2)) as drv, 
    reverse(left(reverse(name),charindex('\\',reverse(name))-1)) as filename, st.NumberReads as iocnt
    from #fl inner join fn_virtualfilestats(null,null) st on st.dbid=#fl.dbid and #fl.fid=st.fileid
select drv+','+name+','+convert(varchar,val) from #res
"""

qpreW = """
create table #fl (dbname sysname, dbid int, fid int, name nvarchar(1024))
exec sp_Msforeachdb 'insert into #fl select ''?'',db_id(''?''),fileid,filename from [?].dbo.sysfiles'
create table #res (drv varchar(2), name varchar(1024), val bigint)
insert into #res 
  select upper(left(name,2)) as drv, 
    reverse(left(reverse(name),charindex('\\',reverse(name))-1)) as filename, st.NumberWrites as iocnt
    from #fl inner join fn_virtualfilestats(null,null) st on st.dbid=#fl.dbid and #fl.fid=st.fileid
select drv+','+name+','+convert(varchar,val) from #res
"""

q = "select * from #res"

dataR = []
d = MSSQLquery(conn, q, qpreR)
for r in d:
  dataR.append( [r[0], r[1], int(r[2]) ])

df = pd.DataFrame(np.array(dataR), columns=['drive', 'file', 'iocnt'])
fig = px.treemap(df, path=['drive', 'file'], values='iocnt')
fig.update_layout(margin = dict(t=50, l=25, r=25, b=25))
fig.write_image("reads.jpg", width=1080, height=720) 

dataW = []
d = MSSQLquery(conn, q, qpreW)
for r in d:
  dataW.append( [r[0], r[1], r[2] ])

df = pd.DataFrame(np.array(dataW), columns=['drive', 'file', 'iocnt'])
fig = px.treemap(df, path=['drive', 'file'], values='iocnt')
fig.update_layout(margin = dict(t=50, l=25, r=25, b=25))
fig.write_image("writes.jpg", width=1080, height=720) 


print (f"""<html>
<h1>IO per database file, number of Reads</h1>
<body style="background: black;">
<img src="reads.jpg">
</body>
<h1>IO per database file, number of Writes</h1>
<body style="background: black;">
<img src="writes.jpg">
</body>
</html>""")


