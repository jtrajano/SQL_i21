﻿GO

-- Maintenance plan always used msdb
--USE msdb;  

-- Turn On Agent XPs --
EXEC sp_configure'SHOW ADVANCE',1
RECONFIGURE
EXEC sp_configure'AGENT XPs',1
RECONFIGURE

BEGIN TRANSACTION

DECLARE @ReturnCode				INT				= 0,
		@strCStoreSchedulerName NVARCHAR(100)	= N'i21 CStore Scheduler',
		@strCStorePlanName		NVARCHAR(100)	= N'i21_PostRetailPrice_Maintenance_Plan',
		@strCStoreJobName		NVARCHAR(100)	= N'i21_PostRetailPrice_Maintenance_Job',
		@stri21Folder			NVARCHAR(150)   = N'i21CStoreSQLLog'
		
DECLARE @stri21LogPath			NVARCHAR(150)   = N'C:\\' + @stri21Folder + '\'

--Note: category_class
--1 = Job
--2 = Alert
--3 = Operator

-- Create JOB
IF NOT EXISTS(SELECT TOP 1 1 FROM msdb.dbo.syscategories WHERE name = @strCStoreSchedulerName AND category_class = 1)
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category 
							@class		=	N'JOB', 
							@type		=	N'LOCAL', 
							@name		=	@strCStoreSchedulerName

		IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
			BEGIN
				PRINT @@ERROR
				GOTO QuitWithRollback
			END	
	END

-- Check if maintenance is currently existing, else create it
DECLARE @planId BINARY(16),
		@currentDatabaseName AS NVARCHAR(100) = DB_NAME()

SELECT @planId = plan_id FROM msdb.dbo.sysdbmaintplans WHERE plan_name = @strCStorePlanName
	IF @planId IS NULL
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_maintenance_plan 
							@plan_name	= @strCStorePlanName ,   
							@plan_id	= @planId OUTPUT 

		IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
			BEGIN
				PRINT @@ERROR
				GOTO QuitWithRollback
			END

		EXEC @ReturnCode = msdb.dbo.sp_add_maintenance_plan_db 
				@planId, 
				@currentDatabaseName
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
			BEGIN
				PRINT @@ERROR
				GOTO QuitWithRollback
			END	
	END


-- Add job for this database --
DECLARE @jobId BINARY(16)
DECLARE @serverName varchar(250)

SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE name = @strCStoreJobName
SELECT @serverName = Convert(varchar(250), SERVERPROPERTY('ServerName'))

	IF @jobId IS NULL
	BEGIN
		--  Adds a new job, executed by the SQL Server Agent service, called "i21_ReIndex_Maintenance_Schedule".  
		EXEC @ReturnCode = msdb.dbo.sp_add_job  
		   @job_name				=	@strCStoreJobName,
		   @enabled					=	1,
		   @notify_level_eventlog	=	2, 
		   @description				=	N'Post Retail Price Adjustment',
		   @category_name			=	@strCStoreSchedulerName, 
		   @job_id = @jobId OUTPUT

		IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
			BEGIN
				PRINT @@ERROR
				GOTO QuitWithRollback
			END

		EXEC @ReturnCode = msdb.dbo.sp_add_jobserver 
			 @job_id = @jobId,
			 @server_name = @serverName

		IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
			BEGIN
				PRINT @@ERROR
				GOTO QuitWithRollback
			END

		-- Add this job to our maintenance plan
		EXEC @ReturnCode = msdb.dbo.sp_add_maintenance_plan_job @planId, @jobId
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
			BEGIN
				PRINT @@ERROR
				GOTO QuitWithRollback
			END
	END


-- ADD JOB STEP AND JOB SCHEDULE FOR i21 DATABASES --
	DECLARE @stepName nvarchar(max)
	DECLARE @stepNameSchedule nvarchar(max)
	DECLARE @stepCommand nvarchar(max)
	DECLARE @currentDate nvarchar(max)
	DECLARE @stepId INT
	DECLARE @maxStepId INT

	SET @maxStepId = 0;
	SET @currentDate = convert(NVARCHAR, GETDATE(), 112)
	SET @stepName = N'Invoke Post Retail Price Stored Procedure in ' + Convert(varchar(100), @currentDatabaseName)
	SET @stepNameSchedule = N'i21_PostRetailPriceSchedule in' + Convert(varchar(100), @currentDatabaseName)
	SET @stepCommand = N'
	GO
	BEGIN TRY
		USE [' + Convert(varchar(50), @currentDatabaseName) + '] 
		EXEC [uspSTCStoreSQLScheduler]
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
	GO'



	SELECT @maxStepId = MAX(step_id) FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId
	SELECT @stepId = step_id FROM msdb.dbo.sysjobsteps WHERE step_name = @stepName
	IF ISNULL(@stepId, 0) = 0
	BEGIN
		SET @maxStepId = ISNULL(@maxStepId, 0) + 1
		-- Adds a job step for invoking the stored procedure for reindex in this database
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep  
			@job_id = @jobId,
			@step_id = @maxStepId,
			@step_name = @stepName,
			@subsystem = N'TSQL',   
			--@command = @stepCommand,
			@os_run_priority=0,
			@output_file_name=N'C:\\i21Log\i21_Reindex_Log', 
			@flags=2														--Append to output file
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_update_jobstep
			 @job_id = @jobId, 
			 @step_id = @maxStepId,
			 @command = @stepCommand
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_update_job 
			 @job_id = @jobId, 
			 @start_step_id = 1
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
		EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
			--@job_id = @jobId, 
			@job_name = @strCStoreJobName,   
			@name = @stepNameSchedule,
			@enabled = 1, 
			--@freq_type = 16,					-- Monthly
			@freq_type = 4,						-- Daily
			@freq_interval = 1,					-- Once / Sunday
			@freq_subday_type = 1,				-- At the specified time
			@freq_relative_interval = 0, 
			@freq_recurrence_factor = 1, 
			@active_start_date= @currentDate, 
			@active_end_date = 99991231, 
			@active_start_time = 10000,			-- 1AM
			--@active_start_time = 175400,		-- 1AM
			@active_end_time = 235959
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		-- Update lower step success action to "Go to next step"
		IF @maxStepId > 1
		BEGIN
			UPDATE msdb.dbo.sysjobsteps set on_success_action = 3
			WHERE job_id = @jobId and step_id <> @maxStepId
		END

		-- Create directory for log --
		DECLARE @LogPath nvarchar(500)
		DECLARE @DirTree TABLE (subdirectory nvarchar(255), depth INT)

		SET @LogPath = @stri21LogPath

		INSERT INTO @DirTree(subdirectory, depth)
		EXEC master.sys.xp_dirtree @LogPath

		IF NOT EXISTS (SELECT 1 FROM @DirTree WHERE subdirectory = @stri21Folder)
		EXEC master.dbo.xp_create_subdir @LogPath

		DELETE FROM @DirTree

	END
	ELSE
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_update_jobstep
				 @job_id = @jobId, 
				 @step_id = @stepId,
				 @command = @stepCommand
			IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END

	COMMIT TRANSACTION

	GOTO EndSave


QuitWithRollback:
		IF (@@TRANCOUNT > 0)
			BEGIN
				ROLLBACK TRANSACTION
				PRINT 'Will ROLLBACK changes'
			END
			

EndSave:

GO

