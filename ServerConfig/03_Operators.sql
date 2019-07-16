USE [msdb]
GO

/****** Object:  Operator [Backup Restore Group]    Script Date: 3/20/2019 9:58:21 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'Backup Restore Group', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'DBAS1@nextgearcapital.com; ngc.InfoServices1@coxautoinc.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [DBA + PagerDuty]    Script Date: 3/20/2019 9:58:21 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'DBA + PagerDuty', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'dba-alerts1@nextgear.pagerduty.com;dbas@nextgearcapital.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [DBA Operators]    Script Date: 3/20/2019 9:58:21 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'DBA Operators', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'DBAS1@nextgearcapital.com; ngc.InfoServices1@coxautoinc.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [DBAPagerDuty]    Script Date: 3/20/2019 9:58:21 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'DBAPagerDuty', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'dba-alerts1@nextgear.pagerduty.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [DSC BI Support]    Script Date: 3/20/2019 9:58:21 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'DSC BI Support', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'tim.schubach1@nextgearcapital.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [Information Services Support]    Script Date: 3/20/2019 9:58:21 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'Information Services Support', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'ngc.InfoServices1@coxautoinc.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [NextGear - Warehouse Reporting]    Script Date: 3/20/2019 9:58:21 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'NextGear - Warehouse Reporting', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'WarehouseReporting1@nextgearcapital.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [No Page DBA Operator]    Script Date: 3/20/2019 9:58:21 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'No Page DBA Operator', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'DBAS1@nextgearcapital.com', 
		@category_name=N'[Uncategorized]'
GO


