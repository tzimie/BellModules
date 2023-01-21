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
$d = @"
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

'<font face="Lucida Console" size="3">'
$code = ''
[System.Collections.ArrayList] $ecomment = @()
[System.Collections.ArrayList] $mcomment = @()
[System.Collections.ArrayList] $textlines = @()
$eating = 0 # flag that we eat multiline comment
foreach ($ln in $d.Split([System.Environment]::NewLine)) {
  $ln = $ln.replace("`n","").replace("`r","").replace("`t"," ")
  if ($eating -gt 0) {
    if ($ln.Contains('*/')) { # multiline comment ended
      $forming += $ln.Split('*/')[0] + '*/'
      $mcomment += $forming
      $eating = 0
      $ln = $ln.Split('*/',2)[1]
    } else { # another line in comment
      $forming += $ln + "<br>"
      $ln = '{skip}'
      }
    }
  if ($ln.Contains('--'))
    {
    $ecomment += $ln.Split("--",2)[1]
    $ln = $ln.Split("--",2)[0] + "{e}"
    }
  if ($ln.Contains("/*") -and -not $ln.Contains("*/")) { # starting multi line comment
    $forming = $ln.Split("/*", 2)[1] + "<br>"
    $ln = $ln.Split("/*",2)[0] + "{m}"
    $eating = 1
  }
  elseif ($ln.Contains("/*")) { # /* */ in a single line
    while ($ln.Contains("/*")) {
      $l = $ln.Split('/*', 2)[0]
      $r = $ln.Split('/*', 2)[1]
      $forming = $r.Split('*/', 2)[0]
      $r = $r.Split('*/',2)[1]
      $ln = $l + '{m}' + $r
      $mcomment += $forming + '*/'
      }
    }
  if ($ln -ne '{skip}') { $textlines += $ln }
  }

foreach ($ln in $textlines) {
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
  if ($ln.Endswith("{e}")) {
    $len = $ln.Length
    $ln = $ln.Substring(0,$len-3) + '<font color="gray">--' + $ecomment[0] + '<font color="black">'
    $ecomment.RemoveAt(0)
    }
  while ($ln.Contains("{m}" )) {
    $l = $ln.Split("{m}", 2)[0]
    $r = $ln.Split("{m}", 2)[1]
    $ln = $l + '<font color="gray">/*' + $mcomment[0] + '<font color="black">' + $r
    $mcomment.RemoveAt(0)
    }
  $code += $ln + '<br>'
  }
  "$code<br>"

