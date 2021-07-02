USE master;
GO

DECLARE @DBNAME NVARCHAR(100), @Count INT, @Full NVARCHAR(4000), @Log NVARCHAR(4000);

DECLARE @DBs TABLE(dbname NVARCHAR(100)); --, SourceFullPath NVARCHAR(3000), SourceLogPath NVARCHAR(3000), DataDrivePath NVARCHAR(100), LogDrivePath NVARCHAR(100));

INSERT INTO @DBs 
SELECT value AS dbname FROM string_split
('Bravos,Citadel,CRSDBA,Inbound,IronBank,KingsLanding,Qyburn,Raven,RiverRun,ReportServer,ReportServerTempDB', ',');

INSERT INTO @DBs 
SELECT value AS dbname FROM string_split
('ins2019gelit0255unallocatedc1,ins2019geoth0210hcb,ins2019gllit0118ssgavvisbal,ins2019naadv0302seclending,insprojectm,inssecny9713,insstatestreetgcmodel', ',');

DECLARE @SourceFullPath NVARCHAR(3000) = N'\\lich.champ.caseshare.com\gc-sql\GCSQL0304_SQL1\FullBackup\GCSQL0304$AG_GCSQL0304_01\';
DECLARE @SourceLogPath NVARCHAR(3000) = N'\\lich.champ.caseshare.com\gc-sql\GCSQL0304_SQL1\LogBackup\GCSQL0304$AG_GCSQL0304_01\';
DECLARE @SourceDiffPath NVARCHAR(3000) = NULL;
DECLARE @DataDrivePath NVARCHAR(100) = N'G:\Data\';
DECLARE @LogDrivePath NVARCHAR(100) = N'F:\Logs\';

INSERT INTO [dbo].[DB_Move]
SELECT db.dbname, @SourceFullPath, @SourceLogPath, @SourceDiffPath, @DataDrivePath, @LogDrivePath, 0, GETDATE()
FROM @DBs db
LEFT JOIN [dbo].[DB_Move] dbmove ON dbmove.DBName = db.dbname
WHERE db.dbname IS NULL
ORDER BY db.dbname;

--UPDATE [dbo].[DB_Move] SET MoveStatus = 1

--SELECT * FROM dbo.DB_Move ORDER BY dbname;

/*
DECLARE @SourceFullPath NVARCHAR(3000) = N'\\lich.champ.caseshare.com\gc-sql\GCSQL01_GC1\Full\';
DECLARE @SourceLogPath NVARCHAR(3000) = N'\\lich.champ.caseshare.com\gc-sql\GCSQL01_GC1\Log\';
DECLARE @SourceDiffPath NVARCHAR(3000) = NULL;
DECLARE @DataDrivePath NVARCHAR(100) = N'E:\SQL1\Data\';
DECLARE @LogDrivePath NVARCHAR(100) = N'E:\SQL1\Log\';

INSERT INTO [dbo].[DB_Move]
SELECT db.name, @SourceFullPath, @SourceLogPath, @SourceDiffPath, @DataDrivePath, @LogDrivePath, 0, GETDATE()
FROM sys.databases db
LEFT JOIN [dbo].[DB_Move] dbmove ON dbmove.DBName = db.name
WHERE db.database_id > 4 and dbmove.DBName IS NULL
ORDER BY db.name;
*/