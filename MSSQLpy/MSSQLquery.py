import pyodbc
from datetime import datetime

def MSSQLscalar(constr, query, prequery=''):
  curs = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};'+constr).cursor()
  if prequery>'': curs.execute(prequery)
  curs.execute(query)
  row = curs.fetchone()
  return row[0]

def MSSQLquery(constr, query, prequery=''):
  curs = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};'+constr).cursor()
  if prequery>'': curs.execute(prequery)
  curs.execute(query)
  grid = []
  row = curs.fetchone()
  while row:
    grid.append(row)
    row = curs.fetchone()
  return grid

def MSSQLqueryH(constr, query, prequery=''): # with header
  curs = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};'+constr).cursor()
  if prequery>'': curs.execute(prequery)
  curs.execute(query)
  cols = tuple([column[0] for column in curs.description])
  grid = [cols]
  row = curs.fetchone()
  while row:
    grid.append(row)
    row = curs.fetchone()
  return grid

def MSSQLqueryHB(constr, query, prequery=''): # with header, making columns bold
  curs = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};'+constr).cursor()
  if prequery>'': curs.execute(prequery)
  curs.execute(query)
  cols = ['{bold}'+str(column[0])+'{nobold}' for column in curs.description]
  grid = [tuple(cols)]
  row = curs.fetchone()
  while row:
    grid.append(row)
    row = curs.fetchone()
  return grid

def MSSQLchart(constr, query):
  curs = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};'+constr).cursor()
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

