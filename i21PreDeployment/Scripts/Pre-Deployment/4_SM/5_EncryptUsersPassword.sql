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

IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityCredential') 
 AND NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityCredential' AND COLUMN_NAME = 'ysnNotEncrypted')
BEGIN
  EXEC('
    ALTER TABLE tblEMEntityCredential
      ADD ysnNotEncrypted bit NOT NULL DEFAULT((1));
  ')
END

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityCredential' AND [COLUMN_NAME] = 'strPassword') 
BEGIN
  EXEC('
    ALTER TABLE [tblEMEntityCredential] ALTER COLUMN [strPassword] nvarchar(MAX) COLLATE Latin1_General_CI_AS
  ')
END

EXEC('
  OPEN SYMMETRIC KEY i21EncryptionSymKey
    DECRYPTION BY CERTIFICATE i21EncryptionCert
    WITH PASSWORD = ''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY=''
')

IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblEMEntityCredential' AND COLUMN_NAME = 'ysnNotEncrypted')
BEGIN

  EXEC('
    DECLARE @EncryptionTable TABLE (
      intEntityCredentialId INT,
      encrypted_data VARBINARY(128)
    )

    INSERT INTO @EncryptionTable
      SELECT intEntityCredentialId, EncryptByKey(Key_GUID(''i21EncryptionSymKey''), strPassword)
      FROM tblEMEntityCredential
      WHERE ysnNotEncrypted = 1

    UPDATE EntityCredential
    SET strPassword = CAST(N'''' AS XML).value(''xs:base64Binary(sql:column(''''Encrypt.encrypted_data''''))'', ''nvarchar(max)''), ysnNotEncrypted = 0
    FROM tblEMEntityCredential EntityCredential
    JOIN @EncryptionTable Encrypt on Encrypt.intEntityCredentialId = EntityCredential.intEntityCredentialId
    WHERE ysnNotEncrypted = 1
  ')

END

EXEC('CLOSE SYMMETRIC KEY i21EncryptionSymKey')
