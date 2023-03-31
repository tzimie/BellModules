from bell import *
from PGquery import *
import numpy as np
import pandas as pd
import plotly.express as px
# also requires kaleido

def replaceDB(conn, newdb): # replace dbname= in conn string
  m = []
  for el in conn.split(" "):
    if el.startswith('dbname='):
      m.append('dbname='+newdb)
    else:
      m.append(el)
  return ' '.join(m)

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']

q = f"""
with 
all_tables as
(
SELECT  *
FROM    (
    SELECT  'all'::text as table_name, 
        sum( (coalesce(heap_blks_read,0) + coalesce(idx_blks_read,0) + coalesce(toast_blks_read,0) + coalesce(tidx_blks_read,0)) ) as from_disk, 
        sum( (coalesce(heap_blks_hit,0)  + coalesce(idx_blks_hit,0)  + coalesce(toast_blks_hit,0)  + coalesce(tidx_blks_hit,0))  ) as from_cache    
    FROM    pg_statio_all_tables  --> change to pg_statio_USER_tables if you want to check only user tables (excluding postgres's own tables)
    ) a
WHERE   (from_disk + from_cache) > 0 -- discard tables without hits
),
tables as 
(
SELECT  *
FROM    (
    SELECT  relname as table_name, 
        ( (coalesce(heap_blks_read,0) + coalesce(idx_blks_read,0) + coalesce(toast_blks_read,0) + coalesce(tidx_blks_read,0)) ) as from_disk, 
        ( (coalesce(heap_blks_hit,0)  + coalesce(idx_blks_hit,0)  + coalesce(toast_blks_hit,0)  + coalesce(tidx_blks_hit,0))  ) as from_cache    
    FROM    pg_statio_all_tables --> change to pg_statio_USER_tables if you want to check only user tables (excluding postgres's own tables)
    ) a
WHERE   (from_disk + from_cache) > 0 -- discard tables without hits
)
SELECT  table_name as "table name",
    from_disk as "disk hits",
    round((from_disk::numeric / (from_disk + from_cache)::numeric)*100.0,2) as "% disk hits",
    round((from_cache::numeric / (from_disk + from_cache)::numeric)*100.0,2) as "% cache hits",
    (from_disk + from_cache) as "total hits"
FROM    (SELECT * FROM all_tables UNION ALL SELECT * FROM tables) a
ORDER   BY (case when table_name = 'all' then 0 else 1 end), from_disk desc
"""

data = []
db = PGquery(conn, "select datname from pg_database;")
for ss in db:
  dbname = str(ss[0])
  newconn = replaceDB(conn,dbname)
  try:
    d = PGquery(newconn, q)
    for r in d:
      if r[0] == 'all': continue
      data.append([ dbname, r[0], r[4], r[3]])
  except:
    pass

df = pd.DataFrame(np.array(data), columns=['database', 'table', 'hits', 'ratio'])
fig = px.treemap(df, path=['database', 'table'], values='hits', color='ratio', color_continuous_scale='Bluered_r')
fig.update_layout(margin = dict(t=50, l=25, r=25, b=25))
fig.write_image("tabtemp.jpg", width=1080, height=720) # change to png sometimes hangs, blame kaleido

print (f"""<html>
<h1>TreeMap of relative table and index sizes on a server</h1>
<body style="background: black;">
<img src="tabtemp.jpg">
</body>
</html>""")