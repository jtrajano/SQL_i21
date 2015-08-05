GO
	IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblSMRecurringTransaction') AND name = 'intRecurringId')
	BEGIN
		EXEC ('
			UPDATE dbo.tblSMRecurringTransaction
			SET strResponsibleUser = CASE WHEN LEN(LTRIM(RTRIM(strResponsibleUser))) = 0 THEN strFullName ELSE strResponsibleUser END
			FROM dbo.tblSMRecurringTransaction
			INNER JOIN dbo.tblSMUserSecurity ON  dbo.tblSMRecurringTransaction.intUserId = dbo.tblSMUserSecurity.intUserSecurityID
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