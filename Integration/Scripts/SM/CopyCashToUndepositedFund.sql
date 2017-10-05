GO
	/* COPYING CASH ACCOUNT TO UNDEPOSITED FUND */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Copying Cash Account to Undeposited Fund (System Manager)')
	BEGIN
		PRINT 'Copying Cash Account to Undeposited Fund (System Manager)'

		UPDATE t SET intUndepositedFundsId = intCashAccount
		FROM tblSMCompanyLocation t

		PRINT N'ADD LOG TO tblMigrationLog'
		INSERT INTO tblMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Copying Cash Account to Undeposited Fund (System Manager)', 'Copying Cash Account to Undeposited Fund (System Manager)', GETDATE())
	END
GO