IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblSMRecurringTransaction') AND name = 'intRecurringId')
BEGIN
	EXEC ('
		UPDATE dbo.tblSMRecurringTransaction
		SET strResponsibleUser = CASE WHEN LEN(LTRIM(RTRIM(strResponsibleUser))) = 0 THEN strFullName ELSE strResponsibleUser END
		FROM dbo.tblSMRecurringTransaction
		INNER JOIN dbo.tblSMUserSecurity ON  dbo.tblSMRecurringTransaction.intUserId = dbo.tblSMUserSecurity.intUserSecurityID
	')
END