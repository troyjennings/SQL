USE [msdb]
GO

/****** Object:  Job [DatabaseRestore - DSC2Prod - Part 2 of 2 - After Midnight]    Script Date: 1/7/2019 10:18:35 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 1/7/2019 10:18:35 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseRestore - DSC2Prod - Part 2 of 2 - After Midnight', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Finish recovery of DSC2Prod database]    Script Date: 1/7/2019 10:18:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Finish recovery of DSC2Prod database', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE @StopDateTime NVARCHAR(14)

SELECT @StopDateTime = CONVERT(NVARCHAR, GETDATE(), 112) + ''000001'';

EXECUTE [master].[dbo].[sp_DatabaseRestore]
	  @Database = N''DSC2Prod'', 
	  @RestoreDatabaseName = N''DSC2Prod_Snapshot'', 
	  @BackupPathFull = N''\\exp1cifs01\tdbadb01_backuptest\Backups\FULL\EXP1TDBADB01FO$TDBA_AO_AG\DSC2Prod\FULL\'', 
	  @BackupPathDiff = N''\\exp1cifs01\tdbadb01_backuptest\Backups\DIFF\EXP1TDBADB01FO$TDBA_AO_AG\DSC2Prod\DIFF\'', 
	  @BackupPathLog = N''\\exp1cifs01\tdbadb01_backuptest\Backups\LOG\EXP1TDBADB01FO$TDBA_AO_AG\DSC2Prod\LOG\'',
	  @MoveFiles = 1, 
	  @MoveDataDrive = N''F:\Data\DSC2PROD_Snap\'', 
	  @MoveLogDrive = N''L:\Logs\DSC2PROD_Snap\'', 
	  @MoveFilestreamDrive = N''F:\Data\DSC2PROD_Snap\'',
    @RunCheckDB = 0, 
	  @RestoreDiff = 0,
	  @ContinueLogs = 1, 
	  @RunRecovery = 1, 
	  @ForceSimpleRecovery = 1,
    @ExistingDBAction = 0,
	  @StopAt = @StopDateTime;

ALTER DATABASE [DSC2Prod_Snapshot] SET QUERY_STORE = OFF;

ALTER AUTHORIZATION ON DATABASE::[DSC2Prod_Snapshot] TO [sa];

ALTER DATABASE [DSC2Prod_Snapshot] SET READ_ONLY WITH NO_WAIT;', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 2 - Disable Job]    Script Date: 1/7/2019 10:18:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 2 - Disable Job', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--Disable job 

EXEC msdb.dbo.sp_update_job 
  @job_name=N''DatabaseRestore - DSC2Prod - Part 2 of 2 - After Midnight'', 
  @enabled=0;
', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily at 12:10am', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181214, 
		@active_end_date=99991231, 
		@active_start_time=1000, 
		@active_end_time=235959, 
		@schedule_uid=NULL
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


