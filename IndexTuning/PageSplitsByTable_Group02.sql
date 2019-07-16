
IF OBJECT_ID('tempdb..#TableName') IS NOT NULL DROP TABLE #TableName
CREATE TABLE #TableName (FullName NVARCHAR(255))

INSERT INTO #TableName
SELECT value
FROM
STRING_SPLIT (N'dbo.curtailment_amortization_histories,dbo.eligibility_integration_records,dbo.log_messages,dbo.financial_transactions,dbo.auction_access_messages,dbo.businesses_audits,dbo.curtailments,arc.dealer_queue_audit,dbo.financial_record_caches,dbo.financial_record_subledgers,dbo.financial_transaction_caches,dbo.floorplan_auto_approval_logs,dbo.floorplan_caches,dbo.floorplan_comments,dbo.floorplans_audits,dbo.partner_activity_logs,dbo.title_action_histories,dbo.unit_inspections',',')

SELECT
sc.name AS SchemaName,
t.NAME AS TableName,
sI.NAME AS IndexName,
sI.INDEX_ID,
sI.type_desc,
sI.fill_factor AS Fill_Factor,
ISNULL(IOS.LEAF_ALLOCATION_COUNT, 0) AS InsertSplit,
ISNULL(IOS.NONLEAF_ALLOCATION_COUNT, 0) AS UpdateSplit,
partition_sums.TotalPages,
partition_sums.TotalRows,
partition_sums.reserved_in_row_MB AS IndexSize_MB,
GETDATE() AS CollectionDateTime
FROM sys.indexes AS si
JOIN sys.tables AS t ON si.object_id=t.object_id  
JOIN sys.schemas AS sc ON t.schema_id=sc.schema_id 
INNER JOIN #TableName tn on tn.FullName = sc.name + '.' + t.name
LEFT JOIN SYS.DM_DB_INDEX_OPERATIONAL_STATS(DB_ID(),NULL,NULL,NULL) IOS ON IOS.OBJECT_ID=t.OBJECT_ID AND IOS.INDEX_ID=si.INDEX_ID
/* Partitions */ OUTER APPLY ( 
    SELECT 
        COUNT(*) AS partition_count,
        CAST(SUM(ps.in_row_reserved_page_count)*8./1024. AS NUMERIC(32,1)) AS reserved_in_row_MB,
        CAST(SUM(ps.lob_reserved_page_count)*8./1024. AS NUMERIC(32,1)) AS reserved_LOB_MB,
        SUM(ps.in_row_reserved_page_count) AS TotalPages,
        SUM(ps.row_count) AS TotalRows
    FROM sys.partitions AS p
    JOIN sys.dm_db_partition_stats AS ps ON
        p.partition_id=ps.partition_id
    WHERE p.object_id = si.object_id
        and p.index_id=si.index_id
    ) AS partition_sums
WHERE t.TYPE_DESC='USER_TABLE'

ORDER BY sc.name, t.name, IOS.index_id