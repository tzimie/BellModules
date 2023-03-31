from bell import *
from MSSQLquery import *
import plotly.express as px
import numpy as np
import pandas as pd
# also requires kaleido

usr, grp, name, tags, tagval = bellparams()
conn = tagval['Conn']

qpre = """
create table #drv (d varchar(1), free int)
insert into #drv exec xp_fixeddrives
create table #fl (dbname sysname, dbid int, fid int, name nvarchar(1024))
exec sp_Msforeachdb 'insert into #fl select ''?'',db_id(''?''),fileid,filename from [?].dbo.sysfiles'
create table #res (drv varchar(2), name varchar(1024), SizMb int, typ varchar(32))
insert into #res select * from 
(select upper(left(name,2)) as drv, 
  reverse(left(reverse(name),charindex('\\',reverse(name))-1)) as filename,
  BytesOnDisk/1024/1024 as SzMb,
  case when st.dbid=2 then 'tempdb' when st.dbid<5 then 'system' when fid=1 then 'mdf' when fid=2 then 'ldf' else 'ndf' end as typ
  from #fl 
  inner join fn_virtualfilestats(null,null) st on st.dbid=#fl.dbid and #fl.fid=st.fileid
union all 
  select upper(d)+':', '(free space)',free,'free' from #drv) Q
"""

q = "select * from #res"

data = []
d = MSSQLquery(conn, q, qpre)
for r in d:
  data.append( [r[0], r[1], r[2], r[3] ])

df = pd.DataFrame(np.array(data), columns=['drive', 'file', 'size', 'typ'])
fig = px.treemap(df, path=['drive', 'file'], values='size', color='typ',
  color_discrete_map={'free': 'darkblue', 'mdf': 'green', 'ndf': 'yellow', 'ldf': 'magenta', 'tempdb': 'red', 'system': 'goldenrod'})

fig.update_layout(margin = dict(t=50, l=25, r=25, b=25))
#fig.show()
fig.write_image("drv.jpg", width=1080, height=720) 

print (f"""<html>
<h1>TreeMap of database files and drive space</h1>
<body style="background: black;">
<img src="drv.jpg">
</body>
</html>""")


