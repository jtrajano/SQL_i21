GO
	PRINT N'START TEMPORARY DECRYPT PASSWORDS'
	BEGIN
		
		UPDATE	tblEMEntitySMTPInformation
		SET		strPassword = dbo.fnAESDecryptASym(strPassword)
		WHERE	dbo.fnAESDecryptASym(strPassword) IS NOT NULL

		UPDATE	tblSMInterCompany
		SET		strPassword = dbo.fnAESDecryptASym(strPassword)
		WHERE	dbo.fnAESDecryptASym(strPassword) IS NOT NULL

		UPDATE	tblRMConnection
		SET		strPassword = dbo.fnAESDecryptASym(strPassword)
		WHERE	dbo.fnAESDecryptASym(strPassword) IS NOT NULL

	END
	PRINT N'END TEMPORARY DECRYPT PASSWORDS'
GO
