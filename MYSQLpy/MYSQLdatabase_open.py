from bell import *
from MYSQLquery import *
import datetime

usr, grp, name, tags, tagval = bellparams()

print(f"""Tables|MYSQLtables|folder|{tags}
Procedures|MYSQLprocs|folder|{tags}
Functions|MYSQLfuncs|folder|{tags}
Top 30 tables by size|MYSQLbiggesttables|html|{tags}
Chart 30 sec - Logical Fetches and Writes|MYSQLrw|chart|{tags}""")
