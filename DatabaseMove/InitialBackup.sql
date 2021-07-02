CREATE PROCEDURE dbo.InitialBackup
AS
BEGIN 

  EXECUTE AS Login = 'sa';

  DECLARE @DBNAME NVARCHAR(100), @Count INT, @Full NVARCHAR(4000), @Log NVARCHAR(4000), @Diff NVARCHAR(4000), @DataDrivePath NVARCHAR(100), @LogDrivePath NVARCHAR(100);

  DECLARE @DBs TABLE(dbname NVARCHAR(100), SourceFullPath NVARCHAR(3000), SourceLogPath NVARCHAR(3000), SourceDiffPath NVARCHAR(3000), DataDrivePath NVARCHAR(100), LogDrivePath NVARCHAR(100));

  DECLARE @SQL NVARCHAR(4000);

  INSERT INTO @DBs
  SELECT dbname, SourceFullPath, SourceLogPath, SourceDiffPath, DataDrivePath, LogDrivePath
  FROM dbo.DB_Move
  WHERE MoveStatus = 5;

  SELECT @Count = COUNT(*) FROM @DBs;

  WHILE @Count > 0
  BEGIN

    SELECT TOP 1 
      @DBNAME = dbname,
	    @Full =  SourceFullPath, -- + DBNAME + '\FULL\',
	    @Log = SourceLogPath, --  + DBNAME + '\LOG\',
	    @Diff = SourceDiffPath, --  + DBNAME + '\DIFF\',
	    @DataDrivePath = DataDrivePath,
	    @LogDrivePath = LogDrivePath
    FROM @DBs 
    ORDER BY dbname;

    BEGIN TRY

	

		IF EXISTS (SELECT * FROM sys.databases d WHERE d.name = @DBNAME AND d.recovery_model_desc = 'SIMPLE') 
		BEGIN
		  SELECT @SQL = 'ALTER DATABASE [' + @DBNAME + '] SET RECOVERY FULL WITH NO_WAIT';
		  EXECUTE sp_executesql @SQL;
		END 

		 EXECUTE [dbo].[DatabaseBackup]
			@Databases = @DBNAME,
			@Directory = @Full,
			@BackupType = 'FULL',
			@Verify = 'N',
			@CleanupTime = 72,
			@Compress = 'Y',
			@BlockSize = 65536,
			@BufferCount = 34,
			@MaxTransferSize = 4194304,
			@NumberOfFiles = 8,
			@CheckSum = 'Y',
			@LogToTable = 'Y';

	    UPDATE dbo.DB_Move SET MoveStatus = 6, LastUpdate = GETDATE() WHERE DBName = @DBName;

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