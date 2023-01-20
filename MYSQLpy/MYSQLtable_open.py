from bell import *
from MYSQLquery import *

usr, grp, name, tags, tagval = bellparams()

table = tagval['table']
conn = tagval['Conn']

print(f"""Size and fragmentation|MYSQLfrag|html|{tags}
Selectivity|MYSQLselectivity|html|{tags}
Index coverage|MYSQLindexing|html|{tags}""")

d = MYSQLquery(conn, f"""SELECT COLUMN_NAME,DATA_TYPE 
  FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = database() AND TABLE_NAME = '{table}'
    AND (DATA_TYPE LIKE 'date%' or DATA_TYPE = 'timestamp');""")

for s in d:
  col = str(s[0])
  print(f"Chart by column {col}|MYSQLtabletime|chart|{tags}~col={col}")
