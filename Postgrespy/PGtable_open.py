from bell import *
from PGquery import *

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']
schema = tagval['schema']
table = tagval['table']

print(f"""Tuple fragmentation|PGfrag|html|{tags}
Selectivity|PGselectivity|html|{tags}
Index coverage|PGindexing|html|{tags}""")

q = f"""SELECT column_name 
  FROM information_schema.columns 
  WHERE table_schema='{schema}' and table_name='{table}' and data_type like 'time%';"""

d = PGquery(conn, q)

for s in d:
  print(f"Chart by column {str(s[0])}|PGtabletime|chart|{tags}~col={str(s[0])}")
