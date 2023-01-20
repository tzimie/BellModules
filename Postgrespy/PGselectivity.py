from bell import *
from PGquery import *

usr, grp, name, tags, tagval = bellparams()

Header = """<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

conn = tagval['Conn']
schema = tagval['schema']
table = tagval['table']

q = f"""SELECT column_name,data_type,character_maximum_length 
  FROM information_schema.columns 
  WHERE table_schema='{schema}' and table_name='{table}'
    and (data_type like '%int%' 
    or (data_type like 'char%' and character_maximum_length<=128)
    or (data_type like 'varchar%' and character_maximum_length<=128))"""

rows = int(PGscalar(conn, f"select count(*) as cnt from {schema}.{table}"))
if rows == 0:
  print("<h1>Empty table</h1>")
  exit(0)

res = [["{bold}Column{nobold}", "{bold}DistinctValues{nobold}", "{bold}RowsPerValueAvg{nobold}", "{bold}RecordsInMostFreqVal{nobold}" ,"{bold}PctInTop{nobold}"]]

d = PGquery(conn, q)
for s in d:
  col = str(s[0])
  distinct = int(PGscalar(conn, f"select count(distinct {col}) as cnt from {schema}.{table}"))
  if distinct == 0: distinct = 1
  topone = int(PGscalar(conn, f"select count(*) as cnt from {schema}.{table} group by {col} order by 1 desc limit 1"))
  res.append([col, distinct, rows//distinct, topone, 100*topone//rows])

print('<h1>Selectivity on int/char columns and irregular selectivity values</h1>')
print(Header)
print(makegrid(res))

