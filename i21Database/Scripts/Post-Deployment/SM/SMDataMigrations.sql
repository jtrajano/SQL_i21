GO

--Set default Dashboard Role to all users
UPDATE tblSMUserSecurity
SET strDashboardRole = 'User'
WHERE ISNULL(strDashboardRole, '') = ''

GO


-- Add the SQL Server custom messages
EXEC dbo.uspSMErrorMessages
GO

-- Update User Role and User Security Menus
DECLARE @currentRow INT
DECLARE @totalRows INT

SET @currentRow = 1
SELECT @totalRows = Count(*) FROM [dbo].[tblSMUserRole]

WHILE (@currentRow <= @totalRows)
BEGIN

Declare @roleId INT
SELECT @roleId = intUserRoleID FROM (  
	SELECT ROW_NUMBER() OVER(ORDER BY intUserRoleID ASC) AS 'ROWID', *
	FROM [dbo].[tblSMUserRole]
) a
WHERE ROWID = @currentRow

PRINT N'Executing uspSMUpdateUserRoleMenus'
Exec uspSMUpdateUserRoleMenus @roleId, 1, 0


SET @currentRow = @currentRow + 1
END

GO
	-- Reset Demo User Roles and permissions

	DECLARE @AdminId INT
	DECLARE @UserId INT

	SELECT TOP 1 @AdminId = intUserRoleID FROM tblSMUserRole WHERE strName = 'ADMIN'
	--SELECT TOP 1 @UserId = intUserRoleID FROM tblSMUserRole WHERE strName = 'USER'

	UPDATE tblSMUserRoleMenu
	SET ysnVisible = 1
	WHERE intUserRoleId IN (@AdminId)--, @UserId)

	EXEC uspSMUpdateUserRoleMenus @AdminId
	--EXEC uspSMUpdateUserRoleMenus @UserId

GO