from bell import *
from PGquery import *

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']
schema = tagval['schema']
table = tagval['table']
col = tagval['col']

print("""Line
Number of records per day for the table $schema.$table
X - day
Y - Number of rows""")

PGchart(conn, f"""SELECT 
  {col}::date as DT,count(*) as Count 
  from {schema}.{table} 
  where {col} is not null group by {col}::date 
  order by 1;""")
