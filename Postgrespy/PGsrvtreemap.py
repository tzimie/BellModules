from bell import *
from PGquery import *
import numpy as np
import pandas as pd
import plotly.express as px
# also requires kaleido

usr, grp, name, tags, tagval = bellparams()

def replaceDB(conn, newdb): # replace dbname= in conn string
  m = []
  for el in conn.split(" "):
    if el.startswith('dbname='):
      m.append('dbname='+newdb)
    else:
      m.append(el)
  return ' '.join(m)

conn = tagval['Conn']

q = f"""select table_catalog,table_schema,table_name,'Table data: '||table_name as indexname,'table' as Metrics,
  pg_relation_size('"'||table_schema||'"."'||table_name||'"') as table_size
  FROM information_schema.tables T
  where table_type='BASE TABLE'
union all
select table_catalog,table_schema,table_name,indexname,'index' as Metrics,
  pg_relation_size('"'||table_schema||'"."'||indexname||'"') as index_size
  FROM information_schema.tables T
  INNER JOIN pg_indexes ON pg_indexes.tablename=T.table_name and pg_indexes.schemaname=T.table_schema
  where table_type='BASE TABLE'
"""

data = []
db = PGquery(conn, "select datname from pg_database;")
for ss in db:
  dbname = str(ss[0])
  newconn = replaceDB(conn,dbname)
  try:
    d = PGquery(newconn, q)
    for r in d:
      data.append([ dbname, r[1], r[2], r[3], r[5], r[4] ])
  except:
    pass

df = pd.DataFrame(np.array(data), columns=['dbname', 'schema', 'table', 'index', 'size', 'metrics'])
fig = px.treemap(df, path=['dbname', 'schema', 'table', 'index'], values='size', color='metrics',
 color_discrete_map={'table': 'green', 'index': 'yellow'})
fig.update_layout(margin = dict(t=50, l=25, r=25, b=25))
#fig.show()
fig.write_image("srvtree.jpg", width=1080, height=720) # change to png sometimes hangs, blame kaleido

print (f"""<html>
<h1>TreeMap of relative table and index sizes on a server</h1>
<body style="background: black;">
<img src="srvtree.jpg">
</body>
</html>""")