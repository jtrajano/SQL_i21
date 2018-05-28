CREATE PROCEDURE [dbo].[uspSMRefreshUserRoleMenus]
AS
BEGIN
	-- Update User Role and User Security Menus
	DECLARE @currentRow INT
	DECLARE @totalRows INT

	SET @currentRow = 1
	SELECT @totalRows = Count(*) FROM [tblSMUserRole] WHERE (strRoleType IN ('Administrator', 'User') OR strRoleType IS NOT NULL)

	WHILE (@currentRow <= @totalRows)
	BEGIN

	Declare @roleId INT
	SELECT @roleId = intUserRoleID FROM (  
		SELECT ROW_NUMBER() OVER(ORDER BY intUserRoleID ASC) AS 'ROWID', *
		FROM [tblSMUserRole] WHERE (strRoleType IN ('Administrator', 'User') OR strRoleType IS NOT NULL)
	) a
	WHERE ROWID = @currentRow

	PRINT N'Executing uspSMUpdateUserRoleMenus'
	Exec uspSMUpdateUserRoleMenus @roleId, 1, 0

	SET @currentRow = @currentRow + 1
	END
END
