-- --------------------------------------------------
-- Purpose: This script includes all the datafix needed after deployment of database 
-- --------------------------------------------------
-- Date Created: 05/26/2016
-- Created by: Smith de Jesus
-- --------------------------------------------------

print('/*******************  BEGIN Cash Management Data Fixes *******************/')

--This will insert the old data from strBankAccountNo to strMICRBankAccountNo and strRTN to strMICRRoutingNo (CM-1215)
IF EXISTS (SELECT * FROM tblCMBankAccount WHERE strMICRRoutingNo IS NULL OR strMICRBankAccountNo IS NULL)
BEGIN
	UPDATE tblCMBankAccount set strMICRRoutingNo = strRTN WHERE strMICRRoutingNo IS NULL
	UPDATE tblCMBankAccount set strMICRBankAccountNo = strBankAccountNo WHERE strMICRBankAccountNo IS NULL
END


IF NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'CM Datafix for Asymmetric approach in Encryption and Decryption')
BEGIN

	--Backup tblCMBank table
	IF NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE [TABLE_NAME] = 'tblCMBankBackupBeforeASymApproach')
	BEGIN
		SELECT * INTO tblCMBankBackupBeforeASymApproach FROM tblCMBank
	END 
	
	--Backup tblCMBankAccount table
	IF NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE [TABLE_NAME] = 'tblCMBankAccountBackupBeforeASymApproach')
	BEGIN
		SELECT * INTO tblCMBankAccountBackupBeforeASymApproach FROM tblCMBankAccount
	END 
	

	--disable tlbCMBank triggers
	ALTER TABLE tblCMBank DISABLE TRIGGER trgInsteadOfInsertCMBank
	ALTER TABLE tblCMBank DISABLE TRIGGER trgInsteadOfUpdateCMBank


	--Declare the variables that will hold the data
	DECLARE 
	@intBankId as int,
	@intBankAccountId as int,
	@strRTNFromBank as nvarchar(max),
	@strRTNFromBankAccount as nvarchar(max),
	@strBankAccount as nvarchar(max),
	@strMICRBankAccount as nvarchar(max),
	@strMICRRoutingNo as nvarchar(max)

	--Open the symmetric key
	OPEN SYMMETRIC KEY i21EncryptionSymKey
	DECRYPTION BY CERTIFICATE i21EncryptionCert
	WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

	--Insert into temp table
	SELECT intBankId, ISNULL(dbo.fnAESDecrypt(strRTN),strRTN) as strRTN INTO #tmpCMBank FROM tblCMBank

	--loop thru the records and update tblCMBank.strRTN
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpCMBank)
	BEGIN
		SELECT TOP 1 @intBankId = intBankId, @strRTNFromBank = strRTN FROM #tmpCMBank

		UPDATE tblCMBank set strRTN = @strRTNFromBank WHERE intBankId = @intBankId

		DELETE FROM #tmpCMBank WHERE intBankId = @intBankId
	END


	--Insert into temp table
	SELECT intBankAccountId, 
		ISNULL(dbo.fnAESDecrypt(strBankAccountNo),strBankAccountNo) as strBankAccountNo, 
		ISNULL(dbo.fnAESDecrypt(strRTN),strRTN) as strRTN,
		ISNULL(dbo.fnAESDecrypt(strMICRBankAccountNo),strMICRBankAccountNo) as strMICRBankAccountNo,
		ISNULL(dbo.fnAESDecrypt(strMICRRoutingNo),strMICRRoutingNo) as strMICRRoutingNo 
	INTO #tmpCMBankAccount FROM tblCMBankAccount


	--loop thru the records and update tblCMBankAccount's (strBankAccount, strRTN. strMICRBankAccountNo, strMICRRoutingNo)
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpCMBankAccount)
	BEGIN
		SELECT TOP 1 
			@intBankAccountId = intBankAccountId, 
			@strBankAccount = strBankAccountNo,
			@strRTNFromBankAccount = strRTN,
			@strMICRBankAccount = strMICRBankAccountNo,
			@strMICRRoutingNo = strMICRRoutingNo 
		FROM #tmpCMBankAccount

		UPDATE tblCMBankAccount set
			strBankAccountNo = @strBankAccount, 
			strRTN = @strRTNFromBankAccount,
			strMICRBankAccountNo = @strMICRBankAccount,
			strMICRRoutingNo = @strMICRRoutingNo 
		WHERE intBankAccountId = @intBankAccountId

		DELETE FROM #tmpCMBankAccount WHERE intBankAccountId = @intBankAccountId
	END

	--Close the symmetric key
	CLOSE SYMMETRIC KEY i21EncryptionSymKey

	--enable tblCMBank triggers
	ALTER TABLE tblCMBank ENABLE TRIGGER trgInsteadOfInsertCMBank
	ALTER TABLE tblCMBank ENABLE TRIGGER trgInsteadOfUpdateCMBank

	drop table #tmpCMBank
	drop table #tmpCMBankAccount

	--Insert into EM Preferences. This will serve as the checking if the datafix will be executed or not.
	INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('CM Datafix for Asymmetric approach in Encryption and Decryption','1')
END


--This will correctly update the Bank Routing No to encrypted value
--IF EXISTS (SELECT * FROM tblCMBank WHERE LEN(strRTN) > 20) --Greater than 20 means value is already encrypted
--BEGIN
--	DECLARE @strRTN AS NVARCHAR(100)

--	SELECT * INTO #tmpCMBank FROM tblCMBank

--	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpCMBank)
--	BEGIN
--			--OPEN SYMMETRIC KEY i21EncryptionSymKey
--			--   DECRYPTION BY CERTIFICATE i21EncryptionCert
--			--   WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

--				SELECT TOP 1
--				@intBankId = intBankId,
--				@strRTN = dbo.fnAESDecryptASym(strRTN)
--			    FROM #tmpCMBank

--			IF @strRTN IS NOT NULL OR @strRTN <> ''
--			BEGIN
--				UPDATE tblCMBank SET strRTN = @strRTN WHERE intBankId = @intBankId
--			END

--			DELETE FROM #tmpCMBank WHERE intBankId = @intBankId
			
--			--CLOSE SYMMETRIC KEY i21EncryptionSymKey
--	END	
--END

--This will update the Bank Routing No to encrypted value
IF EXISTS (SELECT * FROM tblCMBank WHERE LEN(strRTN) < 20) AND NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'CM Encrypt tblCMBank.strRTN')
BEGIN
	--disable tlbCMBank triggers
	ALTER TABLE tblCMBank DISABLE TRIGGER trgInsteadOfInsertCMBank
	ALTER TABLE tblCMBank DISABLE TRIGGER trgInsteadOfUpdateCMBank

	OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
	DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
	WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

	UPDATE tblCMBank SET strRTN =  dbo.fnAESEncryptASym(strRTN)

	CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

	--enable tblCMBank triggers
	ALTER TABLE tblCMBank ENABLE TRIGGER trgInsteadOfInsertCMBank
	ALTER TABLE tblCMBank ENABLE TRIGGER trgInsteadOfUpdateCMBank

	--Insert into EM Preferences. This will serve as the checking if the datafix will be executed or not.
	INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('CM Encrypt tblCMBank.strRTN','1')
END	

--This will update the Bank Account No to encrypted value
IF EXISTS (SELECT * FROM tblCMBankAccount WHERE LEN(strBankAccountNo) < 20) AND NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'CM Encrypt tblCMBankAccount.strBankAccountNo')
BEGIN

	OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
	DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
	WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

	UPDATE tblCMBankAccount SET strBankAccountNo = dbo.fnAESEncryptASym(strBankAccountNo)

	CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

	--Insert into EM Preferences. This will serve as the checking if the datafix will be executed or not.
	INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('CM Encrypt tblCMBankAccount.strBankAccountNo','1')
END	

--This will update the  Routing No to encrypted value based on what is setup in tblCMBank.strRTN
IF EXISTS (SELECT * FROM tblCMBankAccount WHERE LEN(ISNULL(strRTN,'')) < 20) AND NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'CM Encrypt tblCMBankAccount.strRTN')
BEGIN
	
		UPDATE tblCMBankAccount
		SET strRTN = Bank.strRTN
		FROM tblCMBank Bank
		WHERE tblCMBankAccount.intBankId = Bank.intBankId

	--Insert into EM Preferences. This will serve as the checking if the datafix will be executed or not.
	INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('CM Encrypt tblCMBankAccount.strRTN','1')
END	


--This will update the MICR Bank Account No to encrypted value
IF EXISTS (SELECT * FROM tblCMBankAccount WHERE LEN(strMICRBankAccountNo) < 20) AND NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'CM Encrypt tblCMBankAccount.strMICRBankAccountNo')
BEGIN

	OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
	DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
	WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

	UPDATE tblCMBankAccount SET strMICRBankAccountNo = dbo.fnAESEncryptASym(strMICRBankAccountNo)

	CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

	--Insert into EM Preferences. This will serve as the checking if the datafix will be executed or not.
	INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('CM Encrypt tblCMBankAccount.strMICRBankAccountNo','1')
END	


--This will update the MICR Routing No to encrypted value
IF EXISTS (SELECT * FROM tblCMBankAccount WHERE LEN(strMICRRoutingNo) < 20) AND NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'CM Encrypt tblCMBankAccount.strMICRRoutingNo')
BEGIN

	OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
	DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
	WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

	UPDATE tblCMBankAccount SET strMICRRoutingNo = dbo.fnAESEncryptASym(strMICRRoutingNo)

	CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

	--Insert into EM Preferences. This will serve as the checking if the datafix will be executed or not.
	INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('CM Encrypt tblCMBankAccount.strMICRRoutingNo','1')
END	


--This will fix previous ACH transaction to set intBankFileAuditId = 0 in preparation to the new approach. This is related to this jira key CM-1457
IF NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'CM Previous ACH transactions set intBankFileAuditId = 0')
BEGIN

	UPDATE tblCMBankTransaction SET intBankFileAuditId = 0 WHERE intBankTransactionTypeId IN (22,23) AND dtmCheckPrinted IS NOT NULL

	--Insert into EM Preferences. This will serve as the checking if the datafix will be executed or not.
	INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('CM Previous ACH transactions set intBankFileAuditId = 0','1')
END	

print('/*******************  END Cash Management Data Fixess *******************/')