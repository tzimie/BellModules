from bell import *
from PGquery import *

def replaceDB(conn, newdb): # replace dbname= in conn string
  m = []
  for el in conn.split(" "):
    if el.startswith('dbname='):
      m.append('dbname='+newdb)
    else:
      m.append(el)
  return ' '.join(m)

usr, grp, name, tags, tagval = bellparams()

srv = tagval['Server']
conn = tagval['Conn']

print(f"""Current activity|PGcurrentactivity|html|{tags}
Current locks|PGlocks|html|{tags}
Tables size TreeMap|PGsrvtreemap|html|{tags}
Tables io and cache hits TreeMap|PGtableiosrv|html|{tags}
Database stats|PGdatabasestats|html|{tags}""")

d = PGquery(conn, "select datname from pg_database;")
for s in d:
  dbname = str(s[0])
  sz = PGscalar(conn, f"SELECT pg_size_pretty( pg_database_size('{dbname}')) as str;")
  newtags = replaceDB(tags,dbname)
  print(f'db {dbname} ({sz})|PGdatabase|folder|{newtags}~dbname={dbname}')

