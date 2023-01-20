from bell import *
from MYSQLquery import *
from tabulate import tabulate

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']

Header = """<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

q = """SELECT 
  TABLE_NAME,
  ENGINE,
  ROUND((DATA_LENGTH) / 1024 / 1024 ) AS DataSizeMB,
  ROUND((INDEX_LENGTH) / 1024 / 1024 ) AS IndexSizeMB,
  ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024 ) AS TotalSizeMB
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = database()
order by DATA_LENGTH+INDEX_LENGTH DESC
LIMIT 30"""

d = MYSQLqueryHB(conn,q)
print('<h1>Top 30 tables, ordered by size desc</>')
print(Header)
print(makegrid(d))

