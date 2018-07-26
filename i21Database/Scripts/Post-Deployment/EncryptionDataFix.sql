﻿/*
 Encryption data fix for EM and CM.
*/

DECLARE @version int = SUBSTRING(CAST(SERVERPROPERTY('productversion') AS varchar), 1, CHARINDEX('.', CAST(SERVERPROPERTY('productversion') AS varchar)) - 1)

IF EXISTS (SELECT TOP 1 1 FROM sysobjects WHERE id = object_id(N'[dbo].[uspCreateCertificate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  AND NOT EXISTS (SELECT TOP 1 1 FROM sys.certificates WHERE name = 'iRelyi21Certificate')
BEGIN
  EXEC('[dbo].[uspCreateCertificate]')
END

IF NOT EXISTS (SELECT TOP 1 1 FROM sysobjects WHERE id = object_id(N'[dbo].[uspCreateCertificate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
  IF @version > 10
  BEGIN
    EXEC('
      CREATE PROCEDURE [dbo].[uspCreateCertificate]
      AS
      BEGIN
        CREATE CERTIFICATE iRelyi21Certificate
        FROM BINARY = 0x308202C8308201B0A00302010202107C123B6FE5137D814900ADEB09020A99300D06092A864886F70D01010505003020311E301C060355040313156952656C7920693231204365727469666963617465301E170D3138303532313133303330355A170D3232303533313030303030305A3020311E301C060355040313156952656C792069323120436572746966696361746530820122300D06092A864886F70D01010105000382010F003082010A0282010100CBAECD309891A07693E9AB2263FA9283633DFBCC0276D1373A8BD09185C0988EA3788D908B38B09FDB8E91F4A8AA2758448227CA6C7B6AA5FD7078414890C314F7F6E392589509EEAA10EB4366B0FE2D9BF59AC28AA8010FAB5DB1A5E19160058DFCD77ECCDF280B9F12316F91B8AE3D9F9C30EAEABC4756D16D9E4D62D38326228C6DF55046EE18DEBDDF586374FF8B7B7C30CEBCDF3E3DC3E8DA071FC9841D3EB95143B6120F46556B198704C5E25117F35341402FEE778B2A877AC0D73305017C168E9A6F153FBE1DDB5D51971D4885EEC09CA8A6566B86EF3EFAA68916DFD2C44335B2388940826BE6A66BCAF3FB9A87577E178078D4A2585F7944D0CA010203010001300D06092A864886F70D01010505000382010100101702366ABFA88CFD5A80AB5495E4C95CC66E8C5CEF95E985CA77FDF3906EB7259CFF1995700B3EEAA1270914EA4E3A33E528C13C5358AA5C4E2145F4B7BF87C009749A849EA6F1D669D6289D6708A5B74ABA64EEA6A02FE09355C5C31BAF8BD2BF1A0DE6EB76C1E36862291BBECBC3B70D6A99E919F3EEE593C7B83831328DB6CB838D721BAFD0042D66A64A60E26AF310804C6A193F5A283A73FA9B9A9F99AA6E35A11572B805B4AD306DC878F6EFFB88D5D69288CA95B4683F7A9C84D9393E8A8E75808B219CE0EAF70261A96834D9E1835ECE24CA5C4BBF2E59E449762E32542DF9825A635D25579A20BC35A57AA8398804C58198FF3913A8DC3EBF7381
        WITH PRIVATE KEY (
          BINARY = 0x1EF1B5B00000000001000000010000001000000094040000E511AB651EDCC2BF9879B1A578D1E9BC0702000000A400009FBE9C79F65F202DF3DE19FF899378F89CD2A97C546D0F55F9DD6E2594CF42CA6FF6F2F9169893396DFDCD452510A5DDE421F7A79A907CBA07F26C3167C70502DFA29D87FC975814BE2033CE93DC90A4038AE163803C8C7045A71571D29F2B7CCEA15D91AB6A4BD48F038C30055CED4834C5C15AD1ED16AF4A9CC97296247B68262B43B79B714986957DA74AA372B0D0EF4E342C4B8915CDF22EDAE58A8C120221C53B06E1D759AF576009390C251C91BD584EC598D2514B34F780A1E43D05DA50DCCC6E305777AFC069A66C5876146F48394234B97523DCF8ADE56B67AE575AF27F7264F3CB845A3B135E0A7C857F73C8D0D358F8BBBE1A9F1461A06C28E2E8AFD6806F168A9B515435E9B0FAADD184A17363C9DA28D734179C23D3A6FA9F334CD4ADCEC1C68CF49226107AFF756E3B9E0A60443A19A2944F9A605095BE68017F9CAC081C04CD0FA40D3637126746F287DA5F64BEA66A5EB5BC76EDF726D9CAD23A0FC998A2CD097B4C2DD5EDAA914667AAE5E360C95E8EDE004F42C2E7554A5B91131FFF797846FFF167B767D2DD6BBF24614BFD400B167B76E5E5C6B0AE1455AFAA27630BB85C7AAA449A18F7206FCA62C47EC51A723B282A4018A11BBAD7348C8CB7E3BDAE3C9803EA81F420397D680293721047FC0D738B0603009E50699D65E1B3CD9D3B45D371EDA88E126272D188D4EB4A193C72AFCE6D5C7676D675B13299E02CBE22E0BB0CEE238A0081DE9068AD6BB8FA426B13C6D4F492B074AD40C739093EC2EBFAF97A2B0857A46C009A1B73D35311509F97148C2A6AC597804689FF8D236504E23E94D26C03ED3ACCF220C2981D94FC6852E252939D1B3520DDEE1D4E39AACA827C86E4A9079E41F6E35B3497D38C55BCCC9C457D3D20568589B3AC881A046F79BBDB9D142A75E99DEFEA73AADBED0E8371F35A585EB48552972D70A5C19C16210F852A887B23A5949C7708D8C933E1484CD25FDFA38F54150CE2CBA03D7F4728C02067BD99CC9F2224551865DBD788BB90E8AF46066714BA754865287B9F7164190F36394C6246B1A3F05612FCE4218A620F0876C62151D6274378CA23FDADD0D6209571B2CC9EAB10F84E7F37CB31280DEDA58FFC98C3196BF3610D4D9CD889CC9E4F8D7186698C0CA2D799A83F94F267CAA5E6437DD3749CC2A5B23BAF8E4BF03B813C4DED4B0AF8C497FAD74ADD432C1C37B77D35580B2AB60D7599C9BF9A142BEB32A2E0E16DD1E0F0886A7D28FF5E2E812FF009D88F2DD26BE8424ED5ABEDF71478060D035770192DF5B51AEDDDDC74F216D37D5054D650F4E21755951500103D722F3EA61B0A7BF965EA286D576BBA3AE701B6B485FCDB71C3357C15E4CEFCE8B4C63AA1936808B5EB4462939CA4C4F8035D298E5F8FD2097E8EA430C7C8E341ACEB08FDBA26B7D7F61A2A95BDF0EE36BED7CAD639735C8E46B6612B0015F3DB3E278AE9BA0312E76662D8EA2439E65C65D76C7846082916961BB165EDDCBA30EE255064C576BE73A49477F5A321CD5F004ACE853DB837ED6E0C4EB0036F8BE9D25E83253C5FA0981C970A38BF93C1540F9605849FE09D4305AFB932E70AD12E8B3C3B43DE2E78AC062B46067BB942209D4B924676DD9AD0FF002B8BBA66ADE191,
          DECRYPTION BY PASSWORD = ''5b027c081e37b'',
          ENCRYPTION BY PASSWORD = ''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY=''
        );
      END
    ')
  END
END

IF NOT EXISTS (SELECT TOP 1 1 FROM sys.certificates WHERE name = 'iRelyi21Certificate')
BEGIN
  IF @version > 10
  BEGIN
  EXEC('
    CREATE CERTIFICATE iRelyi21Certificate
      FROM BINARY = 0x308202C8308201B0A00302010202107C123B6FE5137D814900ADEB09020A99300D06092A864886F70D01010505003020311E301C060355040313156952656C7920693231204365727469666963617465301E170D3138303532313133303330355A170D3232303533313030303030305A3020311E301C060355040313156952656C792069323120436572746966696361746530820122300D06092A864886F70D01010105000382010F003082010A0282010100CBAECD309891A07693E9AB2263FA9283633DFBCC0276D1373A8BD09185C0988EA3788D908B38B09FDB8E91F4A8AA2758448227CA6C7B6AA5FD7078414890C314F7F6E392589509EEAA10EB4366B0FE2D9BF59AC28AA8010FAB5DB1A5E19160058DFCD77ECCDF280B9F12316F91B8AE3D9F9C30EAEABC4756D16D9E4D62D38326228C6DF55046EE18DEBDDF586374FF8B7B7C30CEBCDF3E3DC3E8DA071FC9841D3EB95143B6120F46556B198704C5E25117F35341402FEE778B2A877AC0D73305017C168E9A6F153FBE1DDB5D51971D4885EEC09CA8A6566B86EF3EFAA68916DFD2C44335B2388940826BE6A66BCAF3FB9A87577E178078D4A2585F7944D0CA010203010001300D06092A864886F70D01010505000382010100101702366ABFA88CFD5A80AB5495E4C95CC66E8C5CEF95E985CA77FDF3906EB7259CFF1995700B3EEAA1270914EA4E3A33E528C13C5358AA5C4E2145F4B7BF87C009749A849EA6F1D669D6289D6708A5B74ABA64EEA6A02FE09355C5C31BAF8BD2BF1A0DE6EB76C1E36862291BBECBC3B70D6A99E919F3EEE593C7B83831328DB6CB838D721BAFD0042D66A64A60E26AF310804C6A193F5A283A73FA9B9A9F99AA6E35A11572B805B4AD306DC878F6EFFB88D5D69288CA95B4683F7A9C84D9393E8A8E75808B219CE0EAF70261A96834D9E1835ECE24CA5C4BBF2E59E449762E32542DF9825A635D25579A20BC35A57AA8398804C58198FF3913A8DC3EBF7381
      WITH PRIVATE KEY (
        BINARY = 0x1EF1B5B00000000001000000010000001000000094040000E511AB651EDCC2BF9879B1A578D1E9BC0702000000A400009FBE9C79F65F202DF3DE19FF899378F89CD2A97C546D0F55F9DD6E2594CF42CA6FF6F2F9169893396DFDCD452510A5DDE421F7A79A907CBA07F26C3167C70502DFA29D87FC975814BE2033CE93DC90A4038AE163803C8C7045A71571D29F2B7CCEA15D91AB6A4BD48F038C30055CED4834C5C15AD1ED16AF4A9CC97296247B68262B43B79B714986957DA74AA372B0D0EF4E342C4B8915CDF22EDAE58A8C120221C53B06E1D759AF576009390C251C91BD584EC598D2514B34F780A1E43D05DA50DCCC6E305777AFC069A66C5876146F48394234B97523DCF8ADE56B67AE575AF27F7264F3CB845A3B135E0A7C857F73C8D0D358F8BBBE1A9F1461A06C28E2E8AFD6806F168A9B515435E9B0FAADD184A17363C9DA28D734179C23D3A6FA9F334CD4ADCEC1C68CF49226107AFF756E3B9E0A60443A19A2944F9A605095BE68017F9CAC081C04CD0FA40D3637126746F287DA5F64BEA66A5EB5BC76EDF726D9CAD23A0FC998A2CD097B4C2DD5EDAA914667AAE5E360C95E8EDE004F42C2E7554A5B91131FFF797846FFF167B767D2DD6BBF24614BFD400B167B76E5E5C6B0AE1455AFAA27630BB85C7AAA449A18F7206FCA62C47EC51A723B282A4018A11BBAD7348C8CB7E3BDAE3C9803EA81F420397D680293721047FC0D738B0603009E50699D65E1B3CD9D3B45D371EDA88E126272D188D4EB4A193C72AFCE6D5C7676D675B13299E02CBE22E0BB0CEE238A0081DE9068AD6BB8FA426B13C6D4F492B074AD40C739093EC2EBFAF97A2B0857A46C009A1B73D35311509F97148C2A6AC597804689FF8D236504E23E94D26C03ED3ACCF220C2981D94FC6852E252939D1B3520DDEE1D4E39AACA827C86E4A9079E41F6E35B3497D38C55BCCC9C457D3D20568589B3AC881A046F79BBDB9D142A75E99DEFEA73AADBED0E8371F35A585EB48552972D70A5C19C16210F852A887B23A5949C7708D8C933E1484CD25FDFA38F54150CE2CBA03D7F4728C02067BD99CC9F2224551865DBD788BB90E8AF46066714BA754865287B9F7164190F36394C6246B1A3F05612FCE4218A620F0876C62151D6274378CA23FDADD0D6209571B2CC9EAB10F84E7F37CB31280DEDA58FFC98C3196BF3610D4D9CD889CC9E4F8D7186698C0CA2D799A83F94F267CAA5E6437DD3749CC2A5B23BAF8E4BF03B813C4DED4B0AF8C497FAD74ADD432C1C37B77D35580B2AB60D7599C9BF9A142BEB32A2E0E16DD1E0F0886A7D28FF5E2E812FF009D88F2DD26BE8424ED5ABEDF71478060D035770192DF5B51AEDDDDC74F216D37D5054D650F4E21755951500103D722F3EA61B0A7BF965EA286D576BBA3AE701B6B485FCDB71C3357C15E4CEFCE8B4C63AA1936808B5EB4462939CA4C4F8035D298E5F8FD2097E8EA430C7C8E341ACEB08FDBA26B7D7F61A2A95BDF0EE36BED7CAD639735C8E46B6612B0015F3DB3E278AE9BA0312E76662D8EA2439E65C65D76C7846082916961BB165EDDCBA30EE255064C576BE73A49477F5A321CD5F004ACE853DB837ED6E0C4EB0036F8BE9D25E83253C5FA0981C970A38BF93C1540F9605849FE09D4305AFB932E70AD12E8B3C3B43DE2E78AC062B46067BB942209D4B924676DD9AD0FF002B8BBA66ADE191,
        DECRYPTION BY PASSWORD = ''5b027c081e37b'',
        ENCRYPTION BY PASSWORD = ''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY=''
      );
  ')
  END
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
        strPassword VARCHAR(MAX) NULL
      )

      DECLARE @EncryptionTable TABLE (
        intEntityCredentialId INT,
        strPassword VARBINARY(256)
      )

      PRINT(''*** Decrypting password (asymmetric) ***'')
      INSERT INTO @DecryptionTable
        SELECT intEntityCredentialId, ISNULL(CONVERT(VARCHAR(MAX), DECRYPTBYKEYAUTOASYMKEY(ASYMKEY_ID(''i21EncryptionASymKeyPwd''), N''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='', CONVERT(NVARCHAR(MAX), CAST(N'''' as XML).value(''xs:base64Binary(sql:column(''''strPassword''''))'', ''varbinary(256)'')))), strPassword)
        FROM tblEMEntityCredential

      PRINT(''*** Encrypting password using certificate ***'')
      INSERT INTO @EncryptionTable
        SELECT intEntityCredentialId, ENCRYPTBYCERT(CERT_ID(''iRelyi21Certificate''), strPassword)
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
        strAccountNumber VARCHAR(MAX) NULL
      )

      DECLARE @EncryptionTable TABLE (
        intEntityEFTInfoId INT,
        strAccountNumber VARBINARY(256)
      )

      PRINT(''*** Decrypting account number (asymmetric) ***'')
      INSERT INTO @DecryptionTable
        SELECT intEntityEFTInfoId, ISNULL(CONVERT(VARCHAR(MAX), DECRYPTBYKEYAUTOASYMKEY(ASYMKEY_ID(''i21EncryptionASymKeyPwd''), N''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='', CONVERT(NVARCHAR(MAX), CAST(N'''' as XML).value(''xs:base64Binary(sql:column(''''strAccountNumber''''))'', ''varbinary(256)'')))), strAccountNumber)
        FROM tblEMEntityEFTInformation

      PRINT(''*** Encrypting account number using certificate ***'')
      INSERT INTO @EncryptionTable
        SELECT intEntityEFTInfoId, ENCRYPTBYCERT(CERT_ID(''iRelyi21Certificate''), strAccountNumber)
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

  IF EXISTS (SELECT * FROM tblCMBank WHERE LEN(strRTN) < 300)
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

  IF EXISTS (SELECT * FROM tblCMBankAccount WHERE LEN(strBankAccountNo) < 300)
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

  IF EXISTS (SELECT * FROM tblCMBankAccount WHERE LEN(ISNULL(strRTN, '')) < 300)
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

  IF EXISTS (SELECT * FROM tblCMBankAccount WHERE LEN(strMICRBankAccountNo) < 300)
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

  IF EXISTS (SELECT * FROM tblCMBankAccount WHERE LEN(strMICRRoutingNo) < 300)
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