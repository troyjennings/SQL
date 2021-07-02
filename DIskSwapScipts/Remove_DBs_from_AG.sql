DECLARE @DBNAME NVARCHAR(100), @Count INT;

DECLARE @DBs TABLE(dbname NVARCHAR(100));

DECLARE @SQL NVARCHAR(4000);

INSERT INTO @DBs 
SELECT value AS dbname FROM string_split
('Bravos,Citadel,Inbound,IronBank,KingsLanding,Qyburn,Raven,RiverRun', ',');

INSERT INTO @DBs 
SELECT value AS dbname FROM string_split
('ins2019gelit0255unallocatedc1,ins2019geoth0210hcb,ins2019gllit0118ssgavvisbal,ins2019naadv0302seclending,insprojectm,inssecny9713,insstatestreetgcmodel', ',');


SELECT @Count = COUNT(*) FROM @DBs;

WHILE @Count > 0
BEGIN

  SELECT TOP 1 @DBNAME = dbname FROM @DBs ORDER BY dbname;

  SELECT @SQL = 'ALTER AVAILABILITY GROUP [AG_GCSQL0506_01] REMOVE DATABASE ' + @DBNAME +';';

    EXEC sp_executesql @SQL;

	DELETE FROM @DBs WHERE dbname = @DBNAME;

	SELECT @Count = COUNT(*) FROM @DBs;
END