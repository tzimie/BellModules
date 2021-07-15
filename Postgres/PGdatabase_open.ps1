param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/pgODBC.ps1

@"
Tables|PGtables|folder|$tags
Procedures|PGprocs|folder|$tags
Functions|PGfuncs|folder|$tags
Top 30 tables by size|PGbiggesttables|html|$tags
Query stats - 10 sec|PGstats10s|html|$tags
Chart 30 sec - Transactions|PGtrans|chart|$tags
Chart 30 sec - Blocks|PGblocks|chart|$tags
Chart 30 sec - Tuples|PGtuples|chart|$tags
"@
