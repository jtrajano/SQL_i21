GO

PRINT N'START DELETING OF i21_CStore_Daily_Maintenance_Job'
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
		PRINT N'USER IS SYSADMIN/SERVERADMIN'
				PRINT(N'Delete existing i21_CStore_Daily_Maintenance_Job job if exists')		IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'i21_CStore_Daily_Maintenance_Job')			EXEC msdb.dbo.sp_delete_job @job_name=N'i21_CStore_Daily_Maintenance_Job', @delete_unused_schedule=1
					
	END
	ELSE
	BEGIN
		PRINT N'USER IS NOT ALLOWED TO ACCESS SQL JOBS. PLEASE CONTACT YOUR DATABASE ADMINISTRATOR FOR PERMISSION'
	END
END



PRINT N'END DELETING OF i21_CStore_Daily_Maintenance_Job'

GO