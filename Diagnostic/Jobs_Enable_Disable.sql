--DECLARE @EnableState BIT = 0;

select
'EXEC msdb.dbo.sp_update_job @job_Name=N''' + name + ''', @enabled=@EnableState;'
    from msdb.dbo.sysjobs
where enabled = 1
order by name