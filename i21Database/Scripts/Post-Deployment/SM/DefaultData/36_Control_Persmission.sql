GO
	PRINT N'BEGIN INSERT DEFAULT CONTROL'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Insert Default Control Permission - btnDeleteLoc in Customer (Portal) - 1830')
	BEGIN
		DECLARE @entityCustomerId INT
		SELECT @entityCustomerId = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.EntityCustomer' AND strScreenName = 'My Company (Portal)'

		DECLARE @controlId INT
		SELECT @controlId = intControlId FROM tblSMControl WHERE intScreenId = @entityCustomerId AND strControlId = 'btnDeleteLoc'

		IF @controlId IS NOT NULL
		BEGIN
			INSERT INTO tblSMUserRoleControlPermission ([intUserRoleId],[intControlId],[strPermission])
			SELECT intUserRoleID, @controlId, 'Disable' 
			FROM tblSMUserRole 
			WHERE strRoleType NOT IN ('Administrator', 'User')
		END
		
		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Insert Default Control Permission - btnDeleteLoc in Customer (Portal) - 1830', 'Insert Default Control Permission - btnDeleteLoc in Customer (Portal) - 1830', GETDATE())
	END
GO
	PRINT N'END INSERT DEFAULT CONTROL'
GO