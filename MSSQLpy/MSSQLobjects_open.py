from bell import *
from MSSQLquery import *

usr, grp, name, tags, tagval = bellparams()

dbaname = tagval['dbname']
conn = tagval['Conn']
obj = tagval['Obj']

if obj == 'U':
  d = MSSQLquery(conn, f"""SELECT S.name+'.'+O.name as name,
  '['+S.name+'].['+O.name+']' as fullname,
  (select max(rowcnt) from dbo.sysindexes I where I.id=O.object_id) as rowcnt 
  FROM sys.objects O left outer join sys.schemas S on S.schema_id=O.schema_id WHERE type ='{obj}'""")
  for r in d:
    print(f'{r[0]} : {r[2]} rows|MSSQLtable|folder|{tags}~name={r[1]}')
else:
  d = MSSQLquery(conn, f"""SELECT S.name+'.'+O.name as name,
  '['+S.name+'].['+O.name+']' as fullname 
  FROM sys.objects O left outer join sys.schemas S on S.schema_id=O.schema_id WHERE type ='{obj}'""")
  for r in d:
    print(f'{r[0]}|MSSQLproc|html|{tags}~name={r[1]}')

