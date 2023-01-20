from bell import *
from MSSQLquery import *

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']
dbname = tagval['dbname']
name = tagval['name']
col = tagval['col']

print(f"""Line
Number of records per day for the table {name}
X - day
Y - Number of rows""")

MSSQLchart(conn, f"""SELECT convert(datetime,convert(varchar,[{col}],102)) as DT,
  count(*) as Count from {name} 
  where [{col}] is not null 
  group by convert(datetime,convert(varchar,[{col}],102)) order by 1""")
