from bell import *
from MYSQLquery import *

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']
table = tagval['table']

Header = """<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

q = f"""select  
  ENGINE, 
  Round( DATA_LENGTH/1024/1024) as data_length, 
  round(INDEX_LENGTH/1024/1024) as index_length, 
  round(DATA_FREE/ 1024/1024) as data_free,
  (data_free/(index_length+data_length)) as frag_ratio
  from information_schema.tables  
  where TABLE_NAME='{table}';"""

d1 = MYSQLqueryHB(conn, q)
print('<h1>Table fragmentation</h1>')
print(Header)
print(makegrid(d1))



