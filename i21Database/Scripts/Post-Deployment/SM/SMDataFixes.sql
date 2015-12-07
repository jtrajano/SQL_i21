﻿GO
	IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblSMRecurringTransaction') AND name = 'intRecurringId')
	BEGIN
		EXEC ('
			UPDATE dbo.tblSMRecurringTransaction
			SET strResponsibleUser = CASE WHEN LEN(LTRIM(RTRIM(strResponsibleUser))) = 0 THEN strFullName ELSE strResponsibleUser END
			FROM dbo.tblSMRecurringTransaction
			INNER JOIN dbo.tblSMUserSecurity ON  dbo.tblSMRecurringTransaction.intUserId = dbo.tblSMUserSecurity.intEntityUserSecurityId
		')
	END
GO
	/* DELETE i21 Updates MENU'S DUPLICATE */
	DECLARE @UtilitiesParentMenuId INT
	SELECT @UtilitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Utilities' AND strModuleName = 'System Manager' AND intParentMenuID = 1
	IF EXISTS(SELECT strMenuName FROM tblSMMasterMenu WHERE strMenuName =  'i21 Updates' AND (SELECT COUNT(strMenuName) FROM tblSMMasterMenu WHERE strMenuName =  'i21 Updates') > 1)
	BEGIN
		DELETE FROM tblSMMasterMenu WHERE strMenuName = 'i21 Updates' AND strModuleName = 'Service Pack' AND intParentMenuID = @UtilitiesParentMenuId AND intMenuID NOT IN
		(
			SELECT TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'i21 Updates' AND strModuleName = 'Service Pack' AND intParentMenuID = @UtilitiesParentMenuId
		)
	END
GO
	/* DELETE Container MENU'S DUPLICATE */
	DECLARE @CommonInfoParentMenuId INT
	SELECT @CommonInfoParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager' AND intParentMenuID = 0

	IF EXISTS(SELECT strMenuName FROM tblSMMasterMenu WHERE strMenuName =  'Announcement Types' AND (SELECT COUNT(strMenuName) FROM tblSMMasterMenu WHERE strMenuName =  'Announcement Types') > 1)
	BEGIN
		DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Announcement Types' AND strModuleName = 'Help Desk' AND intMenuID NOT IN
		(
			SELECT TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Announcement Types' AND strModuleName = 'Help Desk'
		)
	END

	IF EXISTS(SELECT strMenuName FROM tblSMMasterMenu WHERE strMenuName =  'Maintenance' AND (SELECT COUNT(strMenuName) FROM tblSMMasterMenu WHERE strMenuName =  'Maintenance') > 1)
	BEGIN
		DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Help Desk' AND intMenuID NOT IN
		(
			SELECT TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Help Desk'
		)
	END

	IF EXISTS(SELECT strMenuName FROM tblSMMasterMenu WHERE strMenuName =  'Announcements' AND (SELECT COUNT(strMenuName) FROM tblSMMasterMenu WHERE strMenuName =  'Announcements') > 1)
	BEGIN
		DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Announcements' AND strModuleName = 'Help Desk' AND intParentMenuID = @CommonInfoParentMenuId AND intMenuID NOT IN
		(
			SELECT TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Announcements' AND strModuleName = 'Help Desk' AND intParentMenuID = @CommonInfoParentMenuId
		)
	END
GO

	/* SET A DEFAULT VALUE FOR TAX CODE RATE */
	UPDATE tblSMTaxCodeRate SET strCalculationMethod = 'Percentage' WHERE strCalculationMethod = ''

GO
	/* DELETE TAXABLE BY OTHER TAXES */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Delete Taxable By Other Taxes - Tax Class')
	BEGIN
		UPDATE tblSMTaxCode SET strTaxableByOtherTaxes = NULL
		
		PRINT N'ADD LOG TO tblMigrationLog'
		INSERT INTO tblMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Delete Taxable By Other Taxes - Tax Class', 'Delete Taxable By Other Taxes - Tax Class', GETDATE())
	END

GO

	/* MAKE NULL ALL ZERO VALUES TO NULL FOR intDefaultBlendProductionLocationId  AND intDefaultInboundDockDoorUnitId  IN tblSMCompanyLocation */
	UPDATE tblSMCompanyLocation SET intDefaultBlendProductionLocationId = NULL WHERE intDefaultBlendProductionLocationId = 0
	UPDATE tblSMCompanyLocation SET intDefaultInboundDockDoorUnitId = NULL WHERE intDefaultInboundDockDoorUnitId = 0

GO

	/* MAKE BILL TRANSACTION TYPE TO VOUCHER */
	UPDATE tblSMRecurringTransaction SET strTransactionType = 'Voucher' WHERE strTransactionType = 'Bill'
	UPDATE tblSMRecurringHistory SET strTransactionType = 'Voucher' WHERE strTransactionType = 'Bill'
GO
	/* DELETE EXCESS Sales Analysis Reports */
	DECLARE @AccountsReceivableParentMenuId INT
	SELECT @AccountsReceivableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0

	DECLARE @AccountsReceivableReportParentMenuId INT
	SELECT @AccountsReceivableReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

	DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Sales Analysis Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId


GO
	/* UPDATE Audit Log Icon from small-menu-maintenance to small-gear */
	UPDATE tblSMAuditLog 
	SET strJsonData = REPLACE(strJsonData, 'small-menu-maintenance', 'small-gear') 
	WHERE strJsonData LIKE '%small-menu-maintenance%'
GO
	/* DELETE Sales Analysis Reports MENU'S DUPLICATE */
	IF EXISTS(SELECT strMenuName FROM tblSMMasterMenu WHERE strMenuName =  'Sales Analysis Reports' AND (SELECT COUNT(strMenuName) FROM tblSMMasterMenu WHERE strMenuName =  'Sales Analysis Reports') > 1)
	BEGIN
		DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Sales Analysis Reports' AND strModuleName = 'Accounts Receivable' AND intMenuID NOT IN
		(
			SELECT TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales Analysis Reports' AND strModuleName = 'Accounts Receivable'
		)
	END
GO

	/* Update Search command in Master Menu to replace colon to ?searchCommand*/
	update tblSMMasterMenu
	set strCommand = REPLACE(strCommand, ':', '?searchCommand=')
	where strCommand like '%:%'
GO