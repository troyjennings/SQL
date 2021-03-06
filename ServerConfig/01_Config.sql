
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
---- Memory 352 GB
--EXEC sys.sp_configure N'max server memory (MB)', N'360448'
--GO

---- Memory 64 GB
--EXEC sys.sp_configure N'max server memory (MB)', N'65536'
--GO

---- Memory 8 GB
--EXEC sys.sp_configure N'max server memory (MB)', N'8192'
--GO

DECLARE @MemoryPct DECIMAL(8,2) = 0.90, @MemoryCalc INT = 0, @MemoryMin INT = 1024, @MemorySet NVARCHAR(63) = N''
 
SELECT @MemoryCalc = FLOOR(total_physical_memory_kb * @MemoryPct/1024/1024/4) * 4 * 1024 FROM sys.dm_os_sys_memory

SELECT @MemorySet = CAST(CASE WHEN @MemoryCalc > @MemoryMin THEN @MemoryCalc ELSE @MemoryMin END AS NVARCHAR(63))

EXEC sys.sp_configure N'max server memory (MB)', @MemorySet
GO 

EXEC sys.sp_configure N'cost threshold for parallelism', N'500'
GO
EXEC sys.sp_configure N'max degree of parallelism', N'4'
GO
EXEC sys.sp_configure N'backup compression default', N'1'
GO
EXEC sys.sp_configure N'optimize for ad hoc workloads', N'1'
GO
EXEC sys.sp_configure N'clr enabled', N'1'
GO
EXEC sys.sp_configure N'remote admin connections', N'1'
GO
EXEC sys.sp_configure N'Database Mail XPs', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO


