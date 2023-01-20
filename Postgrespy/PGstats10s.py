from bell import *
from PGquery import *
import time
from datetime import datetime

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']

Header = """<style>
.X-red { color: red; background-color: yellow; }
.X-green { color: green; background-color: white; }
.X-yellow { color: black; background-color: #FFFFE0; }
.X-default { color: black; background-color: white; }
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

dbid = int(PGscalar(conn, "select oid from pg_database where datname=current_database();"))

q = f"""select 
  now() as DT,
  pg_stat_get_db_xact_commit({dbid}) as xact_commit,
  pg_stat_get_db_xact_rollback({dbid}) as xact_rollback,
  pg_stat_get_db_blocks_fetched({dbid}) as blocks_fetched,
  pg_stat_get_db_blocks_hit({dbid}) as blocks_hit,  
  pg_stat_get_db_tuples_returned({dbid}) as tuples_returned,
  pg_stat_get_db_tuples_fetched({dbid}) as tuples_fetched,
  pg_stat_get_db_tuples_inserted({dbid}) as tuples_inserted,
  pg_stat_get_db_tuples_updated({dbid}) as tuples_updated,
  pg_stat_get_db_tuples_deleted({dbid}) as tuples_deleted;"""

p1 = PGquery(conn, q)
time.sleep(10)
p2 = PGquery(conn, q)

grid = [ ['{bold}xact_commit{nobold}','{bold}xact_rollback{bold}','{bold}blocks_fetched{nobold}', \
          '{bold}blocks_hit{nobold}','{bold}tuples_returned{nobold}','{bold}tuples_fetchedv', \
          '{bold}tuples_inserted{nobold}','{bold}tuples_updated{nobold}','{bold}tuples_deleted{nobold}'], \
  [ \
  int(p2[0][1]) - int(p1[0][1]), \
  int(p2[0][2]) - int(p1[0][2]), \
  int(p2[0][3]) - int(p1[0][3]), \
  int(p2[0][4]) - int(p1[0][4]), \
  int(p2[0][5]) - int(p1[0][5]), \
  int(p2[0][6]) - int(p1[0][6]), \
  int(p2[0][7]) - int(p1[0][7]), \
  int(p2[0][8]) - int(p1[0][8]), \
  int(p2[0][9]) - int(p1[0][9]), \
   ]]

print(Header)
print(makegrid(grid))



