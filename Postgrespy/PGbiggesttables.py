from bell import *
from PGquery import *

usr, grp, name, tags, tagval = bellparams()

Header = """<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

q = """select schemaname as table_schema,
    relname as table_name,
    pg_size_pretty(pg_total_relation_size(relid)) as total_size,
    pg_size_pretty(pg_relation_size(relid)) as data_size,
    pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid))
      as external_size
from pg_catalog.pg_statio_user_tables
order by pg_total_relation_size(relid) desc,
         pg_relation_size(relid) desc
limit 30;"""

conn = tagval['Conn']
d = PGqueryHB(conn,q)
print('<h1>Top 30 tables, ordered by size desc</>')
print(Header)
print(makegrid(d))

