 PRINT N'START CREATE RE-INDEX MAINTENANCE PLAN'
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
		PRINT N'USER IS SYSADMIN/SERVERADMIN CONTINUE'
		 --Get the current database
		DECLARE @currentDatabaseName varchar(100)
		SET @currentDatabaseName = DB_NAME()

		--Maintenance plan always used msdb
		--USE msdb;  
		EXEC [uspSMCreateReIndexMaintenancePlan] @currentDatabaseName

		DECLARE @returnCurrentDB NVARCHAR(MAX)
		SET @returnCurrentDB = N'USE ' + QUOTENAME(@currentDatabaseName)

		EXECUTE(@returnCurrentDB);
	END
	ELSE
	BEGIN
		PRINT N'USER IS NOT ALLOWED TO CREATE MAINTENANCE PLAN. PLEASE CONTACT YOUR DATABASE ADMINISTRATOR FOR PERMISSION'
	END
END



PRINT N'END CREATE RE-INDEX MAINTENANCE PLAN'