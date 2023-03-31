from bell import *
from MSSQLquery import *

usr, grp, name, tags, tagval = bellparams()

srv = tagval['Server']
conn = tagval['Conn']

s = f"""SQL jobs status|MSSQLjobs|html|{tags}
SQL server CPU - last few minutes|MSSQLinstantcpu|chart|{tags}
SQL current activity - 10secs|MSSQLcurrentactivity|html|{tags}
SQL locks in progress|MSSQLlocks|html|{tags}
SQL active expensive queries|MSSQLactiveq|html|{tags}
SQL Performance|MSSQLperf|folder|{tags}
TreeMap or IO per database files|MSSQLiotreemap|html|{tags}
TreeMap sizes of all databases, tables and indexes|MSSQLsrvtreemap|html|{tags}
TreeMap database files and drive space|MSSQLdrvtreemap|html|{tags}
SQL database size and free space|MSSQLspace|html|{tags}"""
print(s)

d = MSSQLquery(conn,"select DB_NAME(DbId) as name,sum(BytesOnDisk/1000/1000./1000.) as Gb from ::fn_virtualfilestats(null,null) where DbId>4 group by DbId")

# user databases
for s in d:
  dbname = str(s[0])
  dbsize = float(s[1])
  print(f'db {dbname} ({dbsize}Gb)|MSSQLdatabase|folder|{tags};Database={dbname}~dbname={dbname}')
