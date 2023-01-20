from bell import *
from MYSQLquery import *

usr, grp, name, tags, tagval = bellparams()

Header = """<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

conn = tagval['Conn']

d1 = MYSQLquery(conn, "select * from performance_schema.error_log")
print('<h1>Error log</h1>')
print(Header)
print(makegrid(d1))



