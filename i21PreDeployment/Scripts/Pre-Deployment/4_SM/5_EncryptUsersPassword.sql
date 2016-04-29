--If there is no master key, create one now. 
IF NOT EXISTS 
  (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
  CREATE MASTER KEY ENCRYPTION BY 
    PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY=';
GO

OPEN MASTER KEY
  DECRYPTION BY PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY=';
GO

IF NOT EXISTS
  (SELECT * FROM sys.certificates WHERE name = 'i21Certificate')
  CREATE CERTIFICATE i21Certificate
    WITH SUBJECT = 'i21 Certificate';
GO

IF NOT EXISTS
  (SELECT * FROM sys.symmetric_keys WHERE name = 'i21SymKey')
  CREATE SYMMETRIC KEY i21SymKey
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE i21Certificate;
GO

IF COL_LENGTH('tblEMEntityCredential', 'ysnNotEncrypted') IS NULL
  ALTER TABLE tblEMEntityCredential
    ADD ysnNotEncrypted bit NOT NULL DEFAULT((1));
GO

OPEN SYMMETRIC KEY i21SymKey
  DECRYPTION BY CERTIFICATE i21Certificate;
GO

DECLARE @EncryptionTable TABLE (
  intEntityCredentialId INT,
  encrypted_data VARBINARY(128)
)

INSERT INTO @EncryptionTable
  SELECT intEntityCredentialId, EncryptByKey(Key_GUID('i21SymKey'), strPassword)
  FROM tblEMEntityCredential
  WHERE ysnNotEncrypted = 1

UPDATE EntityCredential
SET strPassword = CAST(N'' AS XML).value('xs:base64Binary(sql:column(''Encrypt.encrypted_data''))','nvarchar(max)'),
ysnNotEncrypted = 0
FROM tblEMEntityCredential EntityCredential
join @EncryptionTable Encrypt on Encrypt.intEntityCredentialId = EntityCredential.intEntityCredentialId
WHERE ysnNotEncrypted = 1;
GO