GO
	/* ARRANGE PORTAL MENUS */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Arrange Portal Menus - Role Menu (Portal) - 1810')
	BEGIN
		UPDATE RoleMenu SET intSort = MasterMenu.intSort
		FROM tblSMUserRoleMenu RoleMenu
		INNER JOIN tblSMMasterMenu MasterMenu ON RoleMenu.intMenuId = MasterMenu.intMenuID
		WHERE strMenuName LIKE '% (Portal)'
		
		PRINT N'ARRANGE PORTAL MENUS'
		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Arrange Portal Menus - Role Menu (Portal) - 1810', 'Arrange Portal Menus - Role Menu (Portal) - 1810', GETDATE())
	END
GO