-- At Publisher Server
	-- Creating a PUSH subscription
USE [ContsoSQLInventory];
EXEC sp_addsubscription 
@publication = N'DIMS', 
@subscriber = N'YourPublisherServerName\SQL2016', 
@destination_db = N'ContsoSQLInventory_Ajay', 
@subscription_type = N'Push', 
@article = N'all',
--BEGIN Backup Params
@sync_type = N'initialize with backup',
@backupdevicetype = 'disk',
@backupdevicename = 'G:\MSSQLData\SQL2016_Backup\ContsoSQLInventory\FULL\ContsoSQLInventory_FULL_20190214_025710.bak'
--END Backup Params
GO


-- Create distribution agent
USE [ContsoSQLInventory];
EXEC sp_addpushsubscription_agent 
	@publication = N'DIMS', 
	@subscriber = N'YourPublisherServerName\SQL2016', 
	@subscriber_db = N'ContsoSQLInventory_Ajay', 
	--@job_login = N'SQLSKILLSDEMOs\Administrator', 
	--@job_password = 'Password;1', 
	@subscriber_security_mode = 1, 
	-- Autostart
	@frequency_type = 64, 
	@frequency_interval = 0, 
	@frequency_relative_interval = 0, 
	@frequency_recurrence_factor = 0, 
	@frequency_subday = 0, 
	@frequency_subday_interval = 0, 
	@active_start_time_of_day = 0, 
	@active_end_time_of_day = 235959, 
	@active_start_date = 20120215, 
	@active_end_date = 99991231;
GO

-- Check snapshot agent job
:CONNECT SQL2K12-SVR2
SELECT name
FROM distribution.dbo.MSsnapshot_agents;
GO


-- ** Let's kick off the snapshot agent job now **

-- When we created it there were no subscriptions waiting...
:CONNECT SQL2K12-SVR2
EXEC msdb.dbo.sp_start_job 
'SQL2K12-SVR1-Credit-Pub_Credit-7' -- CHANGE this name
GO

:CONNECT SQL2K12-SVR3

SELECT category_no, category_desc
FROM [CreditReporting].[dbo].[category];
GO

-- Test a row insert
:CONNECT SQL2K12-SVR1 
USE Credit;

INSERT [Credit].[dbo].[category]
(category_desc)
VALUES ('This is a Test Also');
GO

:CONNECT SQL2K12-SVR3

SELECT category_no, category_desc
FROM [CreditReporting].[dbo].[category];
GO
