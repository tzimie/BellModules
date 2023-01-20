from bell import *
from MYSQLquery import *

usr, grp, name, tags, tagval = bellparams()

keywords = ['PROCEDURE', 'ALL', 'FETCH', 'ALTER', 'FILE', 'AND', 'ANY', 'FOR', 'DECLARE', \
  'AS', 'FOREIGN', 'ASC', 'REFERENCES', 'AUTHORIZATION', 'REPLICATION', 'BACKUP', 'FROM', \
  'RESTORE', 'BEGIN', 'FULL', 'BETWEEN', 'FUNCTION', 'RETURN', 'BREAK', 'GOTO',  'GRANT', 'REVOKE', \
  'GROUP', 'RIGHT', 'BY', 'HAVING', 'ROLLBACK', 'CASCADE', 'CASE', 'IDENTITY', 'CHECK', \
  'RULE', 'CLOSE', 'IF', 'SCHEMA', 'CLUSTERED', 'IN', 'COALESCE', 'INDEX', 'SELECT', \
  'INNER', 'COLUMN', 'INSERT', 'COMMIT', 'INTERSECT', 'COMPUTE', 'INTO', 'CONSTRAINT', 'IS', 'SET', 'CONTAINS', \
  'JOIN', 'KEY', 'CONTINUE', 'KILL', 'SOME', 'CONVERT', 'LEFT', 'STATISTICS', 'CREATE', 'LIKE', \
  'CROSS', 'TABLE', 'CURRENT', 'LOAD', 'CURRENT_DATE', 'MERGE', 'TEXTSIZE', 'CURRENT_TIME', 'THEN', 'CURRENT_TIMESTAMP', 'NOCHECK', \
  'TO', 'NONCLUSTERED', 'TOP', 'CURSOR', 'NOT', 'TRAN', 'DATABASE', 'NULL', 'TRANSACTION', 'DBCC', 'NULLIF', 'TRIGGER', 'DEALLOCATE', \
  'OF', 'TRUNCATE', 'OFF', 'DEFAULT', 'OFFSETS', 'DELETE', 'ON', 'UNION', 'DENY', 'OPEN', 'UNIQUE', 'DESC', \
  'UPDATE', 'DISTINCT', 'DOUBLE', \
  'OPTION', 'USER', 'DROP', 'OR', 'VALUES', 'DUMP', 'ORDER', 'VARYING', 'ELSE', 'OUTER', 'VIEW', 'END', 'OVER', 'PERCENT', \
  'WHEN', 'ESCAPE', 'WHERE', 'EXCEPT', 'PLAN', 'WHILE', 'EXEC', 'PRECISION', 'WITH', 'EXECUTE', 'PRIMARY', 'WITHIN', 'EXISTS', 'PRINT', \
  'PROC', 'REPLACE', 'LANGUAGE', 'DEFINER']

conn = tagval['Conn']
proname = tagval['proname']

src = str(MYSQLscalar(conn, f"SHOW CREATE FUNCTION `{proname}`", 2))

print('<font face="Lucida Console" size="3">')
# looks like comments in MYSQL dissapear when procedure is sent tos erver
code = ''
textlines = []
for l in src.splitlines():
  ln = l.replace("\t"," ")
  ln = re.sub("'(.*?)'", "{green}'\\1'{black}", ln)
  ln = re.sub("`(.*?)`", "{maroon}'\\1'{black}", ln)
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
  ln = ln.replace("{maroon}", '<font color="maroon">')
  if ln.endswith("{e}"):
    ln = ln[:-3] + '<font color="gray">--' + ecomment.pop(0) + '<font color="black">'
  while "{m}" in ln:
    l = ln.split("{m}", 1)[0]
    r = ln.split("{m}", 1)[1]
    ln = l + '<font color="gray">/*' + mcomment.pop(0) + '<font color="black">' + r
  code += ln + '<br>'
print(code)

