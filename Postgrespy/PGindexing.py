from bell import *
from PGquery import *
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
schema = tagval['schema']
table = tagval['table']

# pass 1, assign column names
d = PGquery(conn, f"select indexname,indexdef from pg_indexes where tablename = '{table}' and schemaname='{schema}';")
coln = {}
num = 0
for s in d:
  iname = str(s[0])
  indexdef = str(s[1])
  defi = indexdef.split('(')[1].split(')')[0].replace(' ','')
  for col in defi.split(','):
    if not (col in coln.keys()):
      coln[col] = num
      num += 1

# pass 2, generate header
headercol = ["{bold}INDEX NAME{nobold}"]
for col in coln.keys():
  headercol.append('{bold}' + col + '{nobold}')
csvfile = [headercol]

# pass 3, lines per index
for s in d:
  iname = str(s[0])
  indexdef = str(s[1])
  defi = indexdef.split('(')[1].split(')')[0].replace(' ','')
  thiscols = {}
  pos = 1
  for col in defi.split(','):
    thiscols[col] = pos
    pos += 1
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


