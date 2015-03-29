GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurityMenuFavorite' AND [COLUMN_NAME] = 'intUserSecurityId') 
	BEGIN
		ALTER TABLE tblSMUserSecurityMenuFavorite ADD intUserSecurityId INT NOT NULL DEFAULT 0
	END	
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurityMenuFavorite' AND [COLUMN_NAME] = 'intUserRoleMenuId') 
	BEGIN
		ALTER TABLE tblSMUserSecurityMenuFavorite ADD intUserRoleMenuId INT NOT NULL DEFAULT 0
	END	
GO	
	PRINT N'Check if intUserSecurityMenuID is existing'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurityMenuFavorite' AND [COLUMN_NAME] = 'intUserSecurityMenuId') 
	BEGIN

		IF EXISTS(SELECT TOP 1 1 FROM sys.objects where name = 'FK_tblSMUserSecurityMenuFavorite_tblSMUserSecurityMenu')
		BEGIN
			PRINT N'Drop FK_tblSMUserSecurityMenuFavorite_tblSMUserSecurityMenu'
			ALTER TABLE tblSMUserSecurityMenuFavorite DROP CONSTRAINT FK_tblSMUserSecurityMenuFavorite_tblSMUserSecurityMenu;
		END

		PRINT N'UPDATE intUserSecurityMenuId with intUserRoleMenuId data AND INSERT the intUserSecurityId'

		EXEC ('UPDATE MenuFavorite SET MenuFavorite.intUserRoleMenuId = RoleMenu.intUserRoleMenuId, MenuFavorite.intUserSecurityId = UserSecurity.intUserSecurityID
		FROM tblSMUserRoleMenu RoleMenu
		JOIN tblSMUserSecurity UserSecurity 
			ON RoleMenu.intUserRoleId = UserSecurity.intUserRoleID
		JOIN tblSMUserSecurityMenu SecurityMenu 
			ON UserSecurity.intUserSecurityID = SecurityMenu.intUserSecurityId AND SecurityMenu.intMenuId = RoleMenu.intMenuId
		JOIN tblSMUserSecurityMenuFavorite MenuFavorite 
			ON SecurityMenu.intUserSecurityMenuId = MenuFavorite.intUserSecurityMenuId')
	END
GO