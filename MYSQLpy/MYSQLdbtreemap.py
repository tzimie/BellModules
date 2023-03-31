from bell import *
from MYSQLquery import *
from tabulate import tabulate
import numpy as np
import pandas as pd
import plotly.express as px
# also requires kaleido

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']
dbname = tagval['dbname']

q = """SELECT database_name, table_name, index_name, stat_value
FROM mysql.innodb_index_stats WHERE stat_name = 'size' """

d = MYSQLquery(conn, q)
data = []
for r in d:
  v = 'index'
  if r[2] == 'PRIMARY': v = 'table'
  data.append([ r[1], r[2], r[3], v ])

df = pd.DataFrame(np.array(data), columns=['table', 'index', 'size', 'metrics'])
fig = px.treemap(df, path=['table', 'index'], values='size', color='metrics',
 color_discrete_map={'table': 'green', 'index': 'yellow'})
fig.update_layout(margin = dict(t=50, l=25, r=25, b=25))
#fig.show()
fig.write_image("dbtree.jpg", width=1080, height=720) # change to png sometimes hangs, blame kaleido

print (f"""<html>
<h1>TreeMap of relative table and index sizes in a database {dbname}</h1>
<body style="background: black;">
<img src="dbtree.jpg">
</body>
</html>""")
