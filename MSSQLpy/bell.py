import sys
import re
from tabulate import tabulate

def bellparams():
  usr = sys.argv[1]
  grp = sys.argv[2]
  name = sys.argv[3]
  tags = sys.argv[4]  
  tagval = {}
  for a in tags.split('~'):
    if a == '': continue
    assignment = a.split('=',1)
    tagval[assignment[0]] = assignment[1]
  return usr, grp, name, tags, tagval

def makegrid(s):
  s = tabulate(s, tablefmt='html').replace('{bold}', '<strong>').replace('{nobold}', '</strong>') # for header
  s = re.sub("<td>{(.*?)}",'<td class="X-\\1">', s)
  return s
