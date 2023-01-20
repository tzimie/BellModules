from bell import *
from PGquery import *

usr, grp, name, tags, tagval = bellparams()

Header = """<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

q = """SELECT 
    pid
    ,datname
    ,usename
    ,application_name
    ,client_hostname
    ,client_port
    ,backend_start
    ,query_start
    ,query  
FROM pg_stat_activity
WHERE state <> 'idle'
  AND pid<>pg_backend_pid();"""

conn = tagval['Conn']

d1 = PGqueryHB(conn, q)
print('<h1>Current server connections</h1>')
print(Header)
print(makegrid(d1))



