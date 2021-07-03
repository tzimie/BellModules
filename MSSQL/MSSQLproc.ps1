param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1
parse $tags
if (-not $tagval.Conn) { exit }

$conn = $tagval.Conn 
$dbname = $tagval.dbname
$name = $tagval.name

$keywords = @('PROCEDURE', 'ALL', 'FETCH', 'PUBLIC', 'ALTER', 'FILE', 'RAISERROR', 'AND', 'FILLFACTOR', 'READ', 'ANY', 'FOR', 'READTEXT', `
  'AS', 'FOREIGN', 'RECONFIGURE', 'ASC', 'FREETEXT', 'REFERENCES', 'AUTHORIZATION', 'FREETEXTTABLE', 'REPLICATION', 'BACKUP', 'FROM', `
  'RESTORE', 'BEGIN', 'FULL', 'RESTRICT', 'BETWEEN', 'FUNCTION', 'RETURN', 'BREAK', 'GOTO', 'REVERT', 'BROWSE', 'GRANT', 'REVOKE', 'BULK', `
  'GROUP', 'RIGHT', 'BY', 'HAVING', 'ROLLBACK', 'CASCADE', 'HOLDLOCK', 'ROWCOUNT', 'CASE', 'IDENTITY', 'ROWGUIDCOL', 'CHECK', 'IDENTITY_INSERT', `
  'RULE', 'CHECKPOINT', 'IDENTITYCOL', 'SAVE', 'CLOSE', 'IF', 'SCHEMA', 'CLUSTERED', 'IN', 'SECURITYAUDIT', 'COALESCE', 'INDEX', 'SELECT', `
  'COLLATE', 'INNER', 'COLUMN', 'INSERT', 'COMMIT', 'INTERSECT', 'COMPUTE', 'INTO', 'SESSION_USER', 'CONSTRAINT', 'IS', 'SET', 'CONTAINS', `
  'JOIN', 'SETUSER', 'CONTAINSTABLE', 'KEY', 'SHUTDOWN', 'CONTINUE', 'KILL', 'SOME', 'CONVERT', 'LEFT', 'STATISTICS', 'CREATE', 'LIKE', 'SYSTEM_USER', `
  'CROSS', 'TABLE', 'CURRENT', 'LOAD', 'CURRENT_DATE', 'MERGE', 'TEXTSIZE', 'CURRENT_TIME', 'NATIONAL', 'THEN', 'CURRENT_TIMESTAMP', 'NOCHECK', `
  'TO', 'CURRENT_USER', 'NONCLUSTERED', 'TOP', 'CURSOR', 'NOT', 'TRAN', 'DATABASE', 'NULL', 'TRANSACTION', 'DBCC', 'NULLIF', 'TRIGGER', 'DEALLOCATE', `
  'OF', 'TRUNCATE', 'DECLARE', 'OFF', 'TRY_CONVERT', 'DEFAULT', 'OFFSETS', 'TSEQUAL', 'DELETE', 'ON', 'UNION', 'DENY', 'OPEN', 'UNIQUE', 'DESC', `
  'OPENDATASOURCE', 'UNPIVOT', 'DISK', 'OPENQUERY', 'UPDATE', 'DISTINCT', 'OPENROWSET', 'UPDATETEXT', 'DISTRIBUTED', 'OPENXML', 'USE', 'DOUBLE', `
  'OPTION', 'USER', 'DROP', 'OR', 'VALUES', 'DUMP', 'ORDER', 'VARYING', 'ELSE', 'OUTER', 'VIEW', 'END', 'OVER', 'WAITFOR', 'ERRLVL', 'PERCENT', `
  'WHEN', 'ESCAPE', 'PIVOT', 'WHERE', 'EXCEPT', 'PLAN', 'WHILE', 'EXEC', 'PRECISION', 'WITH', 'EXECUTE', 'PRIMARY', 'WITHIN', 'EXISTS', 'PRINT', `
  'WRITETEXT', 'EXIT', 'PROC', 'NOCOUNT')

$d = MSSQLquery $conn "exec sp_helptext '$name'"
'<font face="Lucida Console" size="2">'
foreach ($l in $d) {
  $ln = $l.Text
  $ln = $ln.replace("`n","").replace("`r","").replace("`t"," ")
  foreach ($k in $keywords) {
    $ln = $ln -iReplace "(\W)($k)(\W)", '$1{blue}$2{black}$3'
    $ln = $ln -iReplace "^($k)(\W)", '{blue}$1{black}$2'
    $ln = $ln -iReplace "(\W)($k)$", '$1{blue}$2{black}'
    $ln = $ln -iReplace "^($k)$", '{blue}$1{black}'
    }
  $ln = $ln -Replace "'(.*?)'", "{green}$&{black}"
  $ln = $ln.replace(" ","&nbsp;").replace(">", "&gt;").replace("<","&lt;")
  $ln = $ln -Replace "{blue}", '<font color="blue">'
  $ln = $ln -Replace "{black}", '<font color="black">'
  $ln = $ln -Replace "{green}", '<font color="green">'
  "$ln<br>"
}

