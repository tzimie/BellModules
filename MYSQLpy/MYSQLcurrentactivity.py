from bell import *
from MYSQLquery import *

usr, grp, name, tags, tagval = bellparams()

Header = """<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

conn = tagval['Conn']

d1 = MYSQLqueryHB(conn, "select * FROM performance_schema.events_statements_summary_by_digest")
print('<h1>Current server activity</h1>')
print(Header)
print(makegrid(d1))



