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