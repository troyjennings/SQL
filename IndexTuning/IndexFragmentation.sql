
SELECT 
 GETDATE() AS collection_datetime
 ,s.[name] +'.'+t.[name]  AS table_name
 ,i.NAME AS index_name
 ,i.index_id
 ,i.fill_factor
 ,ips.index_type_desc
 ,ROUND(ips.avg_fragmentation_in_percent,2) AS avg_fragmentation_in_percent
 ,ROUND(ips.avg_page_space_used_in_percent,2) AS avg_page_space_used_in_percent
 ,ips.page_count
 ,ips.record_count 
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
INNER JOIN sys.tables t on t.[object_id] = ips.[object_id]
INNER JOIN sys.schemas s on t.[schema_id] = s.[schema_id]
INNER JOIN sys.indexes i ON (ips.object_id = i.object_id) AND (ips.index_id = i.index_id)
ORDER BY avg_fragmentation_in_percent DESC