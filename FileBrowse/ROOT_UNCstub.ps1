# this is a stub.
# it creates a directory C:,D: for the current computer.
# replace with UNC path from some inventory

param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

@'
C:|UNC|folder|dir=C:
D:|UNC|folder|dir=D:
\\localhost\C$|UNC|folder|dir=\\localhost\C$
\\localhost\D$|UNC|folder|dir=\\localhost\D$
'@

