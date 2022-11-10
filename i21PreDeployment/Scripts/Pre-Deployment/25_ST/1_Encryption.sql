﻿PRINT('')
PRINT('*** ST Encryption - Start ***')

----------------------------------------------------------------------------------------------------------------------------------
-- Start: Altering tables
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTCheckoutHeader' and COLUMN_NAME = 'strManagersPassword' and CHARACTER_MAXIMUM_LENGTH <> '-1') 
	BEGIN
		PRINT('Altering tblSTCheckoutHeader strManagersPassword')
			EXEC('
					ALTER TABLE tblSTCheckoutHeader 
					ALTER COLUMN strManagersPassword NVARCHAR(MAX) collate Latin1_General_CI_AS
			')
		PRINT('End Altering tblSTCheckoutHeader')
	END

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTGenerateVendorRebateHistory' and COLUMN_NAME = 'strPassword' and CHARACTER_MAXIMUM_LENGTH <> '-1') 
	BEGIN
		PRINT('Altering tblSTGenerateVendorRebateHistory strPassword')
			EXEC('
					ALTER TABLE tblSTGenerateVendorRebateHistory 
					ALTER COLUMN strPassword NVARCHAR(MAX) collate Latin1_General_CI_AS
			')
		PRINT('End Altering tblSTGenerateVendorRebateHistory')
	END

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTRegister' and COLUMN_NAME = 'strFTPPassword' and CHARACTER_MAXIMUM_LENGTH <> '-1') 
	BEGIN
		PRINT('Altering tblSTRegister strFTPPassword')
			EXEC('
					ALTER TABLE tblSTRegister 
					ALTER COLUMN strFTPPassword NVARCHAR(MAX) collate Latin1_General_CI_AS
			')
		PRINT('End Altering tblSTRegister')
	END

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTRegister' and COLUMN_NAME = 'strIrelyPassword' and CHARACTER_MAXIMUM_LENGTH <> '-1') 
	BEGIN
		PRINT('Altering tblSTRegister strIrelyPassword')
			EXEC('
					ALTER TABLE tblSTRegister 
					ALTER COLUMN strIrelyPassword NVARCHAR(MAX) collate Latin1_General_CI_AS
			')
		PRINT('End Altering tblSTRegister')
	END


IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTRegister' and COLUMN_NAME = 'strIrelyReEnterPassword' and CHARACTER_MAXIMUM_LENGTH <> '-1') 
	BEGIN
		PRINT('Altering tblSTRegister strIrelyReEnterPassword')
			EXEC('
					ALTER TABLE tblSTRegister 
					ALTER COLUMN strIrelyReEnterPassword NVARCHAR(MAX) collate Latin1_General_CI_AS
			')
		PRINT('End Altering tblSTRegister')
	END


----------------------------------------------------------------------------------------------------------------------------------
-- End: Altering tables
----------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------
-- Start: Encryption
----------------------------------------------------------------------------------------------------------------------------------

	IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTCheckoutHeader'  and COLUMN_NAME = 'strManagersPassword') 
	BEGIN
		PRINT('Start Encryption tblSTCheckoutHeader')
			EXEC('
					UPDATE tblSTCheckoutHeader SET strManagersPassword = dbo.fnAESEncryptASym(strManagersPassword) WHERE ISNULL(dbo.fnAESEncryptASym(strManagersPassword),'''')  <> '''' 
			')
		PRINT('End Encryption tblSTCheckoutHeader')	
	END

	IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTGenerateVendorRebateHistory'  and COLUMN_NAME = 'strPassword') 
	BEGIN
		PRINT('Start Encryption tblSTGenerateVendorRebateHistory')
			EXEC('
					UPDATE tblSTGenerateVendorRebateHistory SET strPassword = dbo.fnAESEncryptASym(strPassword) WHERE ISNULL(dbo.fnAESEncryptASym(strPassword),'''')  <> '''' 
			')
		PRINT('End Encryption tblSTGenerateVendorRebateHistory')
	END

	IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTRegister'  and COLUMN_NAME = 'strFTPPassword') 
	BEGIN
		PRINT('Start Encryption tblSTRegister strFTPPassword')
			EXEC('
					UPDATE tblSTRegister SET strFTPPassword = dbo.fnAESEncryptASym(strFTPPassword) WHERE ISNULL(dbo.fnAESEncryptASym(strFTPPassword),'''')  <> '''' 
			')
		PRINT('End Encryption tblSTRegister strFTPPassword')
	END

	IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTRegister'  and COLUMN_NAME = 'strIrelyPassword') 
	BEGIN
		PRINT('Start Encryption tblSTRegister strIrelyPassword')
			EXEC('
					UPDATE tblSTRegister SET strIrelyPassword = dbo.fnAESEncryptASym(strIrelyPassword) WHERE ISNULL(dbo.fnAESEncryptASym(strIrelyPassword),'''')  <> '''' 
			')
		PRINT('End Encryption tblSTRegister strIrelyPassword')
	END

	IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTRegister'  and COLUMN_NAME = 'strIrelyReEnterPassword') 
	BEGIN
		PRINT('Start Encryption tblSTRegister strIrelyReEnterPassword')
			EXEC('
					UPDATE tblSTRegister SET strIrelyReEnterPassword = dbo.fnAESEncryptASym(strIrelyReEnterPassword) WHERE ISNULL(dbo.fnAESEncryptASym(strIrelyReEnterPassword),'''')  <> '''' 
			')
		PRINT('End Encryption tblSTRegister strIrelyReEnterPassword')
	END
	
----------------------------------------------------------------------------------------------------------------------------------
-- End: Encryption
----------------------------------------------------------------------------------------------------------------------------------

PRINT('*** ST Encryption - End ***')
PRINT('')