from bell import *
from MYSQLquery import *

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']

d = MYSQLquery(conn, """SELECT routine_name FROM information_schema.routines
  WHERE  routine_type = 'FUNCTION'
    AND routine_schema = database()""")

for s in d:
  name = str(s[0])
  print(f"{name}|MYSQLproc|html|{tags}~proname={name}")
