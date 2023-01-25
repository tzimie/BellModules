import sys

usr = sys.argv[1]
grp = sys.argv[2]
name = sys.argv[3]
tags = sys.argv[4]  
err = sys.argv[5]  

#
#  Uncomment one of 3 sections below
#

############################################################## MS SQL 
#import pyodbc
#curs = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};Server=localhost;Database=BellAuditDb;UID=sa;PWD=******').cursor()
#cmd = f'exec DoAudit "{usr}","{grp}","{name}","{tags}","{err}"; commit tran;'
#curs.execute(cmd)

############################################################## Postgre
#import psycopg2
#curs = psycopg2.connect("host=localhost dbname=BellAuditDb user=CHANGE password=******").cursor()
#err=err[0:65535]
#curs.execute(f"insert into BellAudit (usr,grp,name,tags,execstatus) values ('{usr}','{grp}','{name}','{tags}','{err}');")

############################################################## MySQL
#import pymysql
#constr = "host=localhost dbname=BellAuditDb user=CHANGE password=******"
#conparts = {}
#for a in constr.split(' '):
#  assignment = a.split('=',1)
#  conparts[assignment[0]] = assignment[1]
#curs = pymysql.connect(host=conparts['host'], user=conparts['user'], password = conparts['password'], database=conparts['dbname']).cursor()
#err=err[0:10000]
#curs.execute(f"insert into BellAudit (usr,grp,name,tags,execstatus) values ('{usr}','{grp}','{name}','{tags}','{err}');")
#curs.execute("commit;")
