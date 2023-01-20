from bell import *
from MYSQLquery import *
import re

usr, grp, name, tags, tagval = bellparams()

Header = """<style>
.X-yellow { color: black; background-color: #FFFFE0; }
.X-blue1 { color: white; background-color: #0000FF; }
.X-blue2 { color: white; background-color: #4444FF; }
.X-blue3 { color: white; background-color: #6666FF; }
.X-blue4 { color: white; background-color: #8888FF; }
.X-blue5 { color: white; background-color: #9999FF; }
.X-blue6 { color: black; background-color: #AAAAFF; }
.X-blue7 { color: black; background-color: #BBBBFF; }
.X-blue8 { color: black; background-color: #CCCCFF; }
.X-blue9 { color: black; background-color: #DDDDFF; }
.X-blue10 { color: black; background-color: #DDEEFF; }
.X-blue11 { color: black; background-color: #EEEEFF; }
.X-default { color: black; background-color: white; }
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

conn = tagval['Conn']
table = tagval['table']

# pass 1, assign column names
d = MYSQLquery(conn, f"SELECT INDEX_NAME,SEQ_IN_INDEX,COLUMN_NAME FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_NAME = '{table}' order by INDEX_NAME,SEQ_IN_INDEX;")
coln = {}
num = 0
for s in d:
  iname = str(s[0])
  seq = int(s[1])
  col = str(s[2])
  if not (col in coln.keys()):
    coln[col] = num
    num += 1

# pass 2, generate header
headercol = ["{bold}INDEX NAME{nobold}"]
for col in coln.keys():
  headercol.append('{bold}' + col + '{nobold}')
csvfile = [headercol]

# pass 3, lines per index
d = MYSQLquery(conn, f"SELECT DISTINCT INDEX_NAME FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_NAME = '{table}'")
for s in d:
  iname = str(s[0])
  thiscols = {}
  defiquery = MYSQLquery(conn, f"SELECT SEQ_IN_INDEX,COLUMN_NAME FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_NAME = '{table}' and INDEX_NAME='{iname}'")
  for defi in defiquery:
    col = str(defi[1])
    pos = int(defi[0])
    thiscols[col] = pos
  csv = [iname]
  for col in coln.keys():
    if col in thiscols.keys():
      val = thiscols[col]
      csv.append(f'{val}')
    else:
      csv.append('')
  csvfile.append(csv)

print(Header)
print('<h2>Index coverage report</h2>')
g = makegrid(csvfile)
g = re.sub("<td>([0-9]+)", '<td class="X-blue\\1">\\1', g)
print(g)


