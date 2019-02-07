--CREATE PROCEDURE [dbo].[uspSMCreateAuditLogMigrationPlan]
-- @currentDatabase NVARCHAR(100)
-- AS
-- BEGIN


--EXEC sp_configure'SHOW ADVANCE',1
--	RECONFIGURE
--	EXEC sp_configure'AGENT XPs',1
--	RECONFIGURE

--BEGIN TRANSACTION
--DECLARE @ReturnCode INT
--SELECT @ReturnCode = 0
--DECLARE @stepCommand nvarchar(max)

--SET @stepCommand = N'
--DECLARE @DAY NVARCHAR(15);
--SET @DAY = (SELECT DATENAME(DW, GETDATE()))
--DECLARE @isWeekend BIT = CASE WHEN (@DAY = ''Saturday'' OR @DAY = ''Sunday'') THEN 1 ELSE 0 END

--BEGIN TRY
--USE [' + CONVERT(nvarchar(MAX), @currentDatabase) + ']
--exec [uspSMMigrateScheduledAuditLog] @isWeekend
--END TRY
--BEGIN CATCH
--SELECT 
--		ERROR_NUMBER() AS ErrorNumber,
--		ERROR_SEVERITY() AS ErrorSeverity,
--		ERROR_STATE() as ErrorState,
--		ERROR_PROCEDURE() as ErrorProcedure,
--		ERROR_LINE() as ErrorLine,
--		ERROR_MESSAGE() as ErrorMessage;
--END CATCH
--'

--IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'i21 Audit Migration' AND category_class=1)
--BEGIN
--EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'i21 Audit Migration'
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

--END

--DECLARE @jobId BINARY(16)
--EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'i21_AuditLog_Migration_Job', 
--		@enabled=1, 
--		@notify_level_eventlog=0, 
--		@notify_level_email=0, 
--		@notify_level_netsend=0, 
--		@notify_level_page=0, 
--		@delete_level=0, 
--		@description=N'SQL Agent Job that will migrate old audit log to flat table.', 
--		@category_name=N'i21 Audit Migration', 
--		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

--EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Invoke Migration SP', 
--		@step_id=1, 
--		@cmdexec_success_code=0, 
--		@on_success_action=1, 
--		@on_success_step_id=0, 
--		@on_fail_action=2, 
--		@on_fail_step_id=0, 
--		@retry_attempts=0, 
--		@retry_interval=0, 
--		@os_run_priority=0, @subsystem=N'TSQL', 
--		@output_file_name=N'C:\\i21Log\i21_AuditMigration_Log',
--		@command=@stepCommand, 
--		@database_name= @currentDatabase, 
--		@flags=0
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'i21_Audit_Migration_WeekDay', 
--		@enabled=1, 
--		@freq_type=4, 
--		@freq_interval=1, 
--		@freq_subday_type=4, 
--		@freq_subday_interval=10, 
--		@freq_relative_interval=0, 
--		@freq_recurrence_factor=0, 
--		@active_start_date=20190206, 
--		@active_end_date=99991231, 
--		@active_start_time=0, 
--		@active_end_time=235959 
--		--@schedule_uid=N'c9bbe610-b230-49fe-901b-be6b2a121c7e'
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'i21_Audit_Migration_Weekends_FullBlast', 
--		@enabled=1, 
--		@freq_type=8, 
--		@freq_interval=65, 
--		@freq_subday_type=1, 
--		@freq_subday_interval=0, 
--		@freq_relative_interval=0, 
--		@freq_recurrence_factor=1, 
--		@active_start_date=20190206, 
--		@active_end_date=99991231, 
--		@active_start_time=0, 
--		@active_end_time=235959 
--		--@schedule_uid=N'19ad59f2-f2ee-44c3-8074-6a8bf61a2b2f'
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--COMMIT TRANSACTION
--GOTO EndSave
--QuitWithRollback:
--    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
--EndSave:


--END

CREATE PROCEDURE [dbo].[uspSMCreateAuditLogMigrationPlan]
 @currentDatabaseName NVARCHAR(100)
 AS
 BEGIN


EXEC sp_configure'SHOW ADVANCE',1
RECONFIGURE
EXEC sp_configure'AGENT XPs',1
RECONFIGURE

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0



DECLARE @stepCommand nvarchar(max)
DECLARE @stepId INT
DECLARE @stepName NVARCHAR(MAX)
DECLARE @stepWeekDaySchedule NVARCHAR(MAX)
DECLARE @stepWeekEndSchedule NVARCHAR(MAX)
DECLARE @maxStepId INT


SET @stepWeekDaySchedule = N'i21_Audit_Migration_WeekDay for ' + CONVERT(NVARCHAR(100),@currentDatabaseName)
SET @stepWeekEndSchedule = N'i21_Audit_Migration_Weekends_FullBlast for '+ @currentDatabaseName

SET @stepName = N'Invoke Migration SP in ' + CONVERT(NVARCHAR(100),@currentDatabaseName)
SET @stepCommand = N'
DECLARE @DAY NVARCHAR(15);
SET @DAY = (SELECT DATENAME(DW, GETDATE()))
DECLARE @isWeekend BIT = CASE WHEN (@DAY = ''Saturday'' OR @DAY = ''Sunday'') THEN 1 ELSE 0 END

BEGIN TRY
USE [' + CONVERT(nvarchar(MAX), @currentDatabaseName) + ']
exec [uspSMMigrateScheduledAuditLog] @isWeekend
END TRY
BEGIN CATCH
SELECT 
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() as ErrorState,
		ERROR_PROCEDURE() as ErrorProcedure,
		ERROR_LINE() as ErrorLine,
		ERROR_MESSAGE() as ErrorMessage;
END CATCH
'

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'i21 Audit Migration' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'i21 Audit Migration'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

--===================================================================================
-- CHECK IF MAINTENANCE IS CURRENTLY EXISTING ELSE CREATE IT
-------------------------------------------------------------------------------------
DECLARE @planId binary(16)
	SELECT @planId = plan_id FROM msdb.dbo.sysdbmaintplans WHERE plan_name = 'i21_AuditMigration_Maintenance_Plan'
	IF @planId IS NULL
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_maintenance_plan 
				@plan_name = 'i21_AuditMigration_Maintenance_Plan' ,   
				@plan_id = @planId OUTPUT 
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_maintenance_plan_db 
				@planId, 
				@currentDatabaseName
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END
--===================================================================================
-- ADD JOB FOR THIS DATABASE
-------------------------------------------------------------------------------------

DECLARE @jobId BINARY(16)
DECLARE @serverName NVARCHAR(MAX) = Convert(varchar(250), SERVERPROPERTY('ServerName'))
SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE name = N'i21_AuditLog_Migration_Job'
IF @jobId IS NULL
BEGIN
EXEC @ReturnCode =  msdb.dbo.sp_add_job 
		@job_name=N'i21_AuditLog_Migration_Job', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'SQL Agent Job that will migrate old audit log to flat table.', 
		@category_name=N'i21 Audit Migration', 
		--@owner_login_name=N'sa', 
		@job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobserver
		@job_id = @jobId,
		@server_name = @serverName
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_maintenance_plan_job @planId, @jobId
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		

END
--==================================================================================
-- START ADD JOB STEP AND SCHEDULE
------------------------------------------------------------------------------------
SELECT @stepId = step_id FROM msdb.dbo.sysjobsteps WHERE step_name = @stepName
SELECT @maxStepId = MAX(step_id) FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId
IF ISNULL(@stepId,0) = 0
BEGIN
SET @maxStepId = ISNULL(@maxStepId, 0) + 1
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
		@job_id=@jobId, 
		@step_name=@stepName, 
		@step_id=@maxStepId,--1, 
		@cmdexec_success_code=0, 
		@on_success_action=3,--go to next step 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@output_file_name=N'C:\\i21Log\i21_AuditMigration_Log',
		@command=@stepCommand, 
		@database_name= @currentDatabaseName, 
		@flags=2--append to output file
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
		@job_id=@jobId, 
		@name=  @stepWeekDaySchedule, 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190206, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959 
		--@schedule_uid=N'c9bbe610-b230-49fe-901b-be6b2a121c7e'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
		@job_id=@jobId, 
		@name=@stepWeekEndSchedule, 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=65, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190206, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959 
		--@schedule_uid=N'19ad59f2-f2ee-44c3-8074-6a8bf61a2b2f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--=======================================================
--UPDATE LOWER STEP SUCCESS ACTION TO "Quit with success"
---------------------------------------------------------
IF @maxStepId > 1
BEGIN
	UPDATE msdb.dbo.sysjobsteps set on_success_action = 1
	WHERE job_id = @jobId and step_id = @maxStepId
END
--EXEC @ReturnCode = msdb.dbo.sp_add_jobserver 
--					@job_id = @jobId, 
--					@server_name = @serverName
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END
	ELSE
		BEGIN
			EXEC @ReturnCode = msdb.dbo.sp_update_job
				 @job_id = @jobId,
				 @start_step_id =@stepId--,
				 --@command = @stepCommand
		END
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:


END
