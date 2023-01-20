from bell import *
from MSSQLquery import *

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']
name = tagval['name']


Header = """<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

q = f"""SELECT index_id,index_type_desc,avg_fragmentation_in_percent,avg_fragment_size_in_pages,page_count
  FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID(N'{name}'), NULL, NULL , 'LIMITED'); """

d1 = MSSQLqueryHB(conn, q)
print('<h1>Table fragmentation</h1>')
print(Header)
print(makegrid(d1))



