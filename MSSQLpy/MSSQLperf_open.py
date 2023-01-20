from bell import *
from MSSQLquery import *
import datetime

usr, grp, name, tags, tagval = bellparams()

today = datetime.datetime.today().date()
for d in range(7):
  day = today - datetime.timedelta(d)
  dayfmt = str(day)
  dayname = dayfmt
  if d == 0: dayname += " (Today)"
  if d == 1: dayname += " (Yesterday)"
  print(f'{dayname}|MSSQLperfday|folder|{tags}~day={dayfmt}~daysback={d}')

