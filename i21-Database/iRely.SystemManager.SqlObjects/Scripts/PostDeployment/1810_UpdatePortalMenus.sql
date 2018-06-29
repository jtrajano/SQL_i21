GO
	/* ARRANGE PATRONAGE MENUS */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Arrange User Role Menus - Role Menu (Patronage) - 1730')
	BEGIN
		UPDATE RoleMenu SET intSort = MasterMenu.intSort
		FROM tblSMUserRoleMenu RoleMenu
		INNER JOIN tblSMMasterMenu MasterMenu ON RoleMenu.intMenuId = MasterMenu.intMenuID
		WHERE strModuleName = 'Patronage'
		
		PRINT N'ARRANGE USER ROLE MENUS'
		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Arrange User Role Menus - Role Menu (Patronage) - 1730', 'Arrange User Role Menus - Role Menu (Patronage) - 1730', GETDATE())
	END
GO