USE [msdb]
GO

/****** Object:  Alert [Error Number 3420 - Invalid Object]    Script Date: 3/20/2019 10:00:02 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Error Number 3420 - Invalid Object', 
		@message_id=3420, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Error Number 823 - Windows Read or Write Failure]    Script Date: 3/20/2019 10:00:02 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Error Number 823 - Windows Read or Write Failure', 
		@message_id=823, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Error Number 824 - Page Error]    Script Date: 3/20/2019 10:00:02 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Error Number 824 - Page Error', 
		@message_id=824, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Error Number 825 - Read Operation Retried]    Script Date: 3/20/2019 10:00:02 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Error Number 825 - Read Operation Retried', 
		@message_id=825, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Fatal error]    Script Date: 3/20/2019 10:00:02 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Fatal error', 
		@message_id=0, 
		@severity=25, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Fatal error in current process]    Script Date: 3/20/2019 10:00:02 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Fatal error in current process', 
		@message_id=0, 
		@severity=20, 
		@enabled=0, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Fatal error in database processes]    Script Date: 3/20/2019 10:00:02 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Fatal error in database processes', 
		@message_id=0, 
		@severity=21, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Fatal error in resource]    Script Date: 3/20/2019 10:00:02 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Fatal error in resource', 
		@message_id=0, 
		@severity=19, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Fatal error: database integrity suspect]    Script Date: 3/20/2019 10:00:02 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Fatal error: database integrity suspect', 
		@message_id=0, 
		@severity=23, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Fatal error: hardware error]    Script Date: 3/20/2019 10:00:02 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Fatal error: hardware error', 
		@message_id=0, 
		@severity=24, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Fatal error: table integrity suspect]    Script Date: 3/20/2019 10:00:02 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Fatal error: table integrity suspect', 
		@message_id=0, 
		@severity=22, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Insufficient Resources]    Script Date: 3/20/2019 10:00:02 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Insufficient Resources', 
		@message_id=0, 
		@severity=17, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Miscellaneous user error]    Script Date: 3/20/2019 10:00:02 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Miscellaneous user error', 
		@message_id=0, 
		@severity=16, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Non-Fatal Internal Error]    Script Date: 3/20/2019 10:00:02 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Non-Fatal Internal Error', 
		@message_id=0, 
		@severity=18, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


