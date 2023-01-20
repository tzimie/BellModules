from bell import *
from MYSQLquery import *

def replaceDB(conn, newdb): # replace dbname= in conn string
  m = []
  for el in conn.split(" "):
    if el.startswith('database='):
      m.append('database='+newdb)
    else:
      m.append(el)
  return ' '.join(m)

usr, grp, name, tags, tagval = bellparams()

srv = tagval['Server']
conn = tagval['Conn']

print(f"""Current activity|MYSQLcurrentactivity|html|{tags}
Process list|MYSQLprocesslist|html|{tags}
Current locks|MYSQLlocks|html|{tags}
Questions live 30s|MYSQLquestions|chart|{tags}
Error Log|MYSQLperf|folder|{tags}
InnoDB data reads/writes 30s|MYSQLdataio|chart|{tags}
InnoDB buffer pool reads/writes 30s|MYSQLpoolio|chart|{tags}
InnoDB rows operations 30s|MYSQLrows|chart|{tags}""")

d = MYSQLquery(conn, """SELECT
    table_schema AS 'DB Name',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) AS 'DB Size in MB'
FROM
    information_schema.tables
GROUP BY
    table_schema;""")

for s in d:
  dbname = str(s[0])
  sz = str(s[1])
  newtags = replaceDB(tags,dbname)
  print(f'db {dbname} (size {sz} Mb)|MYSQLdatabase|folder|{newtags}~dbname={dbname}')

