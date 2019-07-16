DECLARE @GetDate DATETIME, @NextRun DATETIME 
SELECT @GetDate = GETDATE()
    ,@NextRun = msdb.dbo.agent_datetime(js.next_run_date,js.next_run_time)
From dbo.sysjobs as jb
Inner Join dbo.sysjobschedules as js on js.job_id = jb.job_id
WHERE jb.name = 'DBA - DatabaseRestore - DSC2Prod - Part 2 of 2 - After Midnight'

SELECT @GetDate, @NextRun