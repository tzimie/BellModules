from bell import *
from MSSQLquery import *
import re

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']
name = tagval['name']

keywords = ['PROCEDURE', 'ALL', 'FETCH', 'PUBLIC', 'ALTER', 'FILE', 'RAISERROR', 'AND', 'FILLFACTOR', 'READ', 'ANY', 'FOR', 'READTEXT', \
  'AS', 'FOREIGN', 'RECONFIGURE', 'ASC', 'FREETEXT', 'REFERENCES', 'AUTHORIZATION', 'FREETEXTTABLE', 'REPLICATION', 'BACKUP', 'FROM', \
  'RESTORE', 'BEGIN', 'FULL', 'RESTRICT', 'BETWEEN', 'FUNCTION', 'RETURN', 'BREAK', 'GOTO', 'REVERT', 'BROWSE', 'GRANT', 'REVOKE', 'BULK', \
  'GROUP', 'RIGHT', 'BY', 'HAVING', 'ROLLBACK', 'CASCADE', 'HOLDLOCK', 'ROWCOUNT', 'CASE', 'IDENTITY', 'ROWGUIDCOL', 'CHECK', 'IDENTITY_INSERT', \
  'RULE', 'CHECKPOINT', 'IDENTITYCOL', 'SAVE', 'CLOSE', 'IF', 'SCHEMA', 'CLUSTERED', 'IN', 'SECURITYAUDIT', 'COALESCE', 'INDEX', 'SELECT', \
  'COLLATE', 'INNER', 'COLUMN', 'INSERT', 'COMMIT', 'INTERSECT', 'COMPUTE', 'INTO', 'SESSION_USER', 'CONSTRAINT', 'IS', 'SET', 'CONTAINS', \
  'JOIN', 'SETUSER', 'CONTAINSTABLE', 'KEY', 'SHUTDOWN', 'CONTINUE', 'KILL', 'SOME', 'CONVERT', 'LEFT', 'STATISTICS', 'CREATE', 'LIKE', 'SYSTEM_USER', \
  'CROSS', 'TABLE', 'CURRENT', 'LOAD', 'CURRENT_DATE', 'MERGE', 'TEXTSIZE', 'CURRENT_TIME', 'NATIONAL', 'THEN', 'CURRENT_TIMESTAMP', 'NOCHECK', \
  'TO', 'CURRENT_USER', 'NONCLUSTERED', 'TOP', 'CURSOR', 'NOT', 'TRAN', 'DATABASE', 'NULL', 'TRANSACTION', 'DBCC', 'NULLIF', 'TRIGGER', 'DEALLOCATE', \
  'OF', 'TRUNCATE', 'DECLARE', 'OFF', 'TRY_CONVERT', 'DEFAULT', 'OFFSETS', 'TSEQUAL', 'DELETE', 'ON', 'UNION', 'DENY', 'OPEN', 'UNIQUE', 'DESC', \
  'OPENDATASOURCE', 'UNPIVOT', 'DISK', 'OPENQUERY', 'UPDATE', 'DISTINCT', 'OPENROWSET', 'UPDATETEXT', 'DISTRIBUTED', 'OPENXML', 'USE', 'DOUBLE', \
  'OPTION', 'USER', 'DROP', 'OR', 'VALUES', 'DUMP', 'ORDER', 'VARYING', 'ELSE', 'OUTER', 'VIEW', 'END', 'OVER', 'WAITFOR', 'ERRLVL', 'PERCENT', \
  'WHEN', 'ESCAPE', 'PIVOT', 'WHERE', 'EXCEPT', 'PLAN', 'WHILE', 'EXEC', 'PRECISION', 'WITH', 'EXECUTE', 'PRIMARY', 'WITHIN', 'EXISTS', 'PRINT', \
  'WRITETEXT', 'EXIT', 'PROC', 'NOCOUNT']

d1 = MSSQLquery(conn, f"exec sp_helptext '{name}'")
print('<font face="Lucida Console" size="3">')

# replace end line comments with {e} and /* */ comments with {m} to avoud parsing
code = ''
ecomment = []
mcomment = []
textlines = []
eating = False # flag that we eat multiline comment
for l in d1:
  ln = str(l[0]).replace("\t"," ")
  if eating:
    if "*/" in ln: # multiline comment ended
      forming += ln.split('*/')[0] + '*/'
      mcomment.append(forming)
      eating = False
      ln = ln.split('*/',1)[1]
    else: # another line in comment
      forming += ln + "<br>"
      ln = '{skip}'
  if "--" in ln:
    ecomment.append(ln.split("--",1)[1])
    ln = ln.split("--",1)[0] + "{e}"
  if "/*" in ln and not("*/") in ln: # starting multi line comment
    forming = ln.split("/*", 1)[1] + "<br>"
    ln = ln.split("/*",1)[0] + "{m}"
    eating = True
  elif "/*" in ln: # /* */ in a single line
    while "/*" in ln:
      l = ln.split('/*', 1)[0]
      r = ln.split('/*', 1)[1]
      forming = r.split('*/', 1)[0]
      r = r.split('*/',1 )[1]
      ln = l + '{m}' + r
      mcomment.append(forming + '*/')
  if ln != '{skip}': textlines.append(ln)

for ln in textlines:
  ln = re.sub("'(.*?)'", "{green}'\\1'{black}", ln)
  for k in keywords:
    pat = "(\W)(" + k + ")(\W)"
    ln = re.sub(pat, "\\1{blue}\\2{black}\\3", ln, flags=re.IGNORECASE)
    pat = "^(" + k + ")(\W)"
    ln = re.sub(pat, "{blue}\\1{black}\\2", ln, flags=re.IGNORECASE)
    pat = "(\W)(" + k + ")$"
    ln = re.sub(pat, "\\1{blue}\\2{black}", ln, flags=re.IGNORECASE)
    pat = "^(" + k + ")$"
    ln = re.sub(pat, "{blue}\\1{black}", ln, flags=re.IGNORECASE)
  ln = ln.replace(" ","&nbsp;").replace(">", "&gt;").replace("<","&lt;")
  ln = ln.replace("{blue}", '<font color="blue">')
  ln = ln.replace("{black}", '<font color="black">')
  ln = ln.replace("{green}", '<font color="green">')
  if ln.endswith("{e}"):
    ln = ln[:-3] + '<font color="gray">--' + ecomment.pop(0) + '<font color="black">'
  while "{m}" in ln:
    l = ln.split("{m}", 1)[0]
    r = ln.split("{m}", 1)[1]
    ln = l + '<font color="gray">/*' + mcomment.pop(0) + '<font color="black">' + r
  code += ln + '<br>'
print(code)


