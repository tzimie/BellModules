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
  pg_stat_get_db_blocks_fetched({dbid}) as blocks_fetched,
  pg_stat_get_db_blocks_hit({dbid}) as blocks_hit;"""

print("""Line
Live metrics
X - time
Y - Number of blocks
DT,blocks_fetched,blocks_hit""")

d = PGquery(conn, q)
blocks_fetched = int(d[0][1])
blocks_hit = int(d[0][2])

for lp in range(30):
  time.sleep(1)
  p1 = PGquery(conn, q)
  for s in p1:
    dt = s[0].strftime('%Y-%m-%dT%H:%M:%s')[0:19]
    dblocks_fetched=int(s[1]) - blocks_fetched
    dblocks_hit=int(s[2]) - blocks_hit

    blocks_fetched=int(s[1])
    blocks_hit=int(s[2])
  print(f'{dt},{dblocks_fetched},{dblocks_hit}')



