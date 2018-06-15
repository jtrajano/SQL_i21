GO
	PRINT N'BEGIN INSERT DEFAULT CONTROL'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Insert Default Control Permission - btnDeleteLoc in Customer (Portal) - 1830')
	BEGIN
		DECLARE @entityCustomerId INT
		SELECT @entityCustomerId = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.EntityCustomer' AND strScreenName = 'My Company (Portal)'

		DECLARE @btnDeleteLocId INT
		SELECT @btnDeleteLocId = intControlId FROM tblSMControl WHERE intScreenId = @entityCustomerId AND strControlId = 'btnDeleteLoc'

		IF @btnDeleteLocId IS NOT NULL
		BEGIN
			INSERT INTO tblSMUserRoleControlPermission ([intUserRoleId],[intControlId],[strPermission])
			SELECT intUserRoleID, @btnDeleteLocId, 'Disable' 
			FROM tblSMUserRole 
			WHERE strRoleType NOT IN ('Administrator', 'User')
		END
		
		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Insert Default Control Permission - btnDeleteLoc in Customer (Portal) - 1830', 'Insert Default Control Permission - btnDeleteLoc in Customer (Portal) - 1830', GETDATE())
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Insert Default Control Permission - txtVendorAccountNo in Vendors - 1830')
	BEGIN
		DECLARE @entityVendorId INT
		SELECT @entityVendorId = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.EntityVendor' AND strScreenName = 'Vendors'

		DECLARE @txtVendorAccountNoId INT
		SELECT @txtVendorAccountNoId = intControlId FROM tblSMControl WHERE intScreenId = @entityVendorId AND strControlId = 'txtVendorAccountNo'

		IF @txtVendorAccountNoId IS NOT NULL
		BEGIN
			INSERT INTO tblSMUserRoleControlPermission ([intUserRoleId],[intControlId],[strPermission], [ysnRequired])
			SELECT intUserRoleID, @txtVendorAccountNoId, 'Editable', 1
			FROM tblSMUserRole 
			WHERE strRoleType IN ('Administrator', 'User')
		END
		
		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Insert Default Control Permission - txtVendorAccountNo in Vendors - 1830', 'Insert Default Control Permission - txtVendorAccountNo in Vendors - 1830', GETDATE())
	END
GO
	PRINT N'END INSERT DEFAULT CONTROL'
GO