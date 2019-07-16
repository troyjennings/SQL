
DECLARE @StopDateTime NVARCHAR(14)

SELECT @StopDateTime = CONVERT(NVARCHAR(14), GETDATE(), 112) + '000900';

EXECUTE [master].[dbo].[sp_DatabaseRestore]
	  @Database = N'DSC2Prod', 
	  @RestoreDatabaseName = N'DSCProd_WarehouseSnapshot', 
	  @BackupPathFull = N'\\EXP1CIFS01\Discover_Backups\Backups\FULL\EXP1PNGNDB01$NGN_AO_AG\DSC2Prod\FULL\', 
	  @BackupPathLog = N'\\EXP1CIFS01\Discover_Backups\Backups\LOG\EXP1PNGNDB01$NGN_AO_AG\DSC2Prod\LOG\',
	  @MoveFiles = 1, 
	  @MoveDataDrive = N'N:\Data\', 
	  @MoveLogDrive = N'O:\Logs\', 
	  @MoveFilestreamDrive = N'N:\Data\',
    @RunCheckDB = 0, 
	  @ContinueLogs = 0, 
	  @RunRecovery = 1, 
	  @ForceSimpleRecovery = 1,
    @ExistingDBAction = 3,
	  @StopAt = @StopDateTime;

ALTER DATABASE [DSCProd_WarehouseSnapshot] SET QUERY_STORE = OFF;

ALTER AUTHORIZATION ON DATABASE::[DSCProd_WarehouseSnapshot] TO [sa];

ALTER DATABASE [DSCProd_WarehouseSnapshot] SET READ_ONLY WITH NO_WAIT;
