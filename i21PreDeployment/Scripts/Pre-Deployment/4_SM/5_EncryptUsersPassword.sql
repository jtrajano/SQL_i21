IF NOT EXISTS
  (SELECT * FROM sys.certificates WHERE name = 'i21EncryptionCert')
  CREATE CERTIFICATE i21EncryptionCert
    ENCRYPTION BY PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='
    WITH SUBJECT = 'i21 Encryption Certificate'
GO

IF NOT EXISTS
  (SELECT * FROM sys.symmetric_keys WHERE name = 'i21EncryptionSymKey')
  CREATE SYMMETRIC KEY i21EncryptionSymKey
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE i21EncryptionCert
GO

IF COL_LENGTH('tblEMEntityCredential', 'ysnNotEncrypted') IS NULL
  ALTER TABLE tblEMEntityCredential
    ADD ysnNotEncrypted bit NOT NULL DEFAULT((1));
GO

OPEN SYMMETRIC KEY i21EncryptionSymKey
  DECRYPTION BY CERTIFICATE i21EncryptionCert
  WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

DECLARE @EncryptionTable TABLE (
  intEntityCredentialId INT,
  encrypted_data VARBINARY(128)
)

INSERT INTO @EncryptionTable
  SELECT intEntityCredentialId, EncryptByKey(Key_GUID('i21EncryptionSymKey'), strPassword)
  FROM tblEMEntityCredential
  WHERE ysnNotEncrypted = 1

UPDATE EntityCredential
SET strPassword = CAST(N'' AS XML).value('xs:base64Binary(sql:column(''Encrypt.encrypted_data''))','nvarchar(max)'),
ysnNotEncrypted = 0
FROM tblEMEntityCredential EntityCredential
join @EncryptionTable Encrypt on Encrypt.intEntityCredentialId = EntityCredential.intEntityCredentialId
WHERE ysnNotEncrypted = 1;
GO

CLOSE SYMMETRIC KEY i21EncryptionSymKey 
GO