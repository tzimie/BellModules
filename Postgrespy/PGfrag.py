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

# CREATE EXTENSION pgstattuple;
d1 = PGqueryHB(conn, f"SELECT * FROM pgstattuple('{schema}.{table}');")
print('<h1>Table fragmentation</h1>')
print(Header)
print(makegrid(d1))
