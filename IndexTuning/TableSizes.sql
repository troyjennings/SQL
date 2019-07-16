SELECT a.SchemaName, a.TableName, SUM(a.IndexSize_MB), SUM(a.TotalRows)
FROM (
SELECT
s.name AS SchemaName,
OBJECT_NAME(i.OBJECT_ID) AS TableName,
i.name AS IndexName,
i.index_id AS IndexID,
8.0 * SUM(a.used_pages) / 1024 AS IndexSize_MB,
SUM(a.total_pages) AS TotalPages, 
    SUM(a.used_pages) AS UsedPages, 
    (SUM(a.total_pages) - SUM(a.used_pages)) AS UnusedPages,
SUM(p.rows) AS TotalRows
FROM sys.indexes AS i
JOIN sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
JOIN sys.tables as t ON i.object_id = t.object_id
JOIN sys.schemas as s ON s.schema_id = t.schema_id
WHERE i.index_id > 0
GROUP BY i.OBJECT_ID,i.index_id,i.name,s.name ) AS a
GROUP BY a.SchemaName, a.TableName
ORDER BY SUM(a.IndexSize_MB) DESC