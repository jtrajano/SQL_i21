IF EXISTS (SELECT TOP 1 1 FROM sys.certificates WHERE name = 'iRelyi21Certificate')
  EXEC('DROP CERTIFICATE iRelyi21Certificate')

IF EXISTS (SELECT TOP 1 1 FROM sys.symmetric_keys WHERE name = 'i21EncryptionSymKey')
  EXEC('DROP SYMMETRIC KEY i21EncryptionSymKey')

IF EXISTS (SELECT TOP 1 1 FROM sys.certificates WHERE name = 'i21EncryptionCert')
  EXEC('DROP CERTIFICATE i21EncryptionCert')
  
IF EXISTS (SELECT TOP 1 1 FROM sys.symmetric_keys WHERE name = 'i21EncryptionSymKeyByASym')
  EXEC('DROP SYMMETRIC KEY i21EncryptionSymKeyByASym')
  
IF EXISTS (SELECT TOP 1 1 FROM sys.asymmetric_keys WHERE name = 'i21EncryptionASymKeyPwd')
  EXEC('DROP ASYMMETRIC KEY i21EncryptionASymKeyPwd')
