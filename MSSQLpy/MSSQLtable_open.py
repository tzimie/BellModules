from bell import *
from MSSQLquery import *

usr, grp, name, tags, tagval = bellparams()

dbaname = tagval['dbname']
conn = tagval['Conn']
name = tagval['name']

d = MSSQLquery(conn, f"SELECT name FROM syscolumns where id=object_id('{name}') and xtype=61")
for r in d:
  print(f'Chart by column {r[0]}|MSSQLtabletime|chart|{tags}~col={r[0]}')

print(f"""Fragmentation report|MSSQLfrag|html|{tags}
Column selectivity report|MSSQLselectivity|html|{tags}
Index coverage|MSSQLindexing|html|{tags}""")
