DECLARE @NumTempDBFiles INT = NULL;

-- Find number of TempDB data files, this excludes tempdb log file
SET @NumTempDBFiles = (select count(name) from sys.master_files where name like 'tempdev%' or name like 'temp%' and name != 'templog')


IF @NumTempDBFiles >= 4 
BEGIN
  ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'tempdev', SIZE = 4190208KB , FILEGROWTH = 4190208KB );

  ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'temp2', SIZE = 4190208KB , FILEGROWTH = 4190208KB );

  ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'temp3', SIZE = 4190208KB , FILEGROWTH = 4190208KB );

  ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'temp4', SIZE = 4190208KB , FILEGROWTH = 4190208KB );

END;
IF @NumTempDBFiles = 8 
BEGIN
  ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'temp5', SIZE = 4190208KB , FILEGROWTH = 4190208KB );

  ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'temp6', SIZE = 4190208KB , FILEGROWTH = 4190208KB );

  ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'temp7', SIZE = 4190208KB , FILEGROWTH = 4190208KB );

  ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'temp8', SIZE = 4190208KB , FILEGROWTH = 4190208KB );
END

ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'templog', SIZE = 4190208KB );

--ADD FILE
--USE [master]
--GO
--ALTER DATABASE [tempdb] ADD FILE ( NAME = N'temp9', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_9.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
--GO

--MOVE TEMPDB  
-- From Brent Ozar https://www.brentozar.com/archive/2017/11/move-tempdb-another-drive-folder/

--SELECT 'ALTER DATABASE tempdb MODIFY FILE (NAME = [' + f.name + '],'
--	+ ' FILENAME = ''Z:\MSSQL\DATA\' + f.name
--	+ CASE WHEN f.type = 1 THEN '.ldf' ELSE '.mdf' END
--	+ ''');'
--FROM sys.master_files f
--WHERE f.database_id = DB_ID(N'tempdb');