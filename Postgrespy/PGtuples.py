from bell import *
from PGquery import *
import time
from datetime import datetime

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']

Header = """<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

dbid = int(PGscalar(conn, "select oid from pg_database where datname=current_database();"))

q = f"""select 
  now() as DT,
  pg_stat_get_db_tuples_returned({dbid}) as tuples_returned,
  pg_stat_get_db_tuples_fetched({dbid}) as tuples_fetched,
  pg_stat_get_db_tuples_inserted({dbid}) as tuples_inserted,
  pg_stat_get_db_tuples_updated({dbid}) as tuples_updated,
  pg_stat_get_db_tuples_deleted({dbid}) as tuples_deleted;"""

print("""Line
Live metrics
X - time
Y - Number of tuples
DT,tuples_returned,tuples_fetched,tuples_inserted,tuples_updated,tuples_deleted""")

d = PGquery(conn, q)
tuples_returned = int(d[0][1])
tuples_fetched = int(d[0][2])
tuples_inserted = int(d[0][3])
tuples_updated = int(d[0][4])
tuples_deleted = int(d[0][5])

for lp in range(30):
  time.sleep(1)
  p1 = PGquery(conn, q)
  for s in p1:
    dt = s[0].strftime('%Y-%m-%dT%H:%M:%s')[0:19]
    dtuples_returned = int(s[1]) - tuples_returned
    dtuples_fetched = int(s[2]) - tuples_fetched
    dtuples_inserted = int(s[3]) - tuples_inserted
    dtuples_updated = int(s[4]) - tuples_updated
    dtuples_deleted = int(s[5]) - tuples_deleted

    tuples_returned = int(s[1])
    tuples_fetched = int(s[2])
    tuples_inserted = int(s[3])
    tuples_updated = int(s[4])
    tuples_deleted = int(s[5])
    print(f'{dt},{dtuples_returned},{dtuples_fetched},{dtuples_inserted},{dtuples_updated},{dtuples_deleted}')



