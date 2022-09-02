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

UPDATE		tblSMCompanyPreference
SET			strSMTPPassword = dbo.fnAESEncryptASym(ISNULL(strSMTPPassword, ''))
WHERE		dbo.fnAESDecryptASym(strSMTPPassword) IS NULL

PRINT('/*******************  END PASSWORD ENCRYPTION *******************/')

GO