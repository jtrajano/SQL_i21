CREATE PROCEDURE [dbo].[uspSMRefreshContactRoleMenus]
AS
BEGIN
	-- UPDATE ALL CONTACT ADMIN AND CONTACTS BASED ON PORTAL DEFAULT
	PRINT N'BUILDING PORTAL DEFAULT AND ALL CONTACTS'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu WHERE intUserRoleId = 999)
	BEGIN
		PRINT N'BUILDING PORTAL DEFAULT FOR THE FIRST TIME'
		EXEC uspSMUpdateUserRoleMenus 999, 1, 1
	END
	ELSE
	BEGIN
		PRINT N'BUILDING PORTAL DEFAULT'
		-- Update User Role and User Security Menus
		DECLARE @currentRow INT
		DECLARE @totalRows INT

		SET @currentRow = 1
		SELECT @totalRows = Count(*) FROM [tblSMUserRole] WHERE (strRoleType IN ('Portal Admin', 'Portal User'))

		WHILE (@currentRow <= @totalRows)
		BEGIN

		Declare @roleId INT
		SELECT @roleId = intUserRoleID FROM (  
			SELECT ROW_NUMBER() OVER(ORDER BY intUserRoleID ASC) AS 'ROWID', *
			FROM [tblSMUserRole] WHERE (strRoleType IN ('Portal Admin', 'Portal User'))
		) a
		WHERE ROWID = @currentRow

		PRINT N'Executing uspSMUpdateUserRoleMenus'
		Exec uspSMUpdateUserRoleMenus @roleId, 1, 0

		SET @currentRow = @currentRow + 1
		END
	END	
END
