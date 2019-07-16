-- Unused Nonclustered Index Script
-- Original Author: Pinal Dave 
-- Modified : Troy Jennings

DECLARE @SeekThreshold INT, @ScanThreshold INT

SET @SeekThreshold = 10
SET @ScanThreshold = 1000

;WITH IndexSize AS(
SELECT
s.name AS SchemaName,
OBJECT_NAME(i.OBJECT_ID) AS TableName,
i.name AS IndexName,
i.index_id AS IndexID,
8 * SUM(a.used_pages) / 1024 AS IndexSize_MB
FROM sys.indexes AS i
JOIN sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
JOIN sys.tables as t ON i.object_id = t.object_id
JOIN sys.schemas as s ON s.schema_id = t.schema_id
WHERE i.index_id > 0
GROUP BY i.OBJECT_ID,i.index_id,i.name,s.name
)

SELECT TOP 250
s.name AS SchemaName
,o.name AS TableName
, i.name AS IndexName
, i.index_id AS IndexID
, i.is_disabled AS IsDisabled
, dm_ius.user_seeks AS UserSeek
, dm_ius.user_scans AS UserScans
, dm_ius.user_lookups AS UserLookups
, dm_ius.user_updates AS UserUpdates
, p.TableRows
, z.IndexSize_MB
FROM  sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats dm_ius ON i.index_id = dm_ius.index_id 
AND dm_ius.OBJECT_ID = i.OBJECT_ID AND dm_ius.database_id = DB_ID() AND  OBJECTPROPERTY(dm_ius.OBJECT_ID,'IsUserTable') = 1
INNER JOIN sys.objects o ON i.OBJECT_ID = o.OBJECT_ID
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
LEFT JOIN IndexSize z ON z.SchemaName = s.name AND z.TableName = o.name AND z.IndexName = i.name
LEFT JOIN (SELECT SUM(p.rows) TableRows, p.index_id, p.OBJECT_ID
FROM sys.partitions p GROUP BY p.index_id, p.OBJECT_ID) p
ON p.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = p.OBJECT_ID
WHERE
i.type_desc = 'nonclustered'
AND i.is_primary_key = 0
AND i.is_unique_constraint = 0
AND 
(
  (dm_ius.user_seeks <= @SeekThreshold
  AND 
  dm_ius.user_scans <= @ScanThreshold)
  OR
  ((dm_ius.user_seeks*1000) < dm_ius.user_scans)
)
ORDER BY z.IndexSize_MB DESC
