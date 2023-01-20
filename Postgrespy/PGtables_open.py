from bell import *
from PGquery import *

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']

q = """SELECT schemaname,tablename 
  FROM pg_catalog.pg_tables 
  where schemaname != 'pg_catalog' AND schemaname != 'information_schema';"""

d = PGquery(conn, q)

for s in d:
  sz = str(PGscalar(conn, f"select pg_size_pretty(pg_relation_size('{str(s[0])}.{str(s[1])}')) as str;"))
  print( f'{str(s[0])}.{str(s[1])} - {sz[0]}|PGtable|folder|{tags}~schema={str(s[0])}~table={str(s[1])}')

