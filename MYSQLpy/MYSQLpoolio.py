from bell import *
from MYSQLquery import *
import time
import datetime

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']

print("""Line
Live metrics
X - time
Y - Innodb buffer pool reads and writes
DT,Reads,Writes""")

q1 = "select VARIABLE_VALUE as cnt from performance_schema.global_status where variable_name like 'innodb_buffer_pool_reads'";
q2 = "select VARIABLE_VALUE as cnt from performance_schema.global_status where variable_name like 'innodb_buffer_pool_write_requests'";

rold = int(MYSQLscalar(conn, q1))
wold = int(MYSQLscalar(conn, q2))

for lp in range(30):
  time.sleep(1)
  rnew = int(MYSQLscalar(conn, q1))
  wnew = int(MYSQLscalar(conn, q2))
  deltar = rnew - rold
  deltaw = wnew - wold
  rold = rnew
  wold = wnew
  print(datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S')[0:19] + ',' + str(deltar) + ',' + str(deltaw))





