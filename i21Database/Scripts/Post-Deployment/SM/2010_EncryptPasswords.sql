GO
PRINT('/*******************  BEGIN PASSWORD ENCRYPTION *******************/')

UPDATE		tblEMEntitySMTPInformation
SET			strPassword = dbo.fnAESEncryptASym(strPassword),
			ysnIsPasswordEncrypted = 1
WHERE		ysnIsPasswordEncrypted = 0

UPDATE		tblSMInterCompany
SET			strPassword = dbo.fnAESEncryptASym(strPassword),
			ysnIsPasswordEncrypted = 1
WHERE		ysnIsPasswordEncrypted = 0

UPDATE		tblRMConnection
SET			strPassword = dbo.fnAESEncryptASym(ISNULL(strPassword, ''))
WHERE		dbo.fnAESDecryptASym(strPassword) IS NULL


PRINT('/*******************  END PASSWORD ENCRYPTION *******************/')

GO