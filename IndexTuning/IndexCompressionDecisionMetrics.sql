--USE DSCWarehouse
--GO

DECLARE 
  @SchemaName NVARCHAR(255) = N'dbo', 
  @TableName NVARCHAR(255) = N'floor_check_audit_extra_info'

IF OBJECT_ID('tempdb..#CompressionEstimateNone') IS NOT NULL DROP TABLE #CompressionEstimateNone

CREATE TABLE #CompressionEstimateNone (TableName NVARCHAR(255), SchemaName  NVARCHAR(255), IndexID INT, PartitionNumber INT, SizeWithCurrentCompression INT, SizeWithRequestedCompression INT, SampleSizeWithCurrentCompression INT, SampleSizeWithRequestedCompression INT)

IF OBJECT_ID('tempdb..#CompressionEstimateRow') IS NOT NULL DROP TABLE #CompressionEstimateRow

CREATE TABLE #CompressionEstimateRow (TableName NVARCHAR(255), SchemaName  NVARCHAR(255), IndexID INT, PartitionNumber INT, SizeWithCurrentCompression INT, SizeWithRequestedCompression INT, SampleSizeWithCurrentCompression INT, SampleSizeWithRequestedCompression INT)

IF OBJECT_ID('tempdb..#CompressionEstimatePage') IS NOT NULL DROP TABLE #CompressionEstimatePage

CREATE TABLE #CompressionEstimatePage (TableName NVARCHAR(255), SchemaName  NVARCHAR(255), IndexID INT, PartitionNumber INT, SizeWithCurrentCompression INT, SizeWithRequestedCompression INT, SampleSizeWithCurrentCompression INT, SampleSizeWithRequestedCompression INT)

INSERT INTO #CompressionEstimateNone
EXEC sp_estimate_data_compression_savings @SchemaName, @TableName, NULL, NULL, 'NONE' ;  

INSERT INTO #CompressionEstimateRow
EXEC sp_estimate_data_compression_savings @SchemaName, @TableName, NULL, NULL, 'ROW' ;  

INSERT INTO #CompressionEstimatePage
EXEC sp_estimate_data_compression_savings @SchemaName, @TableName, NULL, NULL, 'PAGE' ;  

SELECT 
  s.name AS [SchemaName], 
  o.name AS [TableName], 
  x.name AS [IndexName],
  i.index_id AS [IndexID], 
  i.partition_number AS [Partition],
  x.type_desc AS [Index_Type],  
  pt.data_compression_desc, pt.[Rows],
  CASE WHEN pt.data_compression_desc = 'NONE' THEN 0 ELSE
    100 - CAST((n.SizeWithRequestedCompression * 100.0 / (n.SizeWithCurrentCompression + 1)) AS INT)
  END AS CompressNoneSavings,
  CASE WHEN pt.data_compression_desc = 'ROW' THEN 0 ELSE 
    100 - CAST((r.SizeWithRequestedCompression * 100.0 / (r.SizeWithCurrentCompression + 1)) AS INT) 
  END AS CompressRowSavings, 
  CASE WHEN pt.data_compression_desc = 'PAGE' THEN 0 ELSE
    100 - CAST((p.SizeWithRequestedCompression * 100.0 / (p.SizeWithCurrentCompression + 1)) AS INT) 
  END AS CompressPageSavings,
	CAST(i.leaf_update_count * 100.0 /
        (i.range_scan_count + i.leaf_insert_count
        + i.leaf_delete_count + i.leaf_update_count
        + i.leaf_page_merge_count + i.singleton_lookup_count + 1
        ) AS INT) AS [PercentUpdate],
  CAST(i.range_scan_count * 100.0 /
        (i.range_scan_count + i.leaf_insert_count
        + i.leaf_delete_count + i.leaf_update_count
        + i.leaf_page_merge_count + i.singleton_lookup_count + 1
        ) AS INT) AS [PercentScan],
  x.Fill_Factor,
  i.LEAF_ALLOCATION_COUNT AS InsertSplit,
  i.NONLEAF_ALLOCATION_COUNT AS UpdateSplit
FROM sys.dm_db_index_operational_stats (db_id(), OBJECT_ID('[' + @SchemaName + '].[' + @TableName  + ']'), NULL, NULL) i
JOIN sys.objects o ON o.object_id = i.object_id
JOIN sys.indexes x ON x.object_id = i.object_id AND x.index_id = i.index_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
JOIN sys.partitions pt ON i.index_id = pt.index_id AND o.object_id = pt.object_id
LEFT JOIN #CompressionEstimateNone n ON n.SchemaName = s.name AND n.TableName = o.name AND n.IndexID = i.index_id AND n.PartitionNumber = pt.partition_number
LEFT JOIN #CompressionEstimateRow  r ON r.SchemaName = s.name AND r.TableName = o.name AND r.IndexID = i.index_id AND r.PartitionNumber = pt.partition_number
LEFT JOIN #CompressionEstimatePage p ON p.SchemaName = s.name AND p.TableName = o.name AND p.IndexID = i.index_id AND p.PartitionNumber = pt.partition_number
WHERE 
  objectproperty(i.object_id,'IsUserTable') = 1
ORDER BY i.index_id

IF OBJECT_ID('tempdb..#CompressionEstimateNone') IS NOT NULL DROP TABLE #CompressionEstimateNone
IF OBJECT_ID('tempdb..#CompressionEstimateRow') IS NOT NULL DROP TABLE #CompressionEstimateRow
IF OBJECT_ID('tempdb..#CompressionEstimatePage') IS NOT NULL DROP TABLE #CompressionEstimatePage

