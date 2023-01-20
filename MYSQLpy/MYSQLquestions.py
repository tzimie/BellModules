from bell import *
from MYSQLquery import *
import time
import datetime

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']

print("""Line
Live metrics
X - time
Y - Number of questions
DT,Requests""")

qu = "SHOW GLOBAL STATUS LIKE 'Questions';"
qold = int(MYSQLscalar(conn, qu, 1))

for lp in range(30):
  time.sleep(1)
  qnew = int(MYSQLscalar(conn, qu, 1))
  delta = qnew - qold
  qold = qnew
  print(datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S')[0:19] + ',' + str(delta))





