from bell import *
from MSSQLquery import *

usr, grp, name, tags, tagval = bellparams()

print(f"""Top 30 tables by size|MSSQLbiggesttables|html|{tags}
Tables|MSSQLobjects|folder|{tags}~Obj=U
Scalar Functions|MSSQLobjects|folder|{tags}~Obj=FN
Table Functions|MSSQLobjects|folder|{tags}~Obj=TF
Views|MSSQLobjects|folder|{tags}~Obj=V
Procedures|MSSQLobjects|folder|{tags}~Obj=P""")
