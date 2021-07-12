param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1
parse $tags

$Header = @"
<style>
.X-red { color: red; background-color: yellow; }
.X-green { color: green; background-color: white; }
.X-yellow { color: black; background-color: #FFFFE0; }
.X-default { color: black; background-color: white; }
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@  

$q = @"
-- What SPIDs consume CPU right now - 10 sec analysis
declare @c table(spid int, cpu bigint)
declare @c2 table(spid int, cpu bigint)
insert into @c select spid,sum(convert(bigint,cpu)) as cpu from sysprocesses group by spid
waitfor delay '00:00:10'
insert into @c2 select spid,sum(convert(bigint,cpu)) as cpu from sysprocesses group by spid
declare @delta table(spid int, cpu bigint)
insert into @delta select top 10 A.spid,B.cpu-A.cpu from @c A, @c2 B where A.spid=B.spid order by 2 desc
select D.cpu as delta,P.* 
into #s from sysprocesses P, @delta D where D.spid=P.spid order by 1 desc
--
create table #dbcc (eventtype varchar(128), par int, cmd varchar(max))
create table #cmd (spid int, cmd varchar(max))
declare @conn int, @sql varchar(128)
DECLARE se CURSOR FOR SELECT spid from #s 
OPEN se;  
  FETCH NEXT FROM se into @conn
  WHILE @@FETCH_STATUS = 0  
  BEGIN  
    truncate table #dbcc
    set @sql='dbcc inputbuffer('+CONVERT(varchar,@conn)+')'
    insert into #dbcc exec(@sql)
    insert into #cmd (spid,cmd) select @conn,cmd from #dbcc
    FETCH NEXT FROM se into @conn 
  END  
  CLOSE se;  
  DEALLOCATE se; 
select isnull(C.cmd,'') as SQLCMD,S.* into #p2 from #s S inner join #cmd C on C.spid=S.spid

-- set cursors
update #p2 set SQLCMD=ltrim(u.text)
  from (select spid,t.text from
    (
    select p.spid,cu.sql_handle from #p2 p
    CROSS APPLY sys.dm_exec_cursors (p.spid) cu
    where p.SQLCMD like 'FETCH API_CURSOR%'
    ) x
    cross apply sys.dm_exec_sql_text (x.sql_handle) t
  ) u where u.spid=#p2.spid
select D.name as dbname,SQLCMD,case when delta>9000 then '{red}' when delta>5000 then '{yellow}' else '' end+convert(varchar,delta) as delta_ms,spid,blocked,cpu,physical_io,last_batch,hostname,program_name,loginame 
  from #p2 
  inner join sysdatabases D on D.dbid=#p2.dbid
  where delta>0
  order by delta desc
"@

$conn = $tagval.Conn 
$d = MSSQLquery $conn $q | Select-Object -Property * -ExcludeProperty "ItemArray", "RowError", "RowState", "Table", "HasErrors"
$html = $d | ConvertTo-HTML -Title "Rows" -Head $Header -body '<h2>SQL server activity for 15 sec interval</h2>' 
$html = $html -Replace '<td>{(.*?)}', '<td class="X-$1">'
$html
