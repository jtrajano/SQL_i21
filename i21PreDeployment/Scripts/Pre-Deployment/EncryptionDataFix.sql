/*
 Encryption data fix for EM and CM.
*/

IF EXISTS (SELECT TOP 1 1 FROM sysobjects WHERE id = object_id(N'[dbo].[uspCreateCertificate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  AND NOT EXISTS (SELECT TOP 1 1 FROM sys.certificates WHERE name = 'iRelyi21Certificate')
BEGIN
  EXEC('[dbo].[uspCreateCertificate]')
END

IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblEMEntityPreferences')
  AND EXISTS (SELECT TOP 1 1 FROM sys.certificates WHERE name = 'iRelyi21Certificate')
BEGIN
  EXEC('
    OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
      DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd
      WITH PASSWORD = ''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY=''
  ')

  IF EXISTS (SELECT TOP 1 1 FROM tblEMEntityPreferences WHERE strPreference = 'EM change use encryption')
    AND NOT EXISTS (SELECT TOP 1 1 FROM tblEMEntityPreferences WHERE strPreference = 'EM Password re-encryption using certificate')
  BEGIN
    -- Password encryption - START
    EXEC('
      PRINT(''*** Backing up tblEMEntityCredential for certificate encryption ***'')
      IF NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE [TABLE_NAME] = ''tblEMEntityCredentialBackupForCertEncryption'')
      BEGIN
        SELECT * INTO tblEMEntityCredentialBackupForCertEncryption FROM tblEMEntityCredential
      END

      DECLARE @DecryptionTable TABLE (
        intEntityCredentialId INT,
        strPassword NVARCHAR(MAX)
      )

      DECLARE @EncryptionTable TABLE (
        intEntityCredentialId INT,
        strPassword VARBINARY(256)
      )

      PRINT(''*** Decrypting password (asymmetric) ***'')
      INSERT INTO @DecryptionTable
        SELECT intEntityCredentialId, CONVERT(NVARCHAR(MAX), CAST(N'''' as XML).value(''xs:base64Binary(sql:column(''''strPassword''''))'', ''varbinary(256)''))
        FROM tblEMEntityCredential

      PRINT(''*** Encrypting password using certificate ***'')
      INSERT INTO @EncryptionTable
        SELECT intEntityCredentialId, ENCRYPTBYCERT(CERT_ID(''iRelyi21Certificate''), CONVERT(VARCHAR(MAX), DECRYPTBYKEYAUTOASYMKEY(ASYMKEY_ID(''i21EncryptionASymKeyPwd''), N''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='', strPassword)))
        FROM @DecryptionTable

      PRINT(''*** Saving certificate encrypted password ***'')
      UPDATE EntityCredential
        SET strPassword = CAST(N'''' AS XML).value(''xs:base64Binary(sql:column(''''Encrypt.strPassword''''))'', ''varchar(max)''), ysnNotEncrypted = 0
        FROM tblEMEntityCredential AS EntityCredential
        JOIN @EncryptionTable AS Encrypt on Encrypt.intEntityCredentialId = EntityCredential.intEntityCredentialId

      INSERT INTO tblEMEntityPreferences (strPreference, strValue, intConcurrencyId) VALUES (''EM Password re-encryption using certificate'', ''1'', 0)
    ')
    -- Password encryption - END

    -- EXEC('DELETE tblEMEntityPreferences WHERE strPreference = ''EM change use encryption''')
  END

  IF EXISTS (SELECT TOP 1 1 FROM tblEMEntityPreferences WHERE strPreference = 'EM change use encryption')
    AND NOT EXISTS (SELECT TOP 1 1 FROM tblEMEntityPreferences WHERE strPreference = 'EM Account number re-encryption using certificate')
  BEGIN
    -- AccountNumber encryption - START
    EXEC('
      PRINT(''*** Backing up tblEMEntityEFTInformation for certificate encryption ***'')
      IF NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE [TABLE_NAME] = ''tblEMEntityEFTInformationBackupForCertEncryption'')
      BEGIN
        SELECT * INTO tblEMEntityEFTInformationBackupForCertEncryption from tblEMEntityEFTInformation
      END

      DECLARE @DecryptionTable TABLE (
        intEntityEFTInfoId INT,
        strAccountNumber NVARCHAR(MAX)
      )

      DECLARE @EncryptionTable TABLE (
        intEntityEFTInfoId INT,
        strAccountNumber VARBINARY(256)
      )

      PRINT(''*** Decrypting account number (asymmetric) ***'')
      INSERT INTO @DecryptionTable
        SELECT intEntityEFTInfoId, CONVERT(NVARCHAR(MAX), CAST(N'''' as XML).value(''xs:base64Binary(sql:column(''''strAccountNumber''''))'', ''varbinary(256)''))
        FROM tblEMEntityEFTInformation

      PRINT(''*** Encrypting account number using certificate ***'')
      INSERT INTO @EncryptionTable
        SELECT intEntityEFTInfoId, ENCRYPTBYCERT(CERT_ID(''iRelyi21Certificate''), CONVERT(VARCHAR(MAX), DECRYPTBYKEYAUTOASYMKEY(ASYMKEY_ID(''i21EncryptionASymKeyPwd''), N''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='', strAccountNumber)))
        FROM @DecryptionTable

      PRINT(''*** Saving certificate encrypted account number ***'')
      UPDATE EFTInfo
        SET strAccountNumber = CAST(N'''' AS XML).value(''xs:base64Binary(sql:column(''''Encrypt.strAccountNumber''''))'', ''varchar(max)'')
        FROM tblEMEntityEFTInformation AS EFTInfo
        JOIN @EncryptionTable AS Encrypt on Encrypt.intEntityEFTInfoId = EFTInfo.intEntityEFTInfoId

      INSERT INTO tblEMEntityPreferences (strPreference, strValue, intConcurrencyId) VALUES (''EM Account number re-encryption using certificate'', ''1'', 0)
    ')
    -- AccountNumber encryption - END
  END

  IF EXISTS (SELECT TOP 1 1 FROM tblEMEntityPreferences WHERE strPreference = 'CM Encrypt tblCMBank.strRTN')
    AND NOT EXISTS (SELECT TOP 1 1 FROM tblEMEntityPreferences WHERE strPreference = 'CM tblCMBank RTN re-encryption using certificate')
  BEGIN
    EXEC('
      PRINT(''*** Backing up tblCMBank for certificate encryption ***'')
      IF NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''tblCMBankBackupForCertEncryption'')
      BEGIN
        SELECT * INTO tblCMBankBackupForCertEncryption FROM tblCMBank
      END

      PRINT(''*** Disabling tblCMBank triggers ***'')
      ALTER TABLE tblCMBank DISABLE TRIGGER trgInsteadOfInsertCMBank
      ALTER TABLE tblCMBank DISABLE TRIGGER trgInsteadOfUpdateCMBank

      DECLARE @DecryptionTable TABLE (
        intBankId INT,
        strRTN NVARCHAR(MAX)
      )

      DECLARE @EncryptionTable TABLE (
        intBankId INT,
        strRTN VARBINARY(256)
      )

      PRINT(''*** Decrypting RTN (asymmetric) ***'')
      INSERT INTO @DecryptionTable
        SELECT intBankId, CONVERT(NVARCHAR(MAX), CAST(N'''' as XML).value(''xs:base64Binary(sql:column(''''strRTN''''))'', ''varbinary(256)''))
        FROM tblCMBank

      PRINT(''*** Encrypting RTN using certificate ***'')
      INSERT INTO @EncryptionTable
        SELECT intBankId, ENCRYPTBYCERT(CERT_ID(''iRelyi21Certificate''), CONVERT(VARCHAR(MAX), DECRYPTBYKEYAUTOASYMKEY(ASYMKEY_ID(''i21EncryptionASymKeyPwd''), N''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='', strRTN)))
        FROM @DecryptionTable

      PRINT(''*** Saving certificate encrypted RTN ***'')
      UPDATE CMBank
        SET strRTN = CAST(N'''' AS XML).value(''xs:base64Binary(sql:column(''''Encrypt.strRTN''''))'', ''varchar(max)'')
        FROM tblCMBank AS CMBank
        JOIN @EncryptionTable AS Encrypt on Encrypt.intBankId = CMBank.intBankId

      PRINT(''*** Enabling tblCMBank triggers ***'')
      ALTER TABLE tblCMBank ENABLE TRIGGER trgInsteadOfInsertCMBank
      ALTER TABLE tblCMBank ENABLE TRIGGER trgInsteadOfUpdateCMBank

      INSERT INTO tblEMEntityPreferences (strPreference, strValue, intConcurrencyId) VALUES (''CM tblCMBank RTN re-encryption using certificate'', ''1'', 0)
    ')
  END

  IF EXISTS (SELECT TOP 1 1 FROM tblEMEntityPreferences WHERE strPreference = 'CM Encrypt tblCMBankAccount.strBankAccountNo')
    AND NOT EXISTS (SELECT TOP 1 1 FROM tblEMEntityPreferences WHERE strPreference = 'CM BankAccountNo re-encryption using certificate')
  BEGIN
    EXEC('
      PRINT(''*** Backing up tblCMBankAccount for certificate encryption ***'')
      IF NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''tblCMBankAccountBackupForCertEncryption'')
      BEGIN
        SELECT * INTO tblCMBankAccountBackupForCertEncryption FROM tblCMBankAccount
      END

      DECLARE @DecryptionTable TABLE (
        intBankAccountId INT,
        strBankAccountNo NVARCHAR(MAX)
      )

      DECLARE @EncryptionTable TABLE (
        intBankAccountId INT,
        strBankAccountNo VARBINARY(256)
      )

      PRINT(''*** Decrypting BankAccountNo (asymmetric) ***'')
      INSERT INTO @DecryptionTable
        SELECT intBankAccountId, CONVERT(NVARCHAR(MAX), CAST(N'''' as XML).value(''xs:base64Binary(sql:column(''''strBankAccountNo''''))'', ''varbinary(256)''))
        FROM tblCMBankAccount

      PRINT(''*** Encrypting BankAccountNo using certificate ***'')
      INSERT INTO @EncryptionTable
        SELECT intBankAccountId, ENCRYPTBYCERT(CERT_ID(''iRelyi21Certificate''), CONVERT(VARCHAR(MAX), DECRYPTBYKEYAUTOASYMKEY(ASYMKEY_ID(''i21EncryptionASymKeyPwd''), N''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='', strBankAccountNo)))
        FROM @DecryptionTable

      PRINT(''*** Saving certificate encrypted BankAccountNo ***'')
      UPDATE CMBankAccount
        SET strBankAccountNo = CAST(N'''' AS XML).value(''xs:base64Binary(sql:column(''''Encrypt.strBankAccountNo''''))'', ''varchar(max)'')
        FROM tblCMBankAccount AS CMBankAccount
        JOIN @EncryptionTable AS Encrypt on Encrypt.intBankAccountId = CMBankAccount.intBankAccountId

      INSERT INTO tblEMEntityPreferences (strPreference, strValue, intConcurrencyId) VALUES (''CM BankAccountNo re-encryption using certificate'', ''1'', 0)
    ')
  END

  IF EXISTS (SELECT TOP 1 1 FROM tblEMEntityPreferences WHERE strPreference = 'CM Encrypt tblCMBankAccount.strRTN')
    AND NOT EXISTS (SELECT TOP 1 1 FROM tblEMEntityPreferences WHERE strPreference = 'CM tblCMBankAccount RTN re-encryption using certificate')
  BEGIN
    EXEC('
      UPDATE tblCMBankAccount
        SET strRTN = Bank.strRTN
        FROM tblCMBank AS Bank
        WHERE tblCMBankAccount.intBankId = Bank.intBankId

      INSERT INTO tblEMEntityPreferences (strPreference, strValue, intConcurrencyId) VALUES (''CM tblCMBankAccount RTN re-encryption using certificate'', ''1'', 0)
    ')
  END

  IF EXISTS (SELECT TOP 1 1 FROM tblEMEntityPreferences WHERE strPreference = 'CM Encrypt tblCMBankAccount.strMICRBankAccountNo')
    AND NOT EXISTS (SELECT TOP 1 1 FROM tblEMEntityPreferences WHERE strPreference = 'CM tblCMBankAccount MICRBankAccountNo re-encryption using certificate')
  BEGIN
    EXEC('
      PRINT(''*** Backing up tblCMBankAccount for certificate encryption ***'')
      IF NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''tblCMBankAccountBackupForCertEncryption'')
      BEGIN
        SELECT * INTO tblCMBankAccountBackupForCertEncryption FROM tblCMBankAccount
      END

      DECLARE @DecryptionTable TABLE (
        intBankAccountId INT,
        strMICRBankAccountNo NVARCHAR(MAX)
      )

      DECLARE @EncryptionTable TABLE (
        intBankAccountId INT,
        strMICRBankAccountNo VARBINARY(256)
      )

      PRINT(''*** Decrypting MICRBankAccountNo (asymmetric) ***'')
      INSERT INTO @DecryptionTable
        SELECT intBankAccountId, CONVERT(NVARCHAR(MAX), CAST(N'''' as XML).value(''xs:base64Binary(sql:column(''''strMICRBankAccountNo''''))'', ''varbinary(256)''))
        FROM tblCMBankAccount

      PRINT(''*** Encrypting MICRBankAccountNo using certificate ***'')
      INSERT INTO @EncryptionTable
        SELECT intBankAccountId, ENCRYPTBYCERT(CERT_ID(''iRelyi21Certificate''), CONVERT(VARCHAR(MAX), DECRYPTBYKEYAUTOASYMKEY(ASYMKEY_ID(''i21EncryptionASymKeyPwd''), N''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='', strMICRBankAccountNo)))
        FROM @DecryptionTable

      PRINT(''*** Saving certificate encrypted MICRBankAccountNo ***'')
      UPDATE CMBankAccount
        SET strMICRBankAccountNo = CAST(N'''' AS XML).value(''xs:base64Binary(sql:column(''''Encrypt.strMICRBankAccountNo''''))'', ''varchar(max)'')
        FROM tblCMBankAccount AS CMBankAccount
        JOIN @EncryptionTable AS Encrypt on Encrypt.intBankAccountId = CMBankAccount.intBankAccountId

      INSERT INTO tblEMEntityPreferences (strPreference, strValue, intConcurrencyId) VALUES (''CM tblCMBankAccount MICRBankAccountNo re-encryption using certificate'', ''1'', 0)
    ')
  END

  IF EXISTS (SELECT TOP 1 1 FROM tblEMEntityPreferences WHERE strPreference = 'CM Encrypt tblCMBankAccount.strMICRRoutingNo')
    AND NOT EXISTS (SELECT TOP 1 1 FROM tblEMEntityPreferences WHERE strPreference = 'CM tblCMBankAccount MICRRoutingNo re-encryption using certificate')
  BEGIN
    EXEC('
      PRINT(''*** Backing up tblCMBankAccount for certificate encryption ***'')
      IF NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''tblCMBankAccountBackupForCertEncryption'')
      BEGIN
        SELECT * INTO tblCMBankAccountBackupForCertEncryption FROM tblCMBankAccount
      END

      DECLARE @DecryptionTable TABLE (
        intBankAccountId INT,
        strMICRRoutingNo NVARCHAR(MAX)
      )

      DECLARE @EncryptionTable TABLE (
        intBankAccountId INT,
        strMICRRoutingNo VARBINARY(256)
      )

      PRINT(''*** Decrypting MICRBankAccountNo (asymmetric) ***'')
      INSERT INTO @DecryptionTable
        SELECT intBankAccountId, CONVERT(NVARCHAR(MAX), CAST(N'''' as XML).value(''xs:base64Binary(sql:column(''''strMICRRoutingNo''''))'', ''varbinary(256)''))
        FROM tblCMBankAccount

      PRINT(''*** Encrypting MICRBankAccountNo using certificate ***'')
      INSERT INTO @EncryptionTable
        SELECT intBankAccountId, ENCRYPTBYCERT(CERT_ID(''iRelyi21Certificate''), CONVERT(VARCHAR(MAX), DECRYPTBYKEYAUTOASYMKEY(ASYMKEY_ID(''i21EncryptionASymKeyPwd''), N''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='', strMICRRoutingNo)))
        FROM @DecryptionTable

      PRINT(''*** Saving certificate encrypted MICRBankAccountNo ***'')
      UPDATE CMBankAccount
        SET strMICRRoutingNo = CAST(N'''' AS XML).value(''xs:base64Binary(sql:column(''''Encrypt.strMICRRoutingNo''''))'', ''varchar(max)'')
        FROM tblCMBankAccount AS CMBankAccount
        JOIN @EncryptionTable AS Encrypt on Encrypt.intBankAccountId = CMBankAccount.intBankAccountId

      INSERT INTO tblEMEntityPreferences (strPreference, strValue, intConcurrencyId) VALUES (''CM tblCMBankAccount MICRRoutingNo re-encryption using certificate'', ''1'', 0)
    ')
  END

  EXEC('CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym')
END