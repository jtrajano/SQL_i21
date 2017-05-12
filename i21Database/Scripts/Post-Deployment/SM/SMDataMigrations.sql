GO

	--Set default Dashboard Role to all users
	UPDATE tblSMUserSecurity
	SET strDashboardRole = 'User'
	WHERE ISNULL(strDashboardRole, '') = ''

GO

	-- Add the SQL Server custom messages
	--EXEC dbo.uspSMErrorMessages
	--EXEC dbo.uspICErrorMessages
GO

	-- Update User Role and User Security Menus
	DECLARE @currentRow INT
	DECLARE @totalRows INT

	SET @currentRow = 1
	SELECT @totalRows = Count(*) FROM [tblSMUserRole] WHERE (strRoleType NOT IN ('Contact Admin', 'Contact') OR strRoleType IS NULL) AND intUserRoleID <> 999

	WHILE (@currentRow <= @totalRows)
	BEGIN

	Declare @roleId INT
	SELECT @roleId = intUserRoleID FROM (  
		SELECT ROW_NUMBER() OVER(ORDER BY intUserRoleID ASC) AS 'ROWID', *
		FROM [tblSMUserRole] WHERE (strRoleType NOT IN ('Contact Admin', 'Contact') OR strRoleType IS NULL) AND intUserRoleID <> 999
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
	-- Add Help Desk role menus if not existing
	DECLARE @helpDesk INT

	SELECT TOP 1 @helpDesk = intUserRoleID FROM tblSMUserRole WHERE strName = 'Help Desk'

	EXEC uspSMUpdateUserRoleMenus @helpDesk

	UPDATE tblSMUserRoleMenu
	SET ysnVisible = 1
	FROM tblSMUserRoleMenu RoleMenu
	INNER JOIN tblSMMasterMenu MasterMenu ON RoleMenu.intMenuId = MasterMenu.intMenuID
	WHERE strMenuName IN ('Help Desk', 'Create Ticket', 'Tickets', 'Project Lists', 'Reminder Lists') 
	AND strModuleName = 'Help Desk'
	AND intUserRoleId = @helpDesk

GO
	-- UPDATE ORIGIN MENUS SORT ORDER
	EXEC uspSMSortOriginMenus
GO
	-- UPDATE ORIGIN MENUS ICON
	EXEC uspSMApplyOriginMenusIcon
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
	PRINT N'MIGRATING tblAPCompanyPreference to tblSMCompanyLocation'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPCompanyPreference' AND [COLUMN_NAME] IN ('intDefaultAccountId', 'intWithholdAccountId', 'intDiscountAccountId', 'intInterestAccountId'))
	BEGIN
		EXEC
		('
			IF EXISTS(SELECT TOP 1 1 FROM tblAPCompanyPreference)
			BEGIN		
				DECLARE @intDefaultAccountId INT,
						@intWithholdAccountId INT, 
						@intDiscountAccountId INT, 
						@intInterestAccountId INT, 
						@dblWithholdPercent DECIMAL(18, 6)

				SELECT TOP 1 @intDefaultAccountId = intDefaultAccountId, @intWithholdAccountId = intWithholdAccountId, @intDiscountAccountId = intDiscountAccountId, @intInterestAccountId = intInterestAccountId, @dblWithholdPercent = dblWithholdPercent
				FROM tblAPCompanyPreference

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

				PRINT N''TRUNCATING tblAPCompanyPreference''
				TRUNCATE TABLE tblAPCompanyPreference
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
	SELECT @userId = [intEntityId] FROM (  
		SELECT ROW_NUMBER() OVER(ORDER BY [intEntityId] ASC) AS 'ROWID', *
		FROM [dbo].[tblSMUserSecurity]
	) a
	WHERE ROWID = @currentRow

	PRINT N'Executing uspSMUpdateUserPreferenceEntry'
	Exec uspSMUpdateUserPreferenceEntry @userId

	SET @currentRow = @currentRow + 1
	END

GO

	PRINT N'DELETE INVALID USER PREFERENCES'
	DELETE FROM tblSMUserPreference 
	WHERE intEntityUserSecurityId NOT IN (SELECT [intEntityId] FROM tblSMUserSecurity)

GO
--	-- INSERT DEFAULT LOCATION
--	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCompanyLocation)
--	BEGIN
--		INSERT INTO tblSMCompanyLocation([strLocationName], [strLocationNumber], [strLocationType], [strUseLocationAddress], [intAllowablePickDayRange], [intNoOfCopiesToPrintforPalletSlip], [intDemandNoMaxLength], [intDemandNoMinLength])
--		VALUES ('01', '', 'Office', 'No', 0, 0, 0, 0)
--	END
--GO
	-- FLAG IN COMPANY PREFERENCE MIGRATION
	PRINT N'Updating strHelperUrlDomain in tblSMCompanyPreference'
	UPDATE tblSMCompanyPreference SET strHelperUrlDomain = N'http://help.irelyserver.com'
GO
--	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'User Roles per Company Location')
--	BEGIN
--		-- MIGRATE USER ROLE PER LOCATION AND PER USER
--		DECLARE @currentRow INT
--		DECLARE @totalRows INT

--		SET @currentRow = 1
--		SELECT @totalRows = Count(*) FROM [dbo].[tblSMUserSecurity]

--		WHILE (@currentRow <= @totalRows)
--		BEGIN

--		Declare @userId INT
--		Declare @entityId INT
--		Declare @roleId INT
--		SELECT @userId = [intEntityUserSecurityId], @entityId = [intEntityUserSecurityId], @roleId = intUserRoleID FROM (  
--			SELECT ROW_NUMBER() OVER(ORDER BY [intEntityUserSecurityId] ASC) AS 'ROWID', *
--			FROM [dbo].[tblSMUserSecurity]
--		) a
--		WHERE ROWID = @currentRow
--		------ DEFAULT LOCATION ------
--		IF EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @userId AND intCompanyLocationId IS NULL)
--		BEGIN
--			DECLARE @defaultLocation INT
--			SELECT TOP 1 @defaultLocation = intCompanyLocationId FROM tblSMCompanyLocation ORDER BY intCompanyLocationId
--			IF @defaultLocation IS NOT NULL
--			BEGIN
--				UPDATE tblSMUserSecurity SET intCompanyLocationId = @defaultLocation WHERE [intEntityUserSecurityId] = @userId
--			END
--		END
--		------ DEFAULT LOCATION ------
--			--------------------------------C O M P A N Y  L O C A T I O N--------------------------------
--			DECLARE @currentRowLocation INT
--			DECLARE @totalRowsLocation INT

--			SET @currentRowLocation = 1
--			SELECT @totalRowsLocation = Count(*) FROM [dbo].[tblSMCompanyLocation]

--			WHILE (@currentRowLocation <= @totalRowsLocation)
--			BEGIN

--			Declare @companyLocationId INT
--			SELECT @companyLocationId = intCompanyLocationId FROM (  
--				SELECT ROW_NUMBER() OVER(ORDER BY intCompanyLocationId ASC) AS 'ROWID', *
--				FROM [dbo].[tblSMCompanyLocation]
--			) a
--			WHERE ROWID = @currentRowLocation

--			PRINT N'INSERTING RECORD PER COMPANY LOCATION'

--			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurityCompanyLocationRolePermission WHERE [intEntityUserSecurityId] = @userId AND intEntityId = @entityId AND intUserRoleId = @roleId AND intCompanyLocationId = @companyLocationId)
--			BEGIN
--				INSERT INTO tblSMUserSecurityCompanyLocationRolePermission ([intEntityUserSecurityId], [intEntityId], [intUserRoleId], [intCompanyLocationId])
--				VALUES (@userId, @entityId, @roleId, @companyLocationId)
--			END

--			SET @currentRowLocation = @currentRowLocation + 1
--			END
--			--------------------------------C O M P A N Y  L O C A T I O N--------------------------------
--		SET @currentRow = @currentRow + 1
--		END
		
--		PRINT N'ADD LOG TO tblSMMigrationLog'
--		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
--		VALUES('System Manager', 'User Roles per Company Location', 'Migration of User Roles per Company Location', GETDATE())
--	END
--GO
--	-- Update intCompanyLocationId in tblSMUserSecurityMenuFavorite with user default location.
--	UPDATE tblSMUserSecurityMenuFavorite SET intCompanyLocationId = UserSecurity.intCompanyLocationId
--	FROM tblSMUserSecurityMenuFavorite Favorite
--	JOIN tblSMUserSecurity UserSecurity ON Favorite.[intEntityUserSecurityId] = UserSecurity.[intEntityUserSecurityId]
--	WHERE Favorite.intCompanyLocationId IS NULL
GO
	-- Import General Journal to tblSMRecurringTransaction
	INSERT INTO tblSMRecurringTransaction (intTransactionId, strTransactionNumber, strTransactionType,  strReference, strFrequency, dtmLastProcess, dtmNextProcess, ysnDue, strDayOfMonth, dtmStartDate, dtmEndDate, ysnActive, intIteration, intUserId, ysnAvailable)
	SELECT journal.intJournalId, journal.strJournalId, 'General Journal', journal.strDescription, 'Monthly', journal.dtmDate, DATEADD(MM, 1, journal.dtmDate), 0, DAY(journal.dtmDate), DATEADD(MM, 1, journal.dtmDate), DATEADD(MM, 1, journal.dtmDate), 0, 1, journal.intEntityId, 1
	FROM tblGLJournal journal
	WHERE journal.strTransactionType = 'Recurring' AND journal.dtmDate IS NOT NULL AND intJournalId NOT IN (SELECT intTransactionId FROM tblSMRecurringTransaction WHERE strTransactionType = 'General Journal')
GO
	-- Assign Role Type if null
	UPDATE tblSMUserRole 
	SET strRoleType = CASE UserRole.ysnAdmin WHEN 1 THEN 'Administrator' ELSE 'User' END 
	FROM tblSMUserRole UserRole WHERE UserRole.strRoleType IS NULL
GO

	/* MIGRATE HD ANNOUNCEMENT TO SM ANNOUNCEMENT */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Migrate HD Announcement to SM Announcement')
	BEGIN
		INSERT INTO tblSMAnnouncementType(strAnnouncementType, strDescription, strDisplayTo, strFontColor, strBackColor, intSort)
		SELECT strAnnouncementType, strDescription, strDisplayTo, strFontColor, strBackColor, intSort FROM tblHDAnnouncementType

		INSERT INTO tblSMAnnouncementUpload(strImageId, strFileIdentifier, strFilename, strFileLocation, blbFile)
		SELECT strTicketCommentImageId, strFileIdentifier, strFileName,  REPLACE(REPLACE(strFileLocation, 'HelpDesk', 'i21'), 'redactorUpload', 'Upload\Announcement'), blbFile FROM tblHDUpload

		INSERT INTO tblSMAnnouncement(intAnnouncementTypeId, dtmStartDate, dtmEndDate, strAnnouncement, intSort, strImageId)
		SELECT AnnouncementType1.intAnnouncementTypeId, Announcement.dtmStartDate, Announcement.dtmEndDate, REPLACE(REPLACE(Announcement.strAnnouncement, 'HelpDesk', 'i21'), 'redactorUpload', 'Upload/Announcement'), Announcement.intSort, Announcement.strImageId 
		FROM tblSMAnnouncementType AnnouncementType1
		INNER JOIN tblHDAnnouncementType AnnouncementType2 ON AnnouncementType1.strAnnouncementType = AnnouncementType2.strAnnouncementType
		INNER JOIN tblHDAnnouncement Announcement ON AnnouncementType2.intAnnouncementTypeId = Announcement.intAnnouncementTypeId

		INSERT INTO tblSMAnnouncementDisplay(intAnnouncementId, intEntityId)
		SELECT Announcement1.intAnnouncementId, AnnouncementDisplay.intEntityId FROM tblSMAnnouncement Announcement1
		INNER JOIN tblHDAnnouncement Announcement2 ON Announcement1.strImageId = Announcement2.strImageId
		INNER JOIN tblHDAnnouncementDisplay AnnouncementDisplay ON AnnouncementDisplay.intAnnouncementId = Announcement2.intAnnouncementId

		PRINT N'ADD LOG TO tblSMMigrationLog'
		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Migrate HD Announcement to SM Announcement', 'Migrate HD Announcement to SM Announcement', GETDATE())
	END

GO	

	DECLARE @currentRow INT
	DECLARE @totalRows INT

	SET @currentRow = 1
	SELECT @totalRows = COUNT(*) FROM (SELECT Count(*) as 'Count' FROM [dbo].[tblSMUserSecurityMenuFavorite] GROUP BY intEntityUserSecurityId) a

	WHILE (@currentRow <= @totalRows)
	BEGIN

		Declare @entityId INT
		SELECT @entityId = [intEntityUserSecurityId] FROM (  
			SELECT intEntityUserSecurityId, COUNT(*) as 'Total', ROW_NUMBER() OVER(ORDER BY [intEntityUserSecurityId] ASC) AS 'ROWID'
			FROM [dbo].[tblSMUserSecurityMenuFavorite] GROUP BY intEntityUserSecurityId
		) a
		WHERE ROWID = @currentRow

		DECLARE @currentRow1 INT
		DECLARE @totalRows1 INT

		SET @currentRow1 = 1
		SELECT @totalRows1 = COUNT(*) FROM (SELECT Count(*) as 'Count' FROM [dbo].[tblSMUserSecurityMenuFavorite] WHERE intEntityUserSecurityId = @entityId GROUP BY intCompanyLocationId) a 

		WHILE (@currentRow1 <= @totalRows1)
		BEGIN

			Declare @companyLocationId INT
			SELECT @companyLocationId = [intCompanyLocationId] FROM (  
				SELECT [intCompanyLocationId], Count(*) as 'Count', ROW_NUMBER() OVER(ORDER BY [intCompanyLocationId] ASC) AS 'ROWID'
				FROM [dbo].[tblSMUserSecurityMenuFavorite] WHERE intEntityUserSecurityId = @entityId GROUP BY intCompanyLocationId
			) a
			WHERE ROWID = @currentRow1

			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMEntityMenuFavorite WHERE intEntityId = @entityId)
			BEGIN
				INSERT INTO tblSMEntityMenuFavorite(intMenuId, intEntityId, intCompanyLocationId, intSort)
				SELECT intMenuId, intEntityUserSecurityId, intCompanyLocationId, ROW_NUMBER() OVER (ORDER BY intUserSecurityMenuFavoriteId) AS 'intSort' 
				FROM tblSMUserSecurityMenuFavorite SecurityFavorite
				WHERE NOT EXISTS 
				(
					SELECT 1 FROM tblSMEntityMenuFavorite EntityFavorite WHERE SecurityFavorite.intMenuId = EntityFavorite.intMenuId AND SecurityFavorite.intEntityUserSecurityId = EntityFavorite.intEntityId AND ISNULL(SecurityFavorite.intCompanyLocationId,0) = ISNULL(EntityFavorite.intCompanyLocationId, 0)
				)
				AND intEntityUserSecurityId = @entityId AND ISNULL(intCompanyLocationId, 0) = ISNULL(@companyLocationId, 0)
			END

			DELETE FROM tblSMUserSecurityMenuFavorite WHERE intEntityUserSecurityId = @entityId AND ISNULL(intCompanyLocationId, 0) = ISNULL(@companyLocationId, 0)
		
			SET @currentRow1 = @currentRow1 + 1
		END

		SET @currentRow = @currentRow + 1
	END
	
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Migrate All Entity Roles - tblEMEntityToContact')
	BEGIN
		-- Loop through customers
		DECLARE @currentRow INT
		DECLARE @totalRows INT

		PRINT N'GET TOTAL ROWS'
		SET @currentRow = 1
		SELECT @totalRows = Count(*) FROM (SELECT DISTINCT intEntityId FROM [dbo].[tblEMEntityType]) a-- where strType IN ('Customer', 'Vendor')) a

		--PRINT CONCAT(N'TOTAL ROWS ', @totalRows)

		WHILE (@currentRow <= @totalRows)
		BEGIN

		DECLARE @customerId INT
		SELECT @customerId = intEntityId FROM (  
			SELECT ROW_NUMBER() OVER(ORDER BY intEntityId ASC) AS 'ROWID', *
			FROM (SELECT DISTINCT intEntityId FROM [dbo].[tblEMEntityType]) a-- where strType IN ('Customer', 'Vendor')) a
		) b
		WHERE ROWID = @currentRow
		--PRINT CONCAT(N'CUSTOMER ID ', @customerId)

		-- Loop through all contacts of the current customer with user role

			DECLARE @currentRow1 INT
			DECLARE @totalRows1 INT

			SET @currentRow1 = 1
			SELECT @totalRows1 = Count(*) FROM [dbo].[tblEMEntityToContact] EntityToContact
			WHERE EntityToContact.intEntityRoleId IS NOT NULL AND EntityToContact.intEntityId = @customerId
			--PRINT CONCAT(N'TOTAL NUMBER OF CONTACTS ', @totalRows1)

			WHILE (@currentRow1 <= @totalRows1)
			BEGIN

			DECLARE @contactId INT
			SELECT @contactId = intEntityContactId FROM (  
				SELECT EntityToContact.intEntityContactId as intEntityContactId, ROW_NUMBER() OVER(ORDER BY EntityToContact.intEntityId ASC) AS 'ROWID'
				FROM [dbo].[tblEMEntityToContact] EntityToContact
				WHERE EntityToContact.intEntityRoleId IS NOT NULL AND EntityToContact.intEntityId = @customerId
			) a
			WHERE ROWID = @currentRow1
			--PRINT CONCAT(N'CONTACT ID ', @contactId)

			-- Get role
			DECLARE @roleId INT
			SELECT @roleId = intEntityRoleId FROM [tblEMEntityToContact] WHERE intEntityContactId = @contactId
			--PRINT CONCAT(N'ROLE ID ', @roleId)

			-- Get customer name
			DECLARE @customerName VARCHAR(50)	
			SELECT @customerName = RTRIM(strName) FROM tblEMEntity WHERE intEntityId = @customerId
			--PRINT CONCAT(N'CUSTOMER NAME ', @customerName)
	
			DECLARE @roleName VARCHAR(50)
			SELECT @roleName = CAST(@customerName AS VARCHAR) + '''s ' + strName
			FROM tblSMUserRole 
			WHERE intUserRoleID = @roleId
			--PRINT CONCAT(N'ROLE NAME ', @roleName)

			DECLARE @newRoleId INT
			-- Duplicate role
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserRole WHERE strName = @roleName)
			BEGIN
				PRINT N'INSERTING NEW ROLE'
				INSERT INTO tblSMUserRole(strName, strDescription, strMenu, strMenuPermission, strForm, strRoleType, ysnAdmin)
				SELECT @roleName as strName, @roleName as strDescription, strMenu, strMenuPermission, strForm, 'Contact', 0 
				FROM tblSMUserRole 
				WHERE intUserRoleID = @roleId

				SELECT @newRoleId = SCOPE_IDENTITY()
				--PRINT CONCAT(N'NEW ROLE ID ', @newRoleId)

				--PRINT CONCAT(N'UPDATE USER ROLE MENUS FOR ROLE ID ', @newRoleId)
				EXEC uspSMUpdateUserRoleMenus @newRoleId, 1, 0

				-- ENABLING EXISTING MENUS
				UPDATE tblSMUserRoleMenu SET ysnVisible = 1 WHERE intUserRoleId = @newRoleId AND intMenuId IN (SELECT intMenuId FROM tblSMUserRoleMenu WHERE ysnVisible = 1 AND intUserRoleId = @roleId)

				-- INSERT RECORD TO tblEMEntityRole
				INSERT INTO tblEMEntityToRole(intEntityId, intEntityRoleId)
				VALUES(@customerId, @newRoleId)
			END
			ELSE
			BEGIN
				SELECT @newRoleId = intUserRoleID FROM tblSMUserRole WHERE strName = @roleName
			END

			---- assign it back to respective contact
			--PRINT CONCAT(N'ASSIGNING THE ROLE ID ', @newRoleId, ' TO CONTACT ID ', @contactId)
			UPDATE [tblEMEntityToContact] SET intEntityRoleId = @newRoleId WHERE intEntityContactId = @contactId

			SET @currentRow1 = @currentRow1 + 1
			END

			IF @totalRows1 > 0
			BEGIN

				--DECLARE @timeStamp VARCHAR(50)
				--select @timeStamp = SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR, GETDATE(), 121), ' ', ''), '-', ''), ':', ''), '.', ''), 3, 15)
				--PRINT CONCAT(N'TIMESTAMP ', @timeStamp)

				DECLARE @contactAdminName VARCHAR(50)
				SELECT @contactAdminName = CAST(@customerName AS VARCHAR) +  '-' + CAST(@customerId AS VARCHAR)
				--PRINT CONCAT(N'CONTACT ADMIN NAME ', @contactAdminName)

				-- Create a role as contact admin (and Get all menus) ?
				--PRINT CONCAT(N'INSERTING NEW CONTACT ADMIN NAMED ', @contactAdminName)
				INSERT INTO tblSMUserRole(strName, strDescription, strRoleType, ysnAdmin)
				VALUES(@contactAdminName, 'Contact Administrator', 'Contact Admin', 1)

				DECLARE @contactAdminRoleId INT
				SELECT @contactAdminRoleId = SCOPE_IDENTITY()
				--PRINT CONCAT(N'UPDATING NEW CONTACT ADMIN''S USER ROLE MENUS WITH ROLE ID ', @contactAdminRoleId)
				EXEC uspSMUpdateUserRoleMenus @contactAdminRoleId, 1, 1

				-- Get default contact and check if contact has portal permission
				PRINT N'CHECKING IF CUSTOMER''S DEFAULT CONTACT HAVE PORTAL ACCESS'
				IF EXISTS(SELECT TOP 1 1 FROM [tblEMEntityToContact] WHERE intEntityId = @customerId AND ysnDefaultContact = 1 AND ysnPortalAccess = 1)
				BEGIN
					-- if default contact has portal permission assign all the menus
					--PRINT CONCAT(N'ASSIGNING NEW CONTACT ADMIN ROLE ID TO DEFAULT CONTACT ', @contactAdminRoleId)
					UPDATE [tblEMEntityToContact] SET intEntityRoleId = @contactAdminRoleId 
					WHERE intEntityId = @customerId AND ysnDefaultContact = 1 AND ysnPortalAccess = 1
				END
				ELSE
				BEGIN
					-- else select top 1 and assign all the menus
					--PRINT CONCAT(N'ASSIGNING NEW CONTACT ADMIN ROLE ID TO THE TOP 1 CONTACT ', @customerId, ' ', @contactAdminRoleId)
					UPDATE [tblEMEntityToContact] SET intEntityRoleId = @contactAdminRoleId 
					WHERE intEntityContactId = (SELECT TOP 1 intEntityContactId 
												FROM [tblEMEntityToContact] 
												WHERE intEntityId = @customerId AND ysnPortalAccess = 1)
				END
					-- INSERT RECORD TO tblEMEntityRole
					INSERT INTO tblEMEntityToRole(intEntityId, intEntityRoleId)
					VALUES(@customerId, @contactAdminRoleId)
			END
	
		SET @currentRow = @currentRow + 1
		END

		DECLARE @CRMParentMenuId INT
		SELECT @CRMParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'CRM' AND strModuleName = 'Help Desk'

		UPDATE tblSMUserRoleMenu SET ysnVisible = 0 FROM [tblEMEntityType] EntityType
		INNER JOIN tblEMEntityToRole EntityToRole ON EntityType.intEntityId = EntityToRole.intEntityId
		INNER JOIN tblSMUserRoleMenu UserRoleMenu ON EntityToRole.intEntityRoleId = UserRoleMenu.intUserRoleId
		INNER JOIN tblSMMasterMenu MasterMenu ON UserRoleMenu.intMenuId = MasterMenu.intMenuID
		WHERE (MasterMenu.intMenuID = @CRMParentMenuId OR MasterMenu.intParentMenuID = @CRMParentMenuId)
		AND EntityType.strType <> 'Salesperson'

		UPDATE tblSMUserRoleMenu SET ysnVisible = 1 FROM [tblEMEntityType] EntityType
		INNER JOIN tblEMEntityToRole EntityToRole ON EntityType.intEntityId = EntityToRole.intEntityId
		INNER JOIN tblSMUserRoleMenu UserRoleMenu ON EntityToRole.intEntityRoleId = UserRoleMenu.intUserRoleId
		INNER JOIN tblSMMasterMenu MasterMenu ON UserRoleMenu.intMenuId = MasterMenu.intMenuID
		WHERE (MasterMenu.intMenuID = @CRMParentMenuId OR MasterMenu.intParentMenuID = @CRMParentMenuId)
		AND EntityType.strType = 'Salesperson'

		UPDATE tblSMUserRoleMenu SET ysnVisible = 0
		FROM [tblEMEntityType] EntityType
		INNER JOIN tblEMEntityToRole EntityToRole ON EntityType.intEntityId = EntityToRole.intEntityId
		INNER JOIN tblSMUserRoleMenu UserRoleMenu ON EntityToRole.intEntityRoleId = UserRoleMenu.intUserRoleId
		INNER JOIN tblSMMasterMenu MasterMenu ON UserRoleMenu.intMenuId = MasterMenu.intMenuID
		WHERE MasterMenu.strModuleName IN ('Scale', 'Grain', 'Logistics')

		-- delete all un-assigned contact role (except for Help Desk) ?
		PRINT N'DELETING UN-ASSIGNED CONTACTS USER ROLES'
		--DELETE FROM tblSMUserRole 
		--WHERE intUserRoleID IN (SELECT intUserRoleID FROM tblSMUserRole 
		--					  WHERE strRoleType IN ('Contact Admin', 'Contact') 
		--					  AND intUserRoleID NOT IN (SELECT intEntityRoleId
		--												FROM tblEMEntityToContact 
		--												WHERE intEntityRoleId IS NOT NULL))
				
		PRINT N'ADD LOG TO tblSMMigrationLog'
		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Migrate All Entity Roles - tblEMEntityToContact', 'Migrate All Entity Roles - tblEMEntityToContact', GETDATE())
	END	
GO
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
		EXEC uspSMUpdateUserRoleMenus 999, 1, 0
	END

--	-- UPDATE ALL CONTACTS BASED ON THEIR CONTACT ADMINISTRATOR
--	DECLARE @currentRow INT
--	DECLARE @totalRows INT

--	SET @currentRow = 1
--	SELECT @totalRows = Count(*) FROM [dbo].[tblSMUserRole] WHERE [strRoleType] = 'Contact Admin'

--	WHILE (@currentRow <= @totalRows)
--	BEGIN

--	Declare @roleId INT
--	SELECT @roleId = intUserRoleID FROM (  
--		SELECT ROW_NUMBER() OVER(ORDER BY intUserRoleID ASC) AS 'ROWID', *
--		FROM [dbo].[tblSMUserRole] WHERE [strRoleType] = 'Contact Admin'
--	) a
--	WHERE ROWID = @currentRow

--	PRINT N'Executing uspSMResolveContactRoleMenus'
--	Exec uspSMResolveContactRoleMenus @roleId

--	SET @currentRow = @currentRow + 1
--	END
--GO
--	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Update Level/Sorting Order - Approval List')
--	BEGIN

--		DECLARE @currentRow INT
--		DECLARE @totalRows INT

--		SET @currentRow = 1
--		SELECT @totalRows = Count(*) FROM [dbo].[tblSMApprovalList]

--		WHILE (@currentRow <= @totalRows)
--		BEGIN

--		Declare @approvalListId INT
--		SELECT @approvalListId = intApprovalListId FROM (  
--			SELECT ROW_NUMBER() OVER(ORDER BY intApprovalListId ASC) AS 'ROWID', *
--			FROM [dbo].[tblSMApprovalList]
--		) a
--		WHERE ROWID = @currentRow

--		UPDATE A1 SET A1.intApproverLevel = intSortLevel, A1.intSort = intSortLevel
--		FROM
--		(
--			SELECT A.intApproverLevel, A.intSort, CAST (ROW_NUMBER() OVER (ORDER BY B.intApproverLevel, B.intApprovalListUserSecurityId ASC) AS INT) as intSortLevel
--			FROM tblSMApprovalListUserSecurity A
--			INNER JOIN tblSMApprovalListUserSecurity B ON A.intApprovalListUserSecurityId = B.intApprovalListUserSecurityId
--			WHERE B.intApprovalListId = @approvalListId
--		) A1

--		SET @currentRow = @currentRow + 1
--		END
		
--		PRINT N'ADD LOG TO tblSMMigrationLog'
--		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
--		VALUES('System Manager', 'Update Level/Sorting Order - Approval List', 'Update Level/Sorting Order - Approval List', GETDATE())

--	END
GO
	PRINT N'ASSIGNING DEFAULT SECURITY POLICY TO USERS'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurity WHERE intSecurityPolicyId IS NOT NULL)
	BEGIN
		UPDATE tblSMUserSecurity SET intSecurityPolicyId = 1 WHERE intSecurityPolicyId IS NULL
	END
GO
	IF EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE (intDefaultCountryId IS NULL OR intDefaultCountryId = 0))
	BEGIN
		PRINT N'ASSIGNING DEFAULT COUNTRY'
		UPDATE tblSMCompanyPreference SET intDefaultCountryId = (SELECT TOP 1 intCountryID FROM tblSMCountry WHERE strCountry = 'United States')
	END
GO
	UPDATE tblSMEmailRecipient SET intEntityContactId = NULL WHERE intEntityContactId = -1
GO
	UPDATE tblSMDocumentMaintenanceMessage set strMessageOld = '<p>' + strMessage + '</p>'
GO
	PRINT N'UPDATE COMPANY LOCATION SUB LOCATION COUNTRY'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Update Sub Location Country - Company Location')
	BEGIN
		UPDATE SubLocation SET SubLocation.intCountryId = ZipCode.intCountryID
		FROM tblSMCompanyLocationSubLocation SubLocation
		INNER JOIN tblSMZipCode ZipCode ON SubLocation.strZipCode = ZipCode.strZipCode
		WHERE SubLocation.intCountryId IS NULL AND SubLocation.strZipCode <> ''
		
		PRINT N'ADD LOG TO tblSMMigrationLog'
		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Update Sub Location Country - Company Location', 'Update Sub Location Country - Company Location', GETDATE())
	END
GO