GO
	/* ARRANGE SALES MENUS */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Arrange User Role Menus - Role Menu (Sales) - 1740')
	BEGIN
		UPDATE RoleMenu SET intSort = MasterMenu.intSort
		FROM tblSMUserRoleMenu RoleMenu
		INNER JOIN tblSMMasterMenu MasterMenu ON RoleMenu.intMenuId = MasterMenu.intMenuID
		WHERE strModuleName = 'Accounts Receivable'
		
		PRINT N'ARRANGE USER ROLE MENUS'
		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Arrange User Role Menus - Role Menu (Sales) - 1740', 'Arrange User Role Menus - Role Menu (Sales) - 1740', GETDATE())
	END
GO