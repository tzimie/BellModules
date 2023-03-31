from bell import *
from MYSQLquery import *
from tabulate import tabulate
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

q = """SELECT database_name, table_name, index_name, stat_value
FROM mysql.innodb_index_stats WHERE stat_name = 'size' """

data = []
db = MYSQLquery(conn, "SELECT table_schema FROM information_schema.tables GROUP BY table_schema;")
for ss in db:
  dbname = str(ss[0])
  newconn = replaceDB(conn,dbname)
  try:
    d = MYSQLquery(newconn, q)
    data = []
    for r in d:
      v = 'index'
      if r[2] == 'PRIMARY': v = 'table'
      data.append([dbname, r[1], r[2], r[3], v])
  except:
    pass

df = pd.DataFrame(np.array(data), columns=['database', 'table', 'index', 'size', 'metrics'])
fig = px.treemap(df, path=['database', 'table', 'index'], values='size', color='metrics',
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
