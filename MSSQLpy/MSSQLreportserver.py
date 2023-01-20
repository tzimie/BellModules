from bell import *
from MSSQLquery import *

usr, grp, name, tags, tagval = bellparams()

Header = """<style>
.X-red { color: red; background-color: yellow; }
.X-green { color: green; background-color: white; }
.X-yellow { color: black; background-color: #FFFFE0; }
.X-default { color: black; background-color: white; }
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>"""

q = """select (select Name from ReportServer.dbo.Catalog where ItemID=ReportID) as Name,
  UserName,Format,TimeStart,TimeEnd,datediff(ss,TimeStart,TimeEnd) as Seconds,
  case when Status<>'rsSuccess' then '{red}' else '' end +Status as Status,ByteCount,[RowCount] 
  from ReportServer.dbo.ExecutionLogStorage
  where TimeStart>=convert(datetime,'$day') and TimeStart<convert(datetime,'$day')+1
  order by TimeStart"""

conn = tagval['Conn']

d1 = MSSQLqueryHB(conn, q)
print('<h1>MSRS report</h1>')
print(Header)
print(makegrid(d1))



