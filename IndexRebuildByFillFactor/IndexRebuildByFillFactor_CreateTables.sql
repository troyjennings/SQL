USE DBA_Utilities
GO

CREATE TABLE dbo.IndexTracking (
  IndexTrackingID INT NOT NULL,
  DatabaseName NVARCHAR(255),
  TableName NVARCHAR(255),
  SchemaName NVARCHAR(255),
  IndexName NVARCHAR(255), 
  Index_ID INT,
  FillFactorTarget INT,
  FillFactorThreshold INT,
  WaitMaxDuration INT,
  IsEnabled BIT,
  InfoStatus BIT,
  RebuildStatus BIT,
  CONSTRAINT PK_IndexTracking_IndexTrackingID PRIMARY KEY CLUSTERED (IndexTrackingID)
)

CREATE TABLE dbo.IndexTrackingInfo (
  IndexTrackingID INT NOT NULL,
  InfoDateTime DATETIME NOT NULL,
	Avg_Fragmentation_in_Percent DECIMAL(18,2),
	Page_Count INT,
	Avg_Page_Space_Used_in_Percent DECIMAL(18,2),
	Record_Count INT,
  CONSTRAINT PK_IndexTrackingInfo_IndexTrackingID_InfoDateTime PRIMARY KEY CLUSTERED (IndexTrackingID, InfoDateTime)
)