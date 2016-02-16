CREATE PROCEDURE [dbo].[uspSMCreateContactAdmin]
	@entityId int
AS
BEGIN
	DECLARE @entityName NVARCHAR(100)
	DECLARE @roleName NVARCHAR(100)
	DECLARE @helpDesk NVARCHAR(100)
	DECLARE @contactAdminRoleId INT
	DECLARE @helpDeskRoleId INT
	
	SELECT @entityName = strName FROM tblEntity where intEntityId = @entityId

	SELECT @roleName = @entityName + '-' + @entityId

	INSERT INTO tblSMUserRole([strName], [strDescription], [strRoleType], [ysnAdmin])
	SELECT @roleName, 'Contact Administrator',  'Contact Admin', 1

	SELECT @contactAdminRoleId = SCOPE_IDENTITY()

	EXEC uspSMUpdateUserRoleMenus @contactAdminRoleId, 1, 1

	SELECT @helpDesk = @entityName + '''s Help Desk'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserRole WHERE strName = @helpDesk)
	BEGIN
		INSERT INTO tblSMUserRole([strName], [strDescription], [strRoleType], [ysnAdmin])
		SELECT @helpDesk, @helpDesk,  'Contact', 0
		
		SELECT @helpDeskRoleId = SCOPE_IDENTITY()

		EXEC uspSMUpdateUserRoleMenus @helpDeskRoleId, 1, 0
	END


	-- Enable all help desk menus
	UPDATE tblSMUserRoleMenu SET ysnVisible = 1
	FROM tblSMUserRoleMenu RoleMenu
	INNER JOIN tblSMMasterMenu MasterMenu ON RoleMenu.intMenuId = MasterMenu.intMenuID
	WHERE MasterMenu.strModuleName = 'Help Desk'
	AND RoleMenu.intUserRoleId = @helpDeskRoleId

END