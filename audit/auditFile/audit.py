import sys

usr = sys.argv[1]
grp = sys.argv[2]
name = sys.argv[3]
tags = sys.argv[4]  
stat = sys.argv[5]  
with open("bell.log", 'a') as f:
  f.write(f'{usr}|{grp}|{name}|{tags}|{stat}')
                                                               