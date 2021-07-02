
DECLARE @backpath varchar(2000), @database varchar(255);
DECLARE @path VARCHAR(2000) = '\\lich.champ.caseshare.com\gc-sql\GCSQL0506_SQL2\FullBackup\GCSQL05$SQL2\';



SET @database = 'Bravos';
SET @backpath = @Path + @database + '\FULL'; 
EXEC dbo.sp_DatabaseRestore @Database = @database, @BackupPathFull = @backpath, @ExistingDBAction = 3,@RunRecovery = 1;

SET @database = 'Citadel';
SET @backpath = @Path + @database + '\FULL'; 
EXEC dbo.sp_DatabaseRestore @Database = @database, @BackupPathFull = @backpath, @ExistingDBAction = 3,@RunRecovery = 1;

SET @database = 'CRSDBA';
SET @backpath = @Path + @database + '\FULL'; 
EXEC dbo.sp_DatabaseRestore @Database = @database, @BackupPathFull = @backpath, @ExistingDBAction = 3,@RunRecovery = 1;

SET @database = 'Inbound';
SET @backpath = @Path + @database + '\FULL'; 
EXEC dbo.sp_DatabaseRestore @Database = @database, @BackupPathFull = @backpath, @ExistingDBAction = 3,@RunRecovery = 1;

SET @database = 'IronBank';
SET @backpath = @Path + @database + '\FULL'; 
EXEC dbo.sp_DatabaseRestore @Database = @database, @BackupPathFull = @backpath, @ExistingDBAction = 3,@RunRecovery = 1;

SET @database = 'KingsLanding';
SET @backpath = @Path + @database + '\FULL'; 
EXEC dbo.sp_DatabaseRestore @Database = @database, @BackupPathFull = @backpath, @ExistingDBAction = 3,@RunRecovery = 1;

SET @database = 'Qyburn';
SET @backpath = @Path + @database + '\FULL'; 
EXEC dbo.sp_DatabaseRestore @Database = @database, @BackupPathFull = @backpath, @ExistingDBAction = 3,@RunRecovery = 1;

SET @database = 'Raven';
SET @backpath = @Path + @database + '\FULL'; 
EXEC dbo.sp_DatabaseRestore @Database = @database, @BackupPathFull = @backpath, @ExistingDBAction = 3,@RunRecovery = 1;

SET @database = 'RiverRun';
SET @backpath = @Path + @database + '\FULL'; 
EXEC dbo.sp_DatabaseRestore @Database = @database, @BackupPathFull = @backpath, @ExistingDBAction = 3,@RunRecovery = 1;

USE [master]
GO

ALTER DATABASE Bravos SET  READ_WRITE WITH NO_WAIT
GO
ALTER AUTHORIZATION ON DATABASE::Bravos TO [sa]
GO

ALTER DATABASE Citadel SET  READ_WRITE WITH NO_WAIT
GO
ALTER AUTHORIZATION ON DATABASE::Citadel TO [sa]
GO

ALTER DATABASE CRSDBA SET  READ_WRITE WITH NO_WAIT
GO
ALTER AUTHORIZATION ON DATABASE::CRSDBA TO [sa]
GO

ALTER DATABASE Inbound SET  READ_WRITE WITH NO_WAIT
GO
ALTER AUTHORIZATION ON DATABASE::Inbound TO [sa]
GO

ALTER DATABASE IronBank SET  READ_WRITE WITH NO_WAIT
GO
ALTER AUTHORIZATION ON DATABASE::IronBank TO [sa]
GO

ALTER DATABASE KingsLanding SET  READ_WRITE WITH NO_WAIT
GO
ALTER AUTHORIZATION ON DATABASE::KingsLanding TO [sa]
GO

ALTER DATABASE Qyburn SET  READ_WRITE WITH NO_WAIT
GO
ALTER AUTHORIZATION ON DATABASE::Qyburn TO [sa]
GO

ALTER DATABASE Raven SET  READ_WRITE WITH NO_WAIT
GO
ALTER AUTHORIZATION ON DATABASE::Raven TO [sa]
GO

ALTER DATABASE RiverRun SET  READ_WRITE WITH NO_WAIT
GO
ALTER AUTHORIZATION ON DATABASE::RiverRun TO [sa]
GO
