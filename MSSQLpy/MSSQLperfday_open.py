from bell import *
from MSSQLquery import *
import datetime

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']

print('SQL ErrorLog|MSSQLerrorlog|text|'+tags)
if MSSQLscalar(conn,"select count(*) as cnt from master.dbo.sysdatabases where name='ReportServer'")>0:
  print('Report Server Data|MSSQLreportserver|html|'+tags)
