from bell import *
from PGquery import *

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']

q = """select n.nspname as schema_name, p.proname
  from pg_proc p
  left join pg_namespace n on p.pronamespace = n.oid
  where n.nspname not in ('pg_catalog', 'information_schema') and p.prokind = 'f';"""

d = PGquery(conn, q)

for s in d:
  print( f'{str(s[0])}.{str(s[1])}|PGfunc|html|{tags}~schema={str(s[0])}~proname={str(s[1])}')
