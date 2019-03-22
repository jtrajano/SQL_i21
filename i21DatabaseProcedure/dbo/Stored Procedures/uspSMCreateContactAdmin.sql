CREATE PROCEDURE [dbo].[uspSMCreateContactAdmin]
	@entityId int
AS
BEGIN
	DECLARE @entityName NVARCHAR(100)
	DECLARE @roleName NVARCHAR(100)
	DECLARE @helpDesk NVARCHAR(100)
	DECLARE @contactAdminRoleId INT
	DECLARE @helpDeskRoleId INT
	
	SELECT @entityName = RTRIM(strName) FROM tblEMEntity where intEntityId = @entityId

	SELECT @roleName = @entityName + '-' + CAST(@entityId AS NVARCHAR)

	INSERT INTO tblSMUserRole([strName], [strDescription], [strRoleType], [ysnAdmin])
	SELECT @roleName, 'Contact Administrator',  'Contact Admin', 1

	SELECT @contactAdminRoleId = SCOPE_IDENTITY()

	EXEC uspSMUpdateUserRoleMenus @contactAdminRoleId, 1, 1

	-- INSERT RECORD TO tblEMEntityRole
	INSERT INTO tblEMEntityToRole(intEntityId, intEntityRoleId) VALUES(@entityId, @contactAdminRoleId)

	SELECT @helpDesk = @entityName + '''s Help Desk'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserRole WHERE strName = @helpDesk)
	BEGIN
		INSERT INTO tblSMUserRole([strName], [strDescription], [strRoleType], [ysnAdmin])
		SELECT @helpDesk, @helpDesk,  'Contact', 0
		
		SELECT @helpDeskRoleId = SCOPE_IDENTITY()

		EXEC uspSMUpdateUserRoleMenus @helpDeskRoleId, 1, 0

		-- INSERT RECORD TO tblEMEntityRole
		INSERT INTO tblEMEntityToRole(intEntityId, intEntityRoleId) VALUES(@entityId, @helpDeskRoleId)
	END

	-- Enable all help desk menus
	DECLARE @HelpDeskParentMenuId INT
	SELECT @HelpDeskParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0

	UPDATE tblSMUserRoleMenu SET ysnVisible = 1
	FROM tblSMUserRoleMenu RoleMenu
	INNER JOIN tblSMMasterMenu MasterMenu ON RoleMenu.intMenuId = MasterMenu.intMenuID
	WHERE MasterMenu.intMenuID = @HelpDeskParentMenuId OR MasterMenu.intParentMenuID = @HelpDeskParentMenuId
	AND RoleMenu.intUserRoleId = @helpDeskRoleId
END