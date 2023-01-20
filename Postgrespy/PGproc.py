from bell import *
from PGquery import *

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
  'PROC', 'REPLACE', 'LANGUAGE']

conn = tagval['Conn']
schema = tagval['schema']
proname = tagval['proname']

q = f"""SELECT prosrc as str FROM pg_proc p
  left join pg_namespace n on p.pronamespace = n.oid
  WHERE proname='{proname}' and n.nspname='{schema}'"""

src = str(PGscalar(conn, q))

qarg = f"""SELECT pg_get_function_arguments(p.oid) as str FROM pg_proc p
  left join pg_namespace n on p.pronamespace = n.oid
  WHERE proname='{proname}' and n.nspname='{schema}'"""

arg = str(PGscalar(conn, qarg))

src = f"""create or replace procedure {schema}.{proname}
  ({arg})
  language plpgsql
as $$
{src}
$$"""

print('<font face="Lucida Console" size="3">')
# replace end line comments with {e} and /* */ comments with {m} to avoud parsing
code = ''
ecomment = []
mcomment = []
textlines = []
eating = False # flag that we eat multiline comment
for l in src.splitlines():
  ln = l.replace("\t"," ")
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

