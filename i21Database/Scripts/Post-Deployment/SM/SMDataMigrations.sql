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
	-- EXECUTE FIRST BEFORE MIGRATE RECURRING TRANSACTIONS
	EXEC uspGLImportRecurring
	-- UPDATE tblSMRecurringTransaction
	EXEC uspSMMigrateRecurringTransaction

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
	-- MIGRATE USER TYPE FROM tblSMPreferences to tblSMUserPreference
	EXEC uspSMMigrateUserPreference
GO

-- Update User Preference
DECLARE @currentRow INT
DECLARE @totalRows INT

SET @currentRow = 1
SELECT @totalRows = Count(*) FROM [dbo].[tblSMUserSecurity]

WHILE (@currentRow <= @totalRows)
BEGIN

Declare @userId INT
SELECT @userId = intUserSecurityID FROM (  
	SELECT ROW_NUMBER() OVER(ORDER BY intUserSecurityID ASC) AS 'ROWID', *
	FROM [dbo].[tblSMUserSecurity]
) a
WHERE ROWID = @currentRow

PRINT N'Executing uspSMUpdateUserPreferenceEntry'
Exec uspSMUpdateUserPreferenceEntry @userId


SET @currentRow = @currentRow + 1
END

GO
	-- FLAG IN COMPANY PREFERENCE MIGRATION
	PRINT N'Updating strHelperUrlDomain in tblSMCompanyPreference'
	UPDATE tblSMCompanyPreference SET strHelperUrlDomain = N'http://help.irelyserver.com'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'User Roles per Company Location')
	BEGIN
		-- MIGRATE USER ROLE PER LOCATION AND PER USER
		DECLARE @currentRow INT
		DECLARE @totalRows INT

		SET @currentRow = 1
		SELECT @totalRows = Count(*) FROM [dbo].[tblSMUserSecurity]

		WHILE (@currentRow <= @totalRows)
		BEGIN

		Declare @userId INT
		Declare @entityId INT
		Declare @roleId INT
		SELECT @userId = intUserSecurityID, @entityId = intEntityId, @roleId = intUserRoleID FROM (  
			SELECT ROW_NUMBER() OVER(ORDER BY intUserSecurityID ASC) AS 'ROWID', *
			FROM [dbo].[tblSMUserSecurity]
		) a
		WHERE ROWID = @currentRow
		------ DEFAULT LOCATION ------
		IF EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurity WHERE intUserSecurityID = @userId AND intCompanyLocationId IS NULL)
		BEGIN
			DECLARE @defaultLocation INT
			SELECT TOP 1 @defaultLocation = intCompanyLocationId FROM tblSMCompanyLocation ORDER BY intCompanyLocationId
			IF @defaultLocation IS NOT NULL
			BEGIN
				UPDATE tblSMUserSecurity SET intCompanyLocationId = @defaultLocation WHERE intUserSecurityID = @userId
			END
		END
		------ DEFAULT LOCATION ------
			--------------------------------C O M P A N Y  L O C A T I O N--------------------------------
			DECLARE @currentRowLocation INT
			DECLARE @totalRowsLocation INT

			SET @currentRowLocation = 1
			SELECT @totalRowsLocation = Count(*) FROM [dbo].[tblSMCompanyLocation]

			WHILE (@currentRowLocation <= @totalRowsLocation)
			BEGIN

			Declare @companyLocationId INT
			SELECT @companyLocationId = intCompanyLocationId FROM (  
				SELECT ROW_NUMBER() OVER(ORDER BY intCompanyLocationId ASC) AS 'ROWID', *
				FROM [dbo].[tblSMCompanyLocation]
			) a
			WHERE ROWID = @currentRowLocation

			PRINT N'INSERTING RECORD PER COMPANY LOCATION'

			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurityCompanyLocationRolePermission WHERE intUserSecurityId = @userId AND intEntityId = @entityId AND intUserRoleId = @roleId AND intCompanyLocationId = @companyLocationId)
			BEGIN
				INSERT INTO tblSMUserSecurityCompanyLocationRolePermission ([intUserSecurityId], [intEntityId], [intUserRoleId], [intCompanyLocationId])
				VALUES (@userId, @entityId, @roleId, @companyLocationId)
			END

			SET @currentRowLocation = @currentRowLocation + 1
			END
			--------------------------------C O M P A N Y  L O C A T I O N--------------------------------
		SET @currentRow = @currentRow + 1
		END
		
		PRINT N'ADD LOG TO tblMigrationLog'
		INSERT INTO tblMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'User Roles per Company Location', 'Migration of User Roles per Company Location', GETDATE())
	END
GO