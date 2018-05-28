GO
	IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRole WHERE strRoleType IN ('Portal Default'))
	BEGIN
		PRINT N'START ARRANGING PORTAL MENUS'
		UPDATE tblSMUserRole SET strName = 'Portal Admin', strDescription = 'Portal Admin', strRoleType = 'Portal Admin' WHERE intUserRoleID = 999

		DELETE FROM tblEMEntityToRole WHERE intEntityRoleId NOT IN (SELECT intEntityRoleId FROM tblEMEntityToContact WHERE intEntityRoleId IS NOT NULL)

		UPDATE a SET a.ysnPortalAdmin = b.ysnAdmin
		FROM [tblEMEntityToContact] a
			JOIN tblSMUserRole b
				ON a.intEntityRoleId = b.intUserRoleID
			JOIN tblEMEntity c
				ON a.intEntityId = c.intEntityId
			JOIN tblEMEntity d
				ON a.intEntityContactId = d.intEntityId
			LEFT JOIN [tblEMEntityCredential] e
				ON a.intEntityContactId = e.intEntityId
		UPDATE tblEMEntityToContact SET intEntityRoleId = 999 WHERE intEntityRoleId IS NOT NULL
		UPDATE tblEMEntityToRole SET intEntityRoleId = 999
		UPDATE tblSMUserRoleMenu SET ysnVisible = 1 WHERE intUserRoleId = 999

		DELETE FROM tblSMUserRole WHERE strRoleType IN ('Contact Admin', 'Contact')

		DECLARE @currentRow INT
		DECLARE @totalRows INT

		SET @currentRow = 1
		SELECT @totalRows = Count(*) FROM [tblSMUserRole] WHERE (strRoleType IN ('Portal Admin', 'Portal User') OR strRoleType IS NOT NULL)

		WHILE (@currentRow <= @totalRows)
		BEGIN
			Declare @roleId INT
			SELECT @roleId = intUserRoleID FROM (  
				SELECT ROW_NUMBER() OVER(ORDER BY intUserRoleID ASC) AS 'ROWID', *
				FROM [tblSMUserRole] WHERE (strRoleType IN ('Portal Admin', 'Portal User') OR strRoleType IS NOT NULL)
			) a
			WHERE ROWID = @currentRow

			PRINT N'Executing uspSMUpdateUserRoleMenus'
			Exec uspSMUpdateUserRoleMenus @roleId, 1, 0

			SET @currentRow = @currentRow + 1
		END
	
		EXEC uspSMIncreaseECConcurrency 0
	
		PRINT N'END ARRANGING PORTAL MENUS'
	END
GO