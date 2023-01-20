from bell import *
from MYSQLquery import *

usr, grp, name, tags, tagval = bellparams()

srv = tagval['Server']
conn = tagval['Conn']

d = MYSQLquery(conn, """SELECT   
  TABLE_NAME,
  ENGINE,
  ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024) AS SizeMB
  FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = database();""")

for s in d:
  tab = str(s[0])
  e = str(s[1])
  sz = str(s[2])
  print(f'{tab} ({e}) {sz} Mb|MYSQLtable|folder|{tags}~table={tab}')

