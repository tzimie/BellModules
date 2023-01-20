from bell import *
from MYSQLquery import *
import time
import datetime

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']

print("""Line
Live metrics
X - time
Y - Fetches and Writes
DT,Fetches,Writes""")

q = """select ifnull(sum(count_fetch),0) as fetches, ifnull(sum(count_write),0) as writes
  from performance_schema.table_io_waits_summary_by_table 
  where object_schema=database();"""

f, w = MYSQLscalar2(conn, q)
oldf = int(f)
oldw = int(w)

for lp in range(30):
  time.sleep(1)
  f, w = MYSQLscalar2(conn, q)
  newf = int(f)
  neww = int(w)
  deltaf = newf - oldf
  deltaw = neww - oldw
  oldf = newf
  oldw = neww
  print(datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S')[0:19] + ',' + str(deltaf) + ',' + str(deltaw))





