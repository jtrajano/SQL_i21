IF NOT EXISTS (SELECT TOP 1 1 FROM sys.certificates WHERE name = 'i21EncryptionCert')
BEGIN
  EXEC('
    CREATE CERTIFICATE i21EncryptionCert
      ENCRYPTION BY PASSWORD = ''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY=''
      WITH SUBJECT = ''i21 Encryption Certificate''
  ')
END

IF NOT EXISTS (SELECT TOP 1 1 FROM sys.symmetric_keys WHERE name = 'i21EncryptionSymKey')
BEGIN
  EXEC('
    CREATE SYMMETRIC KEY i21EncryptionSymKey
      WITH ALGORITHM = AES_256
      ENCRYPTION BY CERTIFICATE i21EncryptionCert
  ')
END

IF NOT EXISTS (SELECT TOP 1 1 FROM sys.asymmetric_keys WHERE name = 'i21EncryptionASymKeyPwd')
BEGIN
  EXEC('
    CREATE ASYMMETRIC KEY i21EncryptionASymKeyPwd
	WITH ALGORITHM = RSA_2048
	ENCRYPTION BY PASSWORD =  ''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY=''
  ')
END

IF NOT EXISTS (SELECT TOP 1 1 FROM sys.symmetric_keys WHERE name = 'i21EncryptionSymKeyByASym')
BEGIN
  EXEC('
    CREATE SYMMETRIC KEY i21EncryptionSymKeyByASym
	WITH ALGORITHM = AES_256
	ENCRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd
  ')
END

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityCredential' AND [COLUMN_NAME] = 'strPassword')
BEGIN
  EXEC('
    ALTER TABLE [tblEMEntityCredential] ALTER COLUMN [strPassword] nvarchar(MAX) COLLATE Latin1_General_CI_AS
  ')
END

IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblEMEntityCredential')
  AND NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblEMEntityCredential' AND COLUMN_NAME = 'ysnNotEncrypted')
  AND EXISTS (SELECT TOP 1 1 FROM sys.certificates WHERE name = 'iRelyi21Certificate')
BEGIN
  EXEC('
    ALTER TABLE tblEMEntityCredential
      ADD ysnNotEncrypted bit NOT NULL DEFAULT((1));
  ')

  EXEC('
    PRINT(''*** Backing up tblEMEntityCredential for certificate encryption ***'')
    SELECT * INTO tblEMEntityCredentialBackupForCertEncryption FROM tblEMEntityCredential

    DECLARE @EncryptionTable TABLE (
      intEntityCredentialId INT,
      strPassword VARBINARY(256)
    )

    PRINT(''*** Encrypting password using certificate ***'')
    INSERT INTO @EncryptionTable
      SELECT intEntityCredentialId, ENCRYPTBYCERT(CERT_ID(''iRelyi21Certificate''), CAST(strPassword AS varchar(max)))
      FROM tblEMEntityCredential

    PRINT(''*** Saving certificate encrypted password ***'')
    UPDATE EntityCredential
      SET strPassword = CAST(N'''' AS XML).value(''xs:base64Binary(sql:column(''''Encrypt.strPassword''''))'', ''varchar(max)''), ysnNotEncrypted = 0
      FROM tblEMEntityCredential AS EntityCredential
      JOIN @EncryptionTable AS Encrypt on Encrypt.intEntityCredentialId = EntityCredential.intEntityCredentialId

    INSERT INTO tblEMEntityPreferences (strPreference, strValue, intConcurrencyId) VALUES (''SM Password encrypted using certificate'', ''1'', 0)
  ')
END
