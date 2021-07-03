param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 
. $PSScriptRoot/MSSQLquery.ps1
parse $tags

$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

$q = @"
SELECT top 30
    t.name AS TableName,
    sum(p.rows) as RowCounts,
    sum(a.total_pages) as TotalPages, 
    sum(a.used_pages) as UsedPages, 
    sum(a.data_pages) as DataPages,
    (sum(a.total_pages) * 8) / 1024 as TotalSpaceMB, 
    (sum(a.used_pages) * 8) / 1024 as UsedSpaceMB, 
    (sum(a.data_pages) * 8) / 1024 as DataSpaceMB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.object_id = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
    t.name NOT LIKE 'dt%' AND
    i.object_id > 255 AND  
    i.index_id <= 1
GROUP BY 
    t.name, i.object_id, i.index_id, i.name 
ORDER BY 
    3 desc 
"@

$conn = $tagval.Conn -Replace '{sem}', ';' -Replace '{eq}','=' -Replace '{comma}',',' -Replace '{', '''' -Replace '}', '''' 
$d = MSSQLquery $conn $q | Select-Object -Property * -ExcludeProperty "ItemArray", "RowError", "RowState", "Table", "HasErrors"
$d | ConvertTo-HTML -Title "Rows" -Head $Header -body '<h2>Top 30 tables, by row count, desc</h2>' 
