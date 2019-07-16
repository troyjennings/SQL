--==========================================================
-- Enable Database Mail
--==========================================================
sp_CONFIGURE 'show advanced', 1 RECONFIGURE WITH OVERRIDE;
GO
sp_CONFIGURE 'Database Mail XPs', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO 

--================================================================
-- DATABASE MAIL CONFIGURATION
--================================================================
DECLARE 
  @Set_account_name VARCHAR(255) = 'default',
  @Set_profile_name VARCHAR(255) = 'default',
  @Set_description VARCHAR(255) = '',
  @Set_email_address VARCHAR(255) = '',
  @Set_replyto_address VARCHAR(255) = 'noreply@nexxtgearcapital.com',
  @Set_display_name VARCHAR(255) = '',
  @Set_mailserver_name VARCHAR(255) = 'relay.nextgearcapital.com',
  @Set_port INT = 25;

  SELECT @Set_email_address = @@SERVERNAME + '@nextgearcapital.com', @Set_display_name = 'UAT SSIS - ' + @@SERVERNAME

--==========================================================
-- Create a Database Mail account
--==========================================================
EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name = @Set_account_name,
    @description = @Set_description,
    @email_address = @Set_email_address,
    @replyto_address = @Set_replyto_address,
    @display_name = @Set_display_name,
    @mailserver_name = @Set_mailserver_name,
	  @port = @Set_port;

--==========================================================
-- Create a Database Mail Profile
--==========================================================
DECLARE @profile_id INT, @profile_description sysname;
SELECT @profile_id = COALESCE(MAX(profile_id),1) FROM msdb.dbo.sysmail_profile;
SELECT @profile_description = 'Database Mail Profile for ' + @@servername ;

EXECUTE msdb.dbo.sysmail_add_profile_sp
    @profile_name = @Set_profile_name,
    @description = @profile_description;

-- Add the account to the profile
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @Set_profile_name,
    @account_name = @Set_account_name,
    @sequence_number = @profile_id;

-- Grant access to the profile to the DBMailUsers role
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = @Set_profile_name,
    @principal_id = 0,
    @is_default = 1 ;

--================================================================
-- SQL Agent Properties Configuration
--================================================================

EXECUTE msdb.dbo.sp_set_sqlagent_properties 
	@databasemail_profile = @Set_profile_name
	, @use_databasemail=1
  , @email_save_in_sent_folder = 1
  , @jobhistory_max_rows=10000
  , @jobhistory_max_rows_per_job=1000;
GO

--==========================================================
-- Review Outcomes
--==========================================================
SELECT * FROM msdb.dbo.sysmail_profile;
SELECT * FROM msdb.dbo.sysmail_account;
GO


----==========================================================
---- Test Database Mail
----==========================================================
--DECLARE @sub VARCHAR(100)
--DECLARE @body_text NVARCHAR(MAX)
--SELECT @sub = 'Test from New SQL install on ' + @@servername
--SELECT @body_text = N'This is a test of Database Mail.' + CHAR(13) + CHAR(13) + 'SQL Server Version Info: ' + CAST(@@version AS VARCHAR(500))

--EXEC msdb.dbo.[sp_send_dbmail] 
--    @profile_name = ''
--  , @recipients = ''
--  , @subject = @sub
--  , @body = @body_text