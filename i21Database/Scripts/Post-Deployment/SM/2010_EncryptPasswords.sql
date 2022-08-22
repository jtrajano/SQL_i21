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

PRINT('/*******************  END PASSWORD ENCRYPTION *******************/')

GO