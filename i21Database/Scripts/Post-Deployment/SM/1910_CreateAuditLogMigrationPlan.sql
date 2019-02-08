﻿ PRINT N'START CREATE AUDIT LOG MIGRATION PLAN'
BEGIN
	--Check if current user has sysadmin/serveradmin role
	DECLARE @isUserHasValidRole bit
	SET @isUserHasValidRole = 0

	IF OBJECT_ID('tempdb..#TmpSysAdmin') IS NOT NULL
		DROP TABLE #TmpSysAdmin

	Create TABLE #TmpSysAdmin
	(
		[ServerRole]	sysname,
		[MemberName]	sysname,
		[MemberSID]		varbinary(85)
	)

	INSERT INTO #TmpSysAdmin exec sp_helpsrvrolemember 'sysadmin'

	IF OBJECT_ID('tempdb..#TmpServerAdmin') IS NOT NULL
		DROP TABLE #TmpServerAdmin

	Create TABLE #TmpServerAdmin
	(
		[ServerRole]	sysname,
		[MemberName]	sysname,
		[MemberSID]		varbinary(85)
	)

	INSERT INTO #TmpServerAdmin exec sp_helpsrvrolemember 'serveradmin'

	DECLARE @sysUser varchar(250)
	SET @sysUser = SYSTEM_USER

	SELECT @isUserHasValidRole = 1 FROM #TmpSysAdmin WHERE MemberName = @sysUser
	IF ISNULL(@isUserHasValidRole, 0) = 0
	BEGIN
		SELECT @isUserHasValidRole = 1 FROM #TmpServerAdmin WHERE MemberName = @sysUser
	END

	IF ISNULL(@isUserHasValidRole, 0) = 1
	BEGIN
		PRINT N'USER IS SYSADMIN/SERVERADMIN - VALID FOR CREATION OF MAINTENANCE PLAN'
		 --Get the current database
		DECLARE @currentDBName varchar(100)
		DECLARE @jobId BINARY(16)
		DECLARE @unProcessedCount INT
		DECLARE @step_name NVARCHAR(100)
		DECLARE @stepId INT
		DECLARE @maxStepId INT
		SET @currentDBName = DB_NAME()
		SET @step_name = N'Invoke Re-Index Stored Procedure in '+CONVERT(NVARCHAR(100),@currentDBName)

		--set processed true for this created and deleted action type
		UPDATE tblSMAuditLog SET ysnProcessed = 1  WHERE ISNULL(strActionType,'') IN ('Created', 'Deleted') 

		SET @unProcessedCount = (SELECT COUNT(intAuditLogId) FROM tblSMAuditLog WHERE ysnProcessed = 0)
		SELECT @jobId = job_id FROM msdb.dbo.sysjobs where [name] = 'i21_AuditLog_Migration_Job'

		--IF THERE IS NO AUDIT LOG TO BE MIGRATED, DELETE THE JOB
		IF (@unProcessedCount = 0)
			BEGIN
				IF(@jobId is not null)
					BEGIN
						SELECT @stepId = step_id FROM msdb.dbo.sysjobsteps WHERE step_name = @step_name AND job_id = @jobId
						
						exec msdb.dbo.sp_delete_jobstep @job_id = @jobId, @step_id = @stepId --delete job step

						SET @maxStepId = (select max(step_id) from msdb.dbo.sysjobsteps where job_id = @jobId)

						if(@maxStepId = @stepId) --delete job if it is the remaining step
							begin
								exec msdb.dbo.sp_delete_job @job_name = @jobId
							end

					 --finally, update the onsuccess of last step to 'quit the job success'
					   update msdb.dbo.sysjobsteps set on_success_action = 1 WHERE job_id = @jobId and step_id = @maxStepId 
							
					END
					
			END
		
		ELSE
			BEGIN
				IF(@jobId is not null)
					BEGIN
						EXEC msdb.dbo.sp_update_job @job_name='i21_AuditLog_Migration_Job',@enabled = 0--disable job

						EXEC [uspSMCreateAuditLogMigrationPlan] @currentDBName
						
						EXEC msdb.dbo.sp_update_job @job_name='i21_AuditLog_Migration_Job',@enabled = 1--enable the job
					END
						
			END
					
	END
	ELSE
	BEGIN
		PRINT N'USER IS NOT ALLOWED TO CREATE AUDIT MIGRATION PLAN. PLEASE CONTACT YOUR DATABASE ADMINISTRATOR FOR PERMISSION'
	END
END



PRINT N'END CREATE AUDIT LOG MIGRATION PLAN'