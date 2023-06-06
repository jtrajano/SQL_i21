
--EXEC uspAPVendorToIpayablesJob  'D:\SQL Backup'

CREATE PROCEDURE uspAPVendorToIPayablesJob
@folderPath NVARCHAR(MAX)

AS
BEGIN
DECLARE @_JobID UNIQUEIDENTIFIER

SELECT @_JobID = job_id   
FROM  msdb.dbo.sysjobs  
WHERE (name = N'Vendor to IPayables')   
IF (@_JobID IS NOT NULL)  
/****** Object:  Job [Vendor to IPayables]    Script Date: 4/18/2023 6:24:07 PM ******/
EXEC msdb.dbo.sp_delete_job @job_id=@_JobID, @delete_unused_schedule=1


/****** Object:  Job [Vendor to IPayables]    Script Date: 4/18/2023 6:24:07 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Data Collector]    Script Date: 4/18/2023 6:24:07 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Data Collector' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Collector'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Vendor to IPayables', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Generate CSV File]    Script Date: 4/18/2023 6:24:07 PM ******/
DECLARE @strDate  NVARCHAR(20) =  REPLACE(CONVERT(nvarchar(20), GETDATE(), 102),'.','')
DECLARE @command NVARCHAR(MAX) =
N'sqlcmd -S '+ @@SERVERNAME +' -d ' + DB_NAME() + '  -Q "SET NOCOUNT ON; select strData from vyuAPVendorToIPayables order by intEntityId, strTag;" -o "' + @folderPath +'\C0000549_VENDOR_'+ @strDate +'.csv" -W -w 1024 -h-1'
--N'sqlcmd -S .\MSSQL2019 -d ' + DB_NAME() + ' -U irely -P iRely486  -Q "SET NOCOUNT ON; select strData from vyuAPVendorToIPayables order by intEntityId, strTag;" -o "' + @folderPath +'\C0000549_VENDOR_'+ @strDate +'.csv" -W -w 1024 -h-1'
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Generate CSV File', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command= @command,
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

EXEC msdb.dbo.sp_start_job N'Vendor to IPayables' ;  


END


