from bell import *
from PGquery import *

usr, grp, name, tags, tagval = bellparams()

Header = """<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

conn = tagval['Conn']

d1 = PGqueryHB(conn, "select * from pg_stat_database;")
print('<h1>Database statistics</h1>')
print(Header)
print(makegrid(d1))