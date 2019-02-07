 PRINT N'START CREATE AUDIT LOG MIGRATION PLAN'
BEGIN
	--Check if current user has sysadmin/serveradmin role
	DECLARE @isUserHasRole bit
	SET @isUserHasRole = 0

	IF OBJECT_ID('tempdb..#TempSysAdmin') IS NOT NULL
		DROP TABLE #TempSysAdmin

	Create TABLE #TempSysAdmin
	(
		[ServerRole]	sysname,
		[MemberName]	sysname,
		[MemberSID]		varbinary(85)
	)

	INSERT INTO #TempSysAdmin exec sp_helpsrvrolemember 'sysadmin'

	IF OBJECT_ID('tempdb..#TempServerAdmin') IS NOT NULL
		DROP TABLE #TempServerAdmin

	Create TABLE #TempServerAdmin
	(
		[ServerRole]	sysname,
		[MemberName]	sysname,
		[MemberSID]		varbinary(85)
	)

	INSERT INTO #TempServerAdmin exec sp_helpsrvrolemember 'serveradmin'

	DECLARE @loginUser varchar(250)
	SET @loginUser = SYSTEM_USER

	SELECT @isUserHasRole = 1 FROM #TempSysAdmin WHERE MemberName = @loginUser
	IF ISNULL(@isUserHasRole, 0) = 0
	BEGIN
		SELECT @isUserHasRole = 1 FROM #TempServerAdmin WHERE MemberName = @loginUser
	END

	IF ISNULL(@isUserHasRole, 0) = 1
	BEGIN
		PRINT N'USER IS SYSADMIN/SERVERADMIN - VALID FOR CREATION OF MAINTENANCE PLAN'
		 --Get the current database
		DECLARE @currentDatabaseName varchar(100)
		DECLARE @jobId BINARY(16)
		DECLARE @unProcessedCount INT
		SET @currentDatabaseName = DB_NAME()

		SET @unProcessedCount = (SELECT COUNT(intAuditLogId) FROM tblSMAuditLog WHERE ysnProcessed = 0)
		SELECT @jobId = job_id FROM msdb.dbo.sysjobs where [name] = 'i21_AuditLog_Migration_Job'

		--IF THERE IS NO AUDIT LOG TO BE MIGRATED, DELETE THE JOB
		IF (@unProcessedCount = 0)
			BEGIN
				IF(ISNULL(@jobId,'') <> '')
					EXEC msdb.dbo.sp_delete_job @job_name = 'i21_AuditLog_Migration_Job'
			END
		
		ELSE
			BEGIN
				IF(ISNULL(@jobId,'') <> '')
					BEGIN
						EXEC msdb.dbo.sp_update_job @job_name='i21_AuditLog_Migration_Job',@enabled = 0--questionable

						EXEC [uspSMCreateAuditLogMigrationPlan] @currentDatabaseName
						
					END
						--enable the job
						EXEC msdb.dbo.sp_update_job @job_name='i21_AuditLog_Migration_Job',@enabled = 1
			END
					
	END
	ELSE
	BEGIN
		PRINT N'USER IS NOT ALLOWED TO CREATE AUDIT MIGRATION PLAN. PLEASE CONTACT YOUR DATABASE ADMINISTRATOR FOR PERMISSION'
	END
END



PRINT N'END CREATE AUDIT LOG MIGRATION PLAN'