from bell import *
from MYSQLquery import *
import time
import datetime

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']

print("""Line
Live metrics
X - time
Y - Innodb rows operations
DT,Inserted,Deleted,Read,Updated""")

qi = "select VARIABLE_VALUE as cnt from performance_schema.global_status where variable_name like 'innodb_rows_inserted'";
qd = "select VARIABLE_VALUE as cnt from performance_schema.global_status where variable_name like 'innodb_rows_deleted'";
qr = "select VARIABLE_VALUE as cnt from performance_schema.global_status where variable_name like 'innodb_rows_read'";
qu = "select VARIABLE_VALUE as cnt from performance_schema.global_status where variable_name like 'innodb_rows_updated'";

oldi = int(MYSQLscalar(conn, qi))
oldd = int(MYSQLscalar(conn, qd))
oldr = int(MYSQLscalar(conn, qr))
oldu = int(MYSQLscalar(conn, qu))

for lp in range(30):
  time.sleep(1)
  newi = int(MYSQLscalar(conn, qi))
  newd = int(MYSQLscalar(conn, qd))
  newr = int(MYSQLscalar(conn, qr))
  newu = int(MYSQLscalar(conn, qu))
  deltai = newi - oldi
  deltad = newd - oldd
  deltar = newr - oldr
  deltau = newu - oldu
  oldi = newi
  oldd = newd
  oldr = newr
  oldu = newu
  print(datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S')[0:19] + ',' + str(deltai) + ',' + str(deltad) + ',' + str(deltar) + ',' + str(deltau))





