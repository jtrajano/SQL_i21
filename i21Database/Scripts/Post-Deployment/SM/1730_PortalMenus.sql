GO
	/* REBUILD PORTAL MENUS */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Rebuild Portal Menus (System Manager) - 1730')
	BEGIN
		DECLARE @currentRow INT
		DECLARE @totalRows INT

		SET @currentRow = 1
		SELECT @totalRows = Count(*) FROM [dbo].[tblSMUserRole] WHERE [strRoleType] = 'Contact Admin'

		WHILE (@currentRow <= @totalRows)
		BEGIN

		Declare @roleId INT
		SELECT @roleId = intUserRoleID FROM (  
			SELECT ROW_NUMBER() OVER(ORDER BY intUserRoleID ASC) AS 'ROWID', *
			FROM [dbo].[tblSMUserRole] WHERE [strRoleType] = 'Contact Admin'
		) a
		WHERE ROWID = @currentRow

		PRINT N'Executing uspSMUpdateUserRoleMenus'
		Exec uspSMUpdateUserRoleMenus @roleId

		SET @currentRow = @currentRow + 1
		END
		
		PRINT N'REBUILD PORTAL MENUS'
		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Rebuild Portal Menus (System Manager) - 1730', 'Rebuild Portal Menus (System Manager) - 1730', GETDATE())
	END
GO