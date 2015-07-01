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
	-- UPDATE ORIGIN MENUS SORT ORDER
	EXEC uspSMSortOriginMenus

GO
	-- MIGRATE SM COMPANY PREFERENCES
	EXEC uspSMMigrateCompanyPreference
GO

	-- MIGRATE AR COMPANY PREFERENCES
	EXEC uspARMigrateCompanyPreference
GO
	PRINT N'MIGRATING tblAPPreference to tblSMCompanyLocation'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPPreference' AND [COLUMN_NAME] IN ('intDefaultAccountId', 'intWithholdAccountId', 'intDiscountAccountId', 'intInterestAccountId'))
	BEGIN
		EXEC
		('
			IF EXISTS(SELECT TOP 1 1 FROM tblAPPreference)
			BEGIN		
				DECLARE @intDefaultAccountId INT,
						@intWithholdAccountId INT, 
						@intDiscountAccountId INT, 
						@intInterestAccountId INT, 
						@dblWithholdPercent DECIMAL(18, 6)

				SELECT TOP 1 @intDefaultAccountId = intDefaultAccountId, @intWithholdAccountId = intWithholdAccountId, @intDiscountAccountId = intDiscountAccountId, @intInterestAccountId = intInterestAccountId, @dblWithholdPercent = dblWithholdPercent
				FROM tblAPPreference

				PRINT N''UPDATING intWithholdAccountId, intDiscountAccountId, intInterestAccountId, dblWithholdPercent''
				UPDATE tblSMCompanyLocation 
				SET intWithholdAccountId = @intWithholdAccountId, 
				intDiscountAccountId = @intDiscountAccountId, 
				intInterestAccountId = @intInterestAccountId, 
				dblWithholdPercent = @dblWithholdPercent

				PRINT N''UPDATING intAPAccount Where intAPAccount is null''
				UPDATE tblSMCompanyLocation 
				SET intAPAccount = @intDefaultAccountId
				WHERE intAPAccount IS NULL

				PRINT N''TRUNCATING tblAPPreference''
				TRUNCATE TABLE tblAPPreference
			END
		')
	END
GO

	-- MIGRATE DB PREFERENCES
	EXEC uspDBMigrateUserPreference
GO