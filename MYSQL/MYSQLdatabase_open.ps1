param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/ODBC.ps1

@"
Tables|MYSQLtables|folder|$tags
Procedures|MYSQLprocs|folder|$tags
Functions|MYSQLfuncs|folder|$tags
Top 30 tables by size|MYSQLbiggesttables|html|$tags
Chart 30 sec - Logical Fetches and Writes|MYSQLrw|chart|$tags
"@
