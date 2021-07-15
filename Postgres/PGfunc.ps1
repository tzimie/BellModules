param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/pgODBC.ps1

parse $tags
$srv = $tagval.server
$conn = $tagval.Conn
$schema = $tagval.schema
$proname = $tagval.proname

$q = @"
SELECT prosrc as str FROM pg_proc p
  left join pg_namespace n on p.pronamespace = n.oid
  WHERE proname='$proname' and n.nspname='$schema'
"@
$src = ODBCstring $conn $q

$qarg = @"
SELECT pg_get_function_arguments(p.oid) as str FROM pg_proc p
  left join pg_namespace n on p.pronamespace = n.oid
  WHERE proname='$proname' and n.nspname='$schema'
"@
$arg = ODBCstring $conn $qarg
$src = @"
create or replace procedure $schema.$proname
  ($arg)
  language plpgsql
as $$
$src
$$
"@

$keywords = @('PROCEDURE', 'ALL', 'FETCH', 'ALTER', 'FILE', 'AND', 'ANY', 'FOR', 'DECLARE', `
  'AS', 'FOREIGN', 'ASC', 'REFERENCES', 'AUTHORIZATION', 'REPLICATION', 'BACKUP', 'FROM', `
  'RESTORE', 'BEGIN', 'FULL', 'BETWEEN', 'FUNCTION', 'RETURN', 'BREAK', 'GOTO',  'GRANT', 'REVOKE', `
  'GROUP', 'RIGHT', 'BY', 'HAVING', 'ROLLBACK', 'CASCADE', 'CASE', 'IDENTITY', 'CHECK', `
  'RULE', 'CLOSE', 'IF', 'SCHEMA', 'CLUSTERED', 'IN', 'COALESCE', 'INDEX', 'SELECT', `
  'INNER', 'COLUMN', 'INSERT', 'COMMIT', 'INTERSECT', 'COMPUTE', 'INTO', 'CONSTRAINT', 'IS', 'SET', 'CONTAINS', `
  'JOIN', 'KEY', 'CONTINUE', 'KILL', 'SOME', 'CONVERT', 'LEFT', 'STATISTICS', 'CREATE', 'LIKE', `
  'CROSS', 'TABLE', 'CURRENT', 'LOAD', 'CURRENT_DATE', 'MERGE', 'TEXTSIZE', 'CURRENT_TIME', 'THEN', 'CURRENT_TIMESTAMP', 'NOCHECK', `
  'TO', 'NONCLUSTERED', 'TOP', 'CURSOR', 'NOT', 'TRAN', 'DATABASE', 'NULL', 'TRANSACTION', 'DBCC', 'NULLIF', 'TRIGGER', 'DEALLOCATE', `
  'OF', 'TRUNCATE', 'OFF', 'DEFAULT', 'OFFSETS', 'DELETE', 'ON', 'UNION', 'DENY', 'OPEN', 'UNIQUE', 'DESC', `
  'UPDATE', 'DISTINCT', 'DOUBLE', `
  'OPTION', 'USER', 'DROP', 'OR', 'VALUES', 'DUMP', 'ORDER', 'VARYING', 'ELSE', 'OUTER', 'VIEW', 'END', 'OVER', 'PERCENT', `
  'WHEN', 'ESCAPE', 'WHERE', 'EXCEPT', 'PLAN', 'WHILE', 'EXEC', 'PRECISION', 'WITH', 'EXECUTE', 'PRIMARY', 'WITHIN', 'EXISTS', 'PRINT', `
  'PROC', 'REPLACE', 'LANGUAGE')

'<font face="Lucida Console" size="2">'
foreach ($k in $keywords) {
  $src = $src -iReplace "(\W)($k)(\W)", '$1{blue}$2{black}$3'
  $src = $src -iReplace "^($k)(\W)", '{blue}$1{black}$2'
  $src = $src -iReplace "(\W)($k)$", '$1{blue}$2{black}'
  $src = $src -iReplace "^($k)$", '{blue}$1{black}'
  }
$src = $src -Replace "'(.*?)'", "{green}$&{black}"
$src = $src.replace(" ","&nbsp;").replace(">", "&gt;").replace("<","&lt;")
$src = $src -Replace "{blue}", '<font color="blue">'
$src = $src -Replace "{black}", '<font color="black">'
$src = $src -Replace "{green}", '<font color="green">'
$src = $src.Replace("`n", "<br>")
$src

