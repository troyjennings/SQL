USE [msdb]
GO

/****** Object:  Job [DBA - sp_WhoIsActive]    Script Date: 4/2/2019 10:15:57 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 4/2/2019 10:15:57 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - sp_WhoIsActive', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Gather "Trace" information for troubleshooting', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [check_create Table]    Script Date: 4/2/2019 10:15:57 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'check_create Table', 
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
IF (SELECT sys.fn_hadr_is_primary_replica (''dsc2prod'')) = 0
BEGIN
	RETURN 
END

ELSE 

/* script will create script to create destination table in DBA_Utilities database for storing whois information */

DECLARE @destination_table VARCHAR(4000) ;
SET @destination_table = ''WhoIsActive_'' + CONVERT(VARCHAR, GETDATE(), 112) ;

IF NOT EXISTS (Select * from information_schema.tables where table_name = @destination_table)
 BEGIN


 DECLARE @schema VARCHAR(4000) 
 /*EXEC sp_WhoIsActive @get_full_inner_text = 1,
                    @get_plans = 2,
                    @get_outer_command = 1,
                    @get_transaction_info = 1,
                    @get_task_info = 2,
                    @get_locks = 1,
                    @get_additional_info = 1,
                    @find_block_leaders = 1,
                    @return_schema=1
                    @schema = @schema OUTPUT ;
*/

EXEC sp_WhoIsActive @get_full_inner_text = 1,
                    @get_plans = 2,
                    @get_outer_command = 1,
                    @get_transaction_info = 1,
                    @get_task_info = 2,
                    @get_locks = 1,
                    @get_additional_info = 1,
                    @find_block_leaders = 1,
                    @return_schema=1,
                    @schema = @schema OUTPUT 

 SET @schema = REPLACE(@schema, ''<table_name>'', @destination_table) 
 SET @schema = ''USE [DBA_Utilities]; '' + @schema

PRINT @schema
EXEC(@schema) 

END', 
		@database_name=N'DBA_Utilities', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [gather information]    Script Date: 4/2/2019 10:15:57 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'gather information', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
IF (SELECT sys.fn_hadr_is_primary_replica (''dsc2prod'')) = 0
BEGIN
	RETURN 
END

ELSE 

USE [DBA_Utilities];
GO

DECLARE @destination_table VARCHAR(4000),
        @msg NVARCHAR(1000);
SET @destination_table = ''WhoIsActive_'' + CONVERT(VARCHAR, GETDATE(), 112);
DECLARE @numberOfRuns INT;
SET @numberOfRuns = 1;
WHILE @numberOfRuns > 0
BEGIN;


    EXEC sp_WhoIsActive @get_full_inner_text = 1,
                        @get_plans = 2,
                        @get_outer_command = 1,
                        @get_transaction_info = 1,
                        @get_task_info = 2,
                        @get_locks = 1,
                        @get_additional_info = 1,
                        @find_block_leaders = 1,
                        @destination_table = @destination_table;

    SET @numberOfRuns = @numberOfRuns - 1;

    IF @numberOfRuns > 0
    BEGIN
        SET @msg = CONVERT(CHAR(19), GETDATE(), 121) + '': '' + ''Logged info. Waiting...'';
        RAISERROR(@msg, 0, 0) WITH NOWAIT;
    --WAITFOR DELAY ''00:00:05''
    END;
    ELSE
    BEGIN
        SET @msg = CONVERT(CHAR(19), GETDATE(), 121) + '': '' + ''Done.'';
        RAISERROR(@msg, 0, 0) WITH NOWAIT;
    END;
END;
GO', 
		@database_name=N'DBA_Utilities', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'continual', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170823, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=NULL --N'f9c5c666-b35e-4f0d-9b5c-0b2326ddc916'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

USE [msdb]
GO

/****** Object:  Job [DBA - sp_WhoIsActive_Cleanup]    Script Date: 4/2/2019 10:16:03 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 4/2/2019 10:16:03 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - sp_WhoIsActive_Cleanup', 
		@enabled=0, 
		@notify_level_eventlog=3, 
		@notify_level_email=1, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBAPagerDuty', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Cleanup]    Script Date: 4/2/2019 10:16:03 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Cleanup', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/* This will remove all tables older than X days  */
USE [DBA_Utilities];
GO

CREATE TABLE #whoistble
(
    Name NVARCHAR(250)
);

INSERT INTO #whoistble
    (
        Name
    )
SELECT [name]
FROM sys.tables
WHERE name LIKE ''WhoIsActive%''
      AND create_date < (GETDATE () - 3); /* the 14 here denotes how many days to keep */

DECLARE @sql NVARCHAR(MAX) = N'''';
DECLARE @cntALL INT;
DECLARE @cnt INT;

SELECT @cntALL = COUNT (*)
FROM #whoistble;


SELECT @sql += ''DROP TABLE [dbo].'' + ''['' + Name + ''];'' + CHAR (13)
FROM #whoistble;
--PRINT @sql;             /* turn on to see out put but turn off the sp_executesql on the line below first */
EXEC sp_executesql @sql;

DROP TABLE #whoistble;', 
		@database_name=N'DBA_Utilities', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily Run Cleanup', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180320, 
		@active_end_date=99991231, 
		@active_start_time=140000, 
		@active_end_time=235959, 
		@schedule_uid=NULL --N'ba2b2118-239a-4ab4-bd3c-3811c8edaff4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
