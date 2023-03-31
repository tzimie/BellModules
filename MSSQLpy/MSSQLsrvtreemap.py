from bell import *
from MSSQLquery import *
import plotly.express as px
import numpy as np
import pandas as pd
# also requires kaleido

usr, grp, name, tags, tagval = bellparams()
conn = tagval['Conn']

q = """
select DB_NAME() as DbName, 
  SchemaName, TableName, IndexName, 
  sum(a.total_pages) AS size,
  max(itype) as itype
  from (
    SELECT t.object_id, i.index_id,
    s.Name AS SchemaName,
    t.NAME AS TableName,
    isnull(i.name,'(HEAP)') AS IndexName,
    case when i.type_desc='HEAP' then 'HEAP'
	     when i.type_desc='CLUSTERED' then 'CL'
	     when i.type_desc='NONCLUSTERED' then 'NONCL'
	     when i.type_desc like '%COLUMNSTORE' then 'COL'
		 else 'OTHER' end as itype,
    p.rows,
    p.partition_id
  FROM sys.tables t
  INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
  INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
  LEFT OUTER JOIN sys.schemas s ON t.schema_id = s.schema_id
  WHERE t.is_ms_shipped = 0 AND i.OBJECT_ID > 255 and db_id()>4
  ) Q
  INNER JOIN sys.allocation_units a ON Q.partition_id = a.container_id
  GROUP BY SchemaName, TableName, IndexName"""

data = []
dblist = MSSQLquery(conn, "select name from sys.databases where state=0 and database_id>4")
for r in dblist:
  dbname = r[0]
  d = MSSQLquery(conn+f';Database={dbname}', q)
  for r in d:
    data.append( [dbname, r[1], r[2], r[3], r[4], r[5] ])

df = pd.DataFrame(np.array(data), columns=['db', 'schema', 'table', 'index', 'size', 'itype'])
fig = px.treemap(df, path=['db', 'schema', 'table', 'index'], values='size', color='itype',
 color_discrete_map={'CL': 'green', 'NONCL': 'blue', 'HEAP': 'red', 'COL': 'yellow', 'OTHER': 'magenta'})
fig.update_layout(margin = dict(t=50, l=25, r=25, b=25))
#fig.show()
fig.write_image("srvtree.jpg", width=1080, height=720) # change to png sometimes hangs, blame kaleido

print (f"""<html>
<h1>TreeMap of relative database, table, index sizes on server</h1>
<body style="background: black;">
<img src="srvtree.jpg">
</body>
</html>""")


