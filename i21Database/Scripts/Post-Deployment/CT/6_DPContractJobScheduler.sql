GO
-- ==================================================================================================================
-- [START] - Validate Current SQL User if has rights to create SQL Maintenance Plan
-- ==================================================================================================================
	PRINT(N'Validate current SQL user before creating Job Scheduler named i21_Contract_Hourly_Maintenance_Job.')

	-- Check if current user has sysadmin/serveradmin role
	DECLARE @isUserHasRole BIT = CAST(0 AS BIT)

	IF OBJECT_ID('tempdb..#TempSysAdmin') IS NOT NULL
	BEGIN
		DROP TABLE #TempSysAdmin
	END
		
	CREATE TABLE #TempSysAdmin
	(
		[ServerRole]	SYSNAME,
		[MemberName]	SYSNAME,
		[MemberSID]		VARBINARY(85)
	)

	INSERT INTO #TempSysAdmin EXEC sp_helpsrvrolemember 'sysadmin'

	IF OBJECT_ID('tempdb..#TempServerAdmin') IS NOT NULL
	BEGIN
		DROP TABLE #TempServerAdmin
	END
		
	CREATE TABLE #TempServerAdmin
	(
		[ServerRole]	SYSNAME,
		[MemberName]	SYSNAME,
		[MemberSID]		VARBINARY(85)
	)

	INSERT INTO #TempServerAdmin EXEC sp_helpsrvrolemember 'serveradmin'

	DECLARE @loginUser VARCHAR(250)
	SET @loginUser = SYSTEM_USER

	SELECT @isUserHasRole = 1 
	FROM #TempSysAdmin 
	WHERE MemberName = @loginUser

	IF ISNULL(@isUserHasRole, 0) = 0
	BEGIN
		SELECT @isUserHasRole = 1 FROM #TempServerAdmin WHERE MemberName = @loginUser
	END

	-- ===================================================================================================
	-- [START] - VALIDATE
	-- ===================================================================================================
	IF ISNULL(@isUserHasRole, 0) = 1
	BEGIN
		PRINT N'Current SQL user has rights to create maintenenace plan i21_Contract_Hourly_Maintenance_Job'

		-- Turn On Agent XPs --
		EXEC sp_configure'SHOW ADVANCE',1
		RECONFIGURE
		EXEC sp_configure'AGENT XPs',1
		RECONFIGURE

			
		BEGIN TRANSACTION

		-- Maintenance plan always used msdb
		--USE msdb;  

		DECLARE @ReturnCode					INT				= 0,
				@strContractSchedulerName	NVARCHAR(100)	= N'i21 Contract Scheduler Hourly',
				@strContractPlanName		NVARCHAR(100)	= N'i21_Contract_Hourly_Maintenance_Plan',
				@strContractJobName			NVARCHAR(100)	= N'i21_Contract_Hourly_Maintenance_Job'

		DECLARE @stri21Folder				NVARCHAR(150)   = N'i21Log'
		DECLARE @stri21LogPath				NVARCHAR(150)   = N'C:\\' + @stri21Folder + '\'
		DECLARE	@stri21OutputFilename		NVARCHAR(150)   = @stri21LogPath + 'i21_Contract_Log'

		--Note: category_class
		--1 = Job
		--2 = Alert
		--3 = Operator

		-- Create JOB
		IF NOT EXISTS(SELECT TOP 1 1 FROM msdb.dbo.syscategories WHERE NAME = @strContractSchedulerName AND category_class = 1)
		BEGIN
			EXEC @ReturnCode	=	msdb.dbo.sp_add_category 
				 @class			=	N'JOB', 
				 @type			=	N'LOCAL', 
				 @name			=	@strContractSchedulerName

			IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
			BEGIN
				PRINT @@ERROR
				GOTO QuitWithRollback
			END	
		END

		-- Check if maintenance is currently existing, else create it
		DECLARE @planId BINARY(16),
				@currentDatabaseName AS NVARCHAR(100) = DB_NAME()

		SELECT @planId = plan_id FROM msdb.dbo.sysdbmaintplans WHERE plan_name = @strContractPlanName

		IF @planId IS NULL
		BEGIN
			EXEC @ReturnCode	=	msdb.dbo.sp_add_maintenance_plan
				 @plan_name		=	@strContractPlanName,
				 @plan_id		=	@planId OUTPUT

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
		DECLARE @serverName VARCHAR(250)

		SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE NAME = @strContractJobName
		SELECT @serverName = Convert(VARCHAR(250), SERVERPROPERTY('ServerName'))

		IF @jobId IS NULL
		BEGIN
			--  Adds a new job, executed by the SQL Server Agent service, called "i21_Contract_Hourly_Maintenance_Job".  
			EXEC @ReturnCode			=	msdb.dbo.sp_add_job  
				@job_name				=	@strContractJobName,
				@enabled				=	1,
				@notify_level_eventlog	=	2, 
				@description			=	N'Contract Hourly Maintenance Scheduler',
				@category_name			=	@strContractSchedulerName, 
				@job_id					=	@jobId OUTPUT

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
		DECLARE @stepName NVARCHAR(MAX)
		DECLARE @stepNameSchedule NVARCHAR(MAX)
		DECLARE @stepCommand NVARCHAR(MAX)
		DECLARE @currentDate NVARCHAR(MAX)
		DECLARE @stepId INT
		DECLARE @maxStepId INT

		SET @maxStepId = 0;
		SET @currentDate = CONVERT(NVARCHAR, GETDATE(), 112)
		SET @stepName = N'Invoke Contract Hourly Maintenance Scheduler in ' + CONVERT(VARCHAR(100), @currentDatabaseName)
		SET @stepNameSchedule = N'i21_Contract_Hourly_Scheduler in ' + CONVERT(VARCHAR(100), @currentDatabaseName)
		SET @stepCommand = N'
		GO
		BEGIN TRY
			USE [' + CONVERT(VARCHAR(50), @currentDatabaseName) + ']
			EXEC [uspCTCheckDPContract]
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
			EXEC @ReturnCode		=	msdb.dbo.sp_add_jobstep  
				@job_id				=	@jobId,
				@step_id			=	@maxStepId,
				@step_name			=	@stepName,
				@subsystem			=	N'TSQL',   
				@os_run_priority	=	0,
				@output_file_name	=	@stri21OutputFilename, 
				@flags				=	2 --Append to output file
			IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

			EXEC @ReturnCode		=	msdb.dbo.sp_update_jobstep
					@job_id			=	@jobId, 
					@step_id			=	@maxStepId,
					@command			=	@stepCommand
			IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

			EXEC @ReturnCode		=	msdb.dbo.sp_update_job 
					@job_id			=	@jobId, 
					@start_step_id		=	1
			IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
			EXEC @ReturnCode		=	msdb.dbo.sp_add_jobschedule
				@job_name			=	@strContractJobName,
				@name				=	@stepNameSchedule,
				@enabled			=	1,
				@freq_type			=	4,
				@freq_interval		=	1,
				@freq_subday_type	=	8,
				@freq_subday_interval	=	1, 
				@freq_relative_interval	=	0, 
				@freq_recurrence_factor	=	0, 
				@active_start_date	=	@currentDate, 
				@active_end_date	=	99991231, 
				@active_start_time	=	0,
				@active_end_time	=	235959

			IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

			-- Update lower step success action to "Go to next step"
			IF @maxStepId > 1
			BEGIN
				UPDATE msdb.dbo.sysjobsteps SET on_success_action = 3
				WHERE job_id = @jobId and step_id <> @maxStepId
			END

			-- Create directory for log --
			DECLARE @LogPath NVARCHAR(500)
			DECLARE @DirTree TABLE (subdirectory NVARCHAR(255), depth INT)

			SET @LogPath = @stri21LogPath

			INSERT INTO @DirTree(subdirectory, depth)
			EXEC master.sys.xp_dirtree @LogPath

			IF NOT EXISTS (SELECT 1 FROM @DirTree WHERE subdirectory = @stri21Folder)
			EXEC master.dbo.xp_create_subdir @LogPath

			DELETE FROM @DirTree
		END
		ELSE
		BEGIN
			EXEC @ReturnCode	=	msdb.dbo.sp_update_jobstep
						@job_id	=	@jobId, 
						@step_id	=	@stepId,
						@command	=	@stepCommand
			IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		END
		
		PRINT N'SQL Maintenance plan job i21_Contract_Hourly_Maintenance_Job was created successfully.'
		COMMIT TRANSACTION
		GOTO EndSave
	END
	ELSE 
	BEGIN
		PRINT N'CURRENT SQL USER IS NOT ALLOWED TO CREATE MAINTENANCE PLAN. PLEASE CONTACT YOUR DATABASE ADMINISTRATOR FOR PERMISSION.'
		GOTO QuitWithRollback
	END
	-- ===================================================================================================
	-- [END] - VALIDATE
	-- ===================================================================================================


-- ==================================================================================================================
-- [END] - Validate Current SQL User if has rights to create SQL Maintenance Plan
-- ==================================================================================================================


QuitWithRollback:
	IF (@@TRANCOUNT > 0)
	BEGIN
		ROLLBACK TRANSACTION
		PRINT 'Will ROLLBACK changes'
	END
			

EndSave:
	-- DO NOT Turn Off Agent XPs --
	--EXEC sp_configure'AGENT XPs',0
	--RECONFIGURE
	--EXEC sp_configure'SHOW ADVANCE',0
	--RECONFIGURE

GO