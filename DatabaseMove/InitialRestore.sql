CREATE PROCEDURE dbo.InitialRestore
AS
BEGIN 

  EXECUTE AS Login = 'sa';

  DECLARE @DBNAME NVARCHAR(100), @Count INT, @Full NVARCHAR(4000), @Log NVARCHAR(4000), @Diff NVARCHAR(4000), @DataDrivePath NVARCHAR(100), @LogDrivePath NVARCHAR(100);

  DECLARE @DBs TABLE(dbname NVARCHAR(100), SourceFullPath NVARCHAR(3000), SourceLogPath NVARCHAR(3000), SourceDiffPath NVARCHAR(3000), DataDrivePath NVARCHAR(100), LogDrivePath NVARCHAR(100));

  INSERT INTO @DBs
  SELECT dbname, SourceFullPath, SourceLogPath, SourceDiffPath, DataDrivePath, LogDrivePath
  FROM dbo.DB_Move
  WHERE MoveStatus = 1;

  SELECT @Count = COUNT(*) FROM @DBs;

  WHILE @Count > 0
  BEGIN

    SELECT TOP 1 
      @DBNAME = dbname,
	    @Full =  SourceFullPath + DBNAME + '\FULL\',
	    @Log = SourceLogPath  + DBNAME + '\LOG\',
	    @Diff = SourceDiffPath  + DBNAME + '\DIFF\',
	    @DataDrivePath = DataDrivePath,
	    @LogDrivePath = LogDrivePath
    FROM @DBs 
    ORDER BY dbname;

    BEGIN TRY

      EXECUTE dbo.sp_DatabaseRestore
	      @Database = @DBNAME, 
	      @BackupPathFull = @Full,
	      @BackupPathLog = @Log,
	      @BackupPathDiff = @Diff,
	      @MoveFiles = 1, 
	      @MoveDataDrive = @DataDrivePath, 
	      @MoveLogDrive = @LogDrivePath, 
	      @RunCheckDB = 0, 
	      @RestoreDiff = 0,
	      @ContinueLogs = 0, 
	      @RunRecovery = 0,
	      @ExistingDBAction = 3;

	    UPDATE dbo.DB_Move SET MoveStatus = 2, LastUpdate = GETDATE() WHERE DBName = @DBName;

	  END TRY
	  BEGIN CATCH
		  INSERT INTO dbo.DB_Errors
		  VALUES
		  (SUSER_SNAME(),
		  ERROR_NUMBER(),
		  ERROR_STATE(),
		  ERROR_SEVERITY(),
		  ERROR_LINE(),
		  ERROR_PROCEDURE(),
		  ERROR_MESSAGE(),
		  GETDATE());
		
	    UPDATE dbo.DB_Move SET MoveStatus = -1, LastUpdate = GETDATE() WHERE DBName = @DBName;

	  END CATCH

	  DELETE FROM @DBs WHERE dbname = @DBNAME;

	  SELECT @Count = COUNT(*) FROM @DBs;
  END
END