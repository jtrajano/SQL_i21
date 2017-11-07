GO
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.COLUMNS WHERE UPPER(TABLE_NAME) = 'TBLSMMASTERMENU')
	BEGIN
		PRINT N'Rename Receive Multiple Payment TO Receive Multiple Payments Menus'
		EXEC
		('
			UPDATE tblSMMasterMenu SET strMenuName = ''Receive Multiple Payments'', strDescription = ''Receive Multiple Payments'' WHERE strMenuName = ''Receive Multiple Payment'' AND strModuleName = ''Accounts Receivable''
		')

		PRINT N'Delete Receive Multiple Payments Duplicate Menus'
		EXEC
		('
			IF EXISTS(SELECT strMenuName FROM tblSMMasterMenu WHERE strMenuName =  ''Receive Multiple Payments'' AND (SELECT COUNT(strMenuName) FROM tblSMMasterMenu WHERE strMenuName =  ''Receive Multiple Payments'') > 1)
			BEGIN
				DELETE FROM tblSMMasterMenu WHERE strMenuName = ''Receive Multiple Payments'' AND strModuleName = ''Accounts Receivable'' AND intMenuID NOT IN
				(
					SELECT TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = ''Receive Multiple Payments'' AND strModuleName = ''Accounts Receivable''
				)
			END		
		')
	END
GO