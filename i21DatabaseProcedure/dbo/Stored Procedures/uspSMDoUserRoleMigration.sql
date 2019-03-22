CREATE PROCEDURE [dbo].[uspSMDoUserRoleMigration]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
        DECLARE @currentRow INT
	DECLARE @totalRows INT

	SET @currentRow = 1
	SELECT @totalRows = Count(*) FROM [dbo].[tblSMUserRole] a INNER JOIN [dbo].[tblSMInterDatabaseUserRole] b ON a.strName = b.strName
	print 'No of Rows ' +  cast(@totalRows as nvarchar)
	WHILE (@currentRow <= @totalRows)
	BEGIN

		Declare @targetUserRoleId INT
		Declare @fromUserRoleId INT	
		SELECT @targetUserRoleId = intToUserRoleId, @fromUserRoleId = intFromUserRoleId 
		FROM (SELECT ROW_NUMBER() OVER(ORDER BY a.intUserRoleID ASC) AS 'ROWID', a.intUserRoleID as intToUserRoleId, b.intUserRoleID as intFromUserRoleId
			FROM [dbo].[tblSMUserRole] a INNER JOIN [dbo].[tblSMInterDatabaseUserRole] b ON a.strName = b.strName) c
		WHERE ROWID = @currentRow

		UPDATE targetDB SET targetDB.ysnVisible = sourceDB.ysnVisible
		FROM [dbo].[tblSMUserRoleMenu] targetDB
		INNER JOIN 
		(

			SELECT toDB.intMenuID, fromDB.ysnVisible
			FROM 
					(
						SELECT intUserRoleId														
							,RoleMenu.ysnVisible as ysnVisible							
							,REPLACE(strMenuName, ' (Portal)', '') as strMenuName
							,strModuleName
							,RoleMenu.intConcurrencyId
						FROM tblSMInterDatabaseUserRoleMenu RoleMenu
						LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
						WHERE ISNULL(ysnAvailable, 1) = 1 AND (ysnIsLegacy = 0 OR ((SELECT COUNT(*) FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1) = 1 AND ysnIsLegacy = 1))

				)fromDB
			INNER JOIN [dbo].[tblSMMasterMenu] toDB
				ON fromDB.strMenuName = toDB.strMenuName AND fromDB.strModuleName = toDB.strModuleName
			WHERE fromDB.intUserRoleId = @fromUserRoleId

		) sourceDB ON sourceDB.intMenuID = targetDB.intMenuId
		WHERE targetDB.intUserRoleId = @targetUserRoleId

		DELETE FROM [dbo].[tblSMUserRoleScreenPermission] WHERE intUserRoleId = @targetUserRoleId
		DELETE FROM [dbo].[tblSMUserRoleControlPermission] WHERE intUserRoleId = @targetUserRoleId

		INSERT [dbo].[tblSMUserRoleScreenPermission] ([intUserRoleId], [intScreenId], [strPermission])
		SELECT @targetUserRoleId, targetDB.intScreenId, sourceDB.strPermission
		FROM [dbo].[tblSMScreen] targetDB
		INNER JOIN
		(
			SELECT strScreenName, strNamespace, strModule, strPermission, fromDB_SP.intScreenId
			FROM [dbo].[tblSMInterDatabaseUserRoleScreenPermission] fromDB_SP
			INNER JOIN [dbo].[tblSMInterDatabaseScreen] fromDB
				ON fromDB_SP.intScreenId = fromDB.intScreenId
			WHERE fromDB_SP.intUserRoleId = @fromUserRoleId
		) sourceDB
		ON sourceDB.strScreenName = targetDB.strScreenName AND sourceDB.strNamespace = targetDB.strNamespace AND sourceDB.strModule = targetDB.strModule

		INSERT INTO [dbo].[tblSMUserRoleControlPermission]([intUserRoleId],[intControlId],[strPermission],[strLabel],[strDefaultValue],[ysnRequired])
		SELECT @targetUserRoleId,e.intControlId,strPermission,strLabel,strDefaultValue,ysnRequired
		FROM [dbo].[tblSMInterDatabaseUserRoleControlPermission] a
		INNER JOIN [dbo].[tblSMInterDatabaseControl] b
			ON a.intControlId = b.intControlId
		INNER JOIN [dbo].[tblSMInterDatabaseScreen] c
			ON b.intScreenId = c.intScreenId
		INNER JOIN [dbo].[tblSMScreen] d
			ON c.strScreenName = d.strScreenName and c.strNamespace = d.strNamespace and c.strModule = d.strModule
		CROSS APPLY (SELECT * FROM [dbo].[tblSMControl] WHERE intScreenId = d.intScreenId and strControlId = b.strControlId and strControlName = b.strControlName and strControlType = b.strControlType) e
		WHERE a.intUserRoleId = @fromUserRoleId

		INSERT tblSMUserRoleSubRole(intUserRoleId, intSubRoleId)
		SELECT @targetUserRoleId, b.intUserRoleId FROM [dbo].[tblSMInterDatabaseUserRoleSubRole] a
		INNER JOIN 
		(
			SELECT ba.intUserRoleID as intUserRoleId,ba.strName,ba.strDescription,ba.strMenu,ba.strMenuPermission,ba.strForm,ba.strRoleType,ba.ysnAdmin
			FROM [dbo].[tblSMUserRole] ba 
				INNER JOIN [dbo].[tblSMInterDatabaseUserRole] bb ON ba.strName = bb.strName
		) b ON a.intSubRoleId = b.intUserRoleId
		WHERE a.intUserRoleId = @fromUserRoleId

	SET @currentRow = @currentRow + 1
	END


	delete from tblSMInterDatabaseUserRole
	delete from tblSMInterDatabaseUserRoleMenu
	delete from tblSMInterDatabaseUserRoleScreenPermission
	delete from tblSMInterDatabaseUserRoleControlPermission
	delete from tblSMInterDatabaseScreen
	delete from tblSMInterDatabaseControl
	delete from tblSMInterDatabaseUserRoleSubRole

    UPDATE tblSMCompanySetup set ysnDoingMigration = 0, dtmMigrationStarted = null
END


