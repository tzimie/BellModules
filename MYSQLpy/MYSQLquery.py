import pymysql
from datetime import datetime

def MYSQLscalar(constr, query, colnum = 0):
  conparts = {}
  for a in constr.split(' '):
    assignment = a.split('=',1)
    conparts[assignment[0]] = assignment[1]
  curs = pymysql.connect(host=conparts['host'], user=conparts['user'], password = conparts['password'], database=conparts['database']).cursor()
  curs.execute(query)
  row = curs.fetchone()
  return row[colnum]

def MYSQLscalar2(constr, query):
  conparts = {}
  for a in constr.split(' '):
    assignment = a.split('=',1)
    conparts[assignment[0]] = assignment[1]
  curs = pymysql.connect(host=conparts['host'], user=conparts['user'], password = conparts['password'], database=conparts['database']).cursor()
  curs.execute(query)
  row = curs.fetchone()
  return row[0], row[1]

def MYSQLquery(constr, query):
  conparts = {}
  for a in constr.split(' '):
    assignment = a.split('=',1)
    conparts[assignment[0]] = assignment[1]
  curs = pymysql.connect(host=conparts['host'], user=conparts['user'], password = conparts['password'], database=conparts['database']).cursor()
  curs.execute(query)
  grid = []
  row = curs.fetchone()
  while row:
    grid.append(row)
    row = curs.fetchone()
  return grid

def MYSQLqueryH(constr, query): # with header
  conparts = {}
  for a in constr.split(' '):
    assignment = a.split('=',1)
    conparts[assignment[0]] = assignment[1]
  curs = pymysql.connect(host=conparts['host'], user=conparts['user'], password = conparts['password'], database=conparts['database']).cursor()
  curs.execute(query)
  cols = tuple([column[0] for column in curs.description])
  grid = [cols]
  row = curs.fetchone()
  while row:
    grid.append(row)
    row = curs.fetchone()
  return grid

def MYSQLqueryHB(constr, query): # with header, making columns bold
  conparts = {}
  for a in constr.split(' '):
    assignment = a.split('=',1)
    conparts[assignment[0]] = assignment[1]
  curs = pymysql.connect(host=conparts['host'], user=conparts['user'], password = conparts['password'], database=conparts['database']).cursor()
  curs.execute(query)
  cols = ['{bold}'+str(column[0])+'{nobold}' for column in curs.description]
  grid = [tuple(cols)]
  row = curs.fetchone()
  while row:
    grid.append(row)
    row = curs.fetchone()
  return grid

def MYSQLchart(constr, query):
  conparts = {}
  for a in constr.split(' '):
    assignment = a.split('=',1)
    conparts[assignment[0]] = assignment[1]
  curs = pymysql.connect(host=conparts['host'], user=conparts['user'], password = conparts['password'], database=conparts['database']).cursor()
  curs.execute(query)
  row = curs.fetchone()
  cols = ','.join([column[0] for column in curs.description])
  print(cols)
  while row:
    n = 0
    for c in row:
      if n == 0: thisline = row[0].strftime('%Y-%m-%dT%H:%M:%S')[0:19]
      else: thisline += ','+str(row[n])
      n += 1
    print(thisline)
    row = curs.fetchone()
  return

