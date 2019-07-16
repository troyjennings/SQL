

DECLARE
  @IndexTrackingID INT,
  @DatabaseName NVARCHAR(255),
  @FullTableName NVARCHAR(512),   -- schema.table
  @FullIndexName NVARCHAR(1024),  -- database.schema.table.index
  @Index_ID INT,
  @FillFactorTarget INT,
  @FillFactorThreshold INT,
  @WaitMaxDuration INT,
  @avg_Fragmentation_in_Percent DECIMAL(18,2),
	@Page_Count INT,
	@Avg_Page_Space_Used_in_Percent DECIMAL(18,2),
	@Record_Count INT,
  @GetDate DATETIME,
  @Count INT

-- Set status - mark indexes for info collection and reset rebuild if previously interrupted
UPDATE DBA_Utilities.dbo.IndexTracking SET InfoStatus = 1, RebuildStatus = 0 WHERE IsEnabled = 1 AND DatabaseName = DB_NAME()

-- Gather Index info
SELECT @Count = COUNT(*) FROM DBA_Utilities.dbo.IndexTracking WHERE IsEnabled = 1 AND InfoStatus = 1 AND DatabaseName = DB_NAME()

WHILE @Count > 0
BEGIN
  SELECT TOP 1
    @IndexTrackingID = it.IndexTrackingID,
    @DatabaseName = it.DatabaseName,
    @FullTableName = '[' + it.SchemaName + '].[' + it.TableName + ']',   
    @Index_ID = it.Index_ID,
    @FillFactorThreshold = FillFactorThreshold
  FROM DBA_Utilities.dbo.IndexTracking it
  WHERE it.IsEnabled = 1 AND it.InfoStatus = 1 AND it.DatabaseName = DB_NAME()
  ORDER BY it.IndexTrackingID

  SELECT @GetDate = GETDATE(), @avg_fragmentation_in_percent = s.avg_fragmentation_in_percent, @page_count = s.page_count, @avg_page_space_used_in_percent = s.avg_page_space_used_in_percent, @record_count = s.record_count
  FROM sys.dm_db_index_physical_stats(DB_ID(@DatabaseName), OBJECT_ID(@FullTableName), @Index_ID, NULL, 'SAMPLED') s
  WHERE s.alloc_unit_type_desc = 'IN_ROW_DATA'

  INSERT INTO DBA_Utilities.dbo.IndexTrackingInfo
           ([IndexTrackingID]
           ,[InfoDateTime]
           ,[Avg_Fragmentation_in_Percent]
           ,[Page_Count]
           ,[Avg_Page_Space_Used_in_Percent]
           ,[Record_Count])
  VALUES (@IndexTrackingID
           ,@GetDate
           ,@Avg_Fragmentation_in_Percent
           ,@Page_Count
           ,@Avg_Page_Space_Used_in_Percent
           ,@Record_Count)

  UPDATE DBA_Utilities.dbo.IndexTracking 
  SET InfoStatus = 0,
    RebuildStatus = CASE WHEN @Avg_Page_Space_Used_in_Percent >= @FillFactorThreshold THEN 1 ELSE 0 END 
  WHERE IndexTrackingID = @IndexTrackingID
 
  SELECT @Count = COUNT(*) FROM DBA_Utilities.dbo.IndexTracking WHERE IsEnabled = 1 AND InfoStatus = 1 AND DatabaseName = DB_NAME()
END

--Begin Index Rebuild
SELECT @Count = COUNT(*) FROM DBA_Utilities.dbo.IndexTracking WHERE IsEnabled = 1 AND RebuildStatus = 1 AND DatabaseName = DB_NAME()

WHILE @Count > 0
BEGIN
  SELECT TOP 1
    @IndexTrackingID = it.IndexTrackingID,
    @DatabaseName = it.DatabaseName,
    @FullTableName = it.SchemaName + '.' + it.TableName, 
    @FullIndexName = it.DatabaseName + '.' +it.SchemaName + '.' + it.TableName + '.' + it.IndexName,   
    @Index_ID = it.Index_ID,
    @FillFactorTarget = it.FillFactorTarget,
    @WaitMaxDuration = it.WaitMaxDuration
  FROM DBA_Utilities.dbo.IndexTracking it
  WHERE it.IsEnabled = 1 AND it.RebuildStatus = 1 AND it.DatabaseName = DB_NAME()
  ORDER BY it.IndexTrackingID

EXECUTE DBA_Utilities.dbo.IndexOptimize
@Databases = @DatabaseName,
@FragmentationLow = 'INDEX_REBUILD_ONLINE',
@FragmentationMedium = 'INDEX_REBUILD_ONLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE',
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 30,
@Indexes = @FullIndexName,
@FillFactor = @FillFactorTarget,
@WaitAtLowPriorityMaxDuration = @WaitMaxDuration,
@WaitAtLowPriorityAbortAfterWait = 'SELF',
@SortInTempDB = 'Y'

  SELECT @GetDate = GETDATE(), @avg_fragmentation_in_percent = s.avg_fragmentation_in_percent, @page_count = s.page_count, @avg_page_space_used_in_percent = s.avg_page_space_used_in_percent, @record_count = s.record_count
  FROM sys.dm_db_index_physical_stats(DB_ID(@DatabaseName), OBJECT_ID(@FullTableName), @Index_ID, NULL, 'SAMPLED') s
  WHERE s.alloc_unit_type_desc = 'IN_ROW_DATA'

  INSERT INTO DBA_Utilities.dbo.IndexTrackingInfo
           ([IndexTrackingID]
           ,[InfoDateTime]
           ,[Avg_Fragmentation_in_Percent]
           ,[Page_Count]
           ,[Avg_Page_Space_Used_in_Percent]
           ,[Record_Count])
  VALUES (@IndexTrackingID
           ,@GetDate
           ,@Avg_Fragmentation_in_Percent
           ,@Page_Count
           ,@Avg_Page_Space_Used_in_Percent
           ,@Record_Count)

  UPDATE DBA_Utilities.dbo.IndexTracking 
  SET RebuildStatus = 0
  WHERE IndexTrackingID = @IndexTrackingID
 
  SELECT @Count = COUNT(*) FROM DBA_Utilities.dbo.IndexTracking WHERE IsEnabled = 1 AND RebuildStatus = 1 AND DatabaseName = DB_NAME()
END
