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
  pg_stat_get_db_xact_commit({dbid}) as xact_commit,
  pg_stat_get_db_xact_rollback({dbid}) as xact_rollback;"""

print("""Line
Live metrics
X - time
Y - Number of transactions
DT,xact_commit,xact_rollback""")

d = PGquery(conn, q)
xact_commit = int(d[0][1])
xact_rollback = int(d[0][2])

for lp in range(30):
  time.sleep(1)
  p1 = PGquery(conn, q)
  for s in p1:
    dt = s[0].strftime('%Y-%m-%dT%H:%M:%s')[0:19]
    dxact_commit=int(s[1]) - xact_commit
    dxact_rollback=int(s[2]) - xact_rollback

    xact_commit=int(s[1])
    xact_rollback=int(s[2])
  print(f'{dt},{dxact_commit},{dxact_rollback}')



