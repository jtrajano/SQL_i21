GO
	PRINT N'START REFRESH MENUS WHEN EXISTING 18.1 VERSION PRIOR 0730 OR 0803'
	IF OBJECT_ID('tempdb..#updateUserRoleMenus') IS NULL 
	BEGIN
		DECLARE @previous NVARCHAR(20)
		DECLARE @latest NVARCHAR(20)
		DECLARE @isPrevious BIT
		DECLARE @isLatest BIT

		SELECT TOP 1 @previous = SUBSTRING(REPLACE(strVersionNo, '18.1.', ''), 1, 4) FROM tblSMBuildNumber WHERE strVersionNo LIKE '18.1.%'ORDER BY strVersionNo ASC
		SELECT TOP 1 @latest = SUBSTRING(REPLACE(strVersionNo, '18.1.', ''), 1, 4) FROM tblSMBuildNumber WHERE strVersionNo LIKE '18.1.%'ORDER BY strVersionNo DESC
		SELECT @isPrevious = CASE WHEN CAST(@previous AS int) < CAST('0730' AS int)THEN 1 ELSE 0 END
		SELECT @isLatest = CASE WHEN CAST(@latest AS int) < CAST('0803' AS int)THEN 1 ELSE 0 END

		IF @isPrevious = 1 AND @isLatest = 1
		BEGIN
			EXEC uspSMRefreshUserRoleMenus
		END
	END
	PRINT N'END REFRESH MENUS WHEN EXISTING 18.1 VERSION PRIOR 0730 OR 0803'
GO