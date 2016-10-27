PRINT '*** ----  Checking Encrypting Account Number  ---- ***'

IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Encrypt EFT Account Number')
BEGIN

PRINT '*** ----  Start Encrypting Account Number  ---- ***'

	OPEN SYMMETRIC KEY i21EncryptionSymKey
	DECRYPTION BY CERTIFICATE i21EncryptionCert
	WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

	UPDATE tblEMEntityEFTInformation SET strAccountNumber = dbo.fnAESEncrypt(strAccountNumber)
	
	CLOSE SYMMETRIC KEY i21EncryptionSymKey

INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Encrypt EFT Account Number', 1)

PRINT '*** ----  End Encrypting Account Number ---- ***'

END