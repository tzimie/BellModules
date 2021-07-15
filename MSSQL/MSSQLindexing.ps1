param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1
parse $tags
if (-not $tagval.Conn) { exit }

$conn = $tagval.Conn 
$dbname = $tagval.dbname
$name = $tagval.name

$Header = @"
<style>
.X-yellow { color: black; background-color: #FFFFE0; }
.X-blue1 { color: white; background-color: #0000FF; }
.X-blue2 { color: white; background-color: #4444FF; }
.X-blue3 { color: white; background-color: #6666FF; }
.X-blue4 { color: white; background-color: #8888FF; }
.X-blue5 { color: white; background-color: #9999FF; }
.X-blue6 { color: black; background-color: #AAAAFF; }
.X-blue7 { color: black; background-color: #BBBBFF; }
.X-blue8 { color: black; background-color: #CCCCFF; }
.X-blue9 { color: black; background-color: #DDDDFF; }
.X-blue10 { color: black; background-color: #DDEEFF; }
.X-blue11 { color: black; background-color: #EEEEFF; }
.X-default { color: black; background-color: white; }
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

$q = @"
set nocount on 
declare @name varchar(128)='$name'
select I.name as iname,IC.index_column_id, C.name as colname
  into #i
  from sys.index_columns IC, sys.indexes I, sys.columns C
  where IC.object_id=object_id(@name) and I.object_id=IC.object_id and I.index_id=IC.index_id and C.object_id=I.object_id and C.column_id=IC.column_id
declare @sql varchar(8000)='create table ##p (iname varchar(128) collate database_default', @c varchar(128), @blanks varchar(4000)= ''

-- create table
DECLARE servers CURSOR FOR select name from sys.columns where object_id=object_id(@name) and name in (select colname from #i) order by column_id
OPEN servers;  
FETCH NEXT FROM servers into @c  
WHILE @@FETCH_STATUS = 0  
BEGIN  
  set @sql=@sql+' , ['+@c+'] varchar(2)'
  set @blanks=@blanks+','''''
  FETCH NEXT FROM servers into @c
END  
CLOSE servers;  
DEALLOCATE servers;
set @sql=@sql+')'
exec(@sql)

--select * from #i
set @sql='insert into ##p select distinct iname'+@blanks+' from #i '
exec(@sql)

-- create table
DECLARE servers CURSOR FOR select name from sys.columns where object_id=object_id(@name) and name in (select colname from #i) order by column_id
OPEN servers;  
FETCH NEXT FROM servers into @c  
WHILE @@FETCH_STATUS = 0  
BEGIN  
  set @sql='update ##p set ['+@c+']=convert(varchar,index_column_id) from #i where #i.colname='''+@c+''' and #i.iname=##p.iname'
  print @sql
  exec(@sql)
  FETCH NEXT FROM servers into @c
END  
CLOSE servers;  
DEALLOCATE servers;

select * from ##p
--select iname,count(*) from #i group by iname order by 2
drop table #i
drop table ##p
"@

$d = MSSQLquery $conn $q | Select-Object -Property * -ExcludeProperty "ItemArray", "RowError", "RowState", "Table", "HasErrors"
$d = $d | ConvertTo-HTML -Title "Rows" -Head $Header -body '<h2>Index coverage report</h2>' 
$d = $d -Replace '<td>(\d+)</td>', '<td class="X-blue$1">$1</td>'
$d