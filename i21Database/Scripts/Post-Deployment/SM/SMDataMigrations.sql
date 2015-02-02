GO
	-- Reset Demo User Roles and permissions

	DECLARE @AdminId INT
	DECLARE @UserId INT

	SELECT TOP 1 @AdminId = intUserRoleID FROM tblSMUserRole WHERE strName = 'ADMIN'
	SELECT TOP 1 @UserId = intUserRoleID FROM tblSMUserRole WHERE strName = 'USER'

	UPDATE tblSMUserRoleMenu
	SET ysnVisible = 1
	WHERE intUserRoleId IN (@AdminId, @UserId)

	EXEC uspSMUpdateUserRoleMenus @AdminId
	EXEC uspSMUpdateUserRoleMenus @UserId

GO

--Set default Dashboard Role to all users
UPDATE tblSMUserSecurity
SET strDashboardRole = 'User'
WHERE ISNULL(strDashboardRole, '') = ''

GO


-- Add the SQL Server custom messages
EXEC dbo.uspSMErrorMessages
GO