from bell import *
from MYSQLquery import *

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']
table = tagval['table']
col = tagval['col']

print("""Line
Number of records per day for the table $schema.$table
X - day
Y - Number of rows""")

MYSQLchart(conn, f"""SELECT 
  cast(`{col}` as date) as DT,count(*) as Count 
  from `{table}` where {col} is not null 
  group by cast(`{col}` as date) 
  order by 1""")
