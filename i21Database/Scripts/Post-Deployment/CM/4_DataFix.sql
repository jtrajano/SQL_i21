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


	--Backup tblCMBank table
	IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE [TABLE_NAME] = 'tblCMBankBackupBeforeASymApproach')
	DROP TABLE tblCMBankBackupBeforeASymApproach
	SELECT * INTO tblCMBankBackupBeforeASymApproach FROM tblCMBank
	--Backup tblCMBankAccount table
	IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE [TABLE_NAME] = 'tblCMBankAccountBackupBeforeASymApproach')
	DROP TABLE tblCMBankAccountBackupBeforeASymApproach
	SELECT * INTO tblCMBankAccountBackupBeforeASymApproach FROM tblCMBankAccount
	
	

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
	@strMICRRoutingNo as nvarchar(max),
	@intEncryptCheckLength as int = 300

	--Open the symmetric key
	OPEN SYMMETRIC KEY i21EncryptionSymKey
	DECRYPTION BY CERTIFICATE i21EncryptionCert
	WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

	UPDATE Bank SET strRTN = ISNULL(dbo.fnAESDecrypt(strRTN),strRTN) 
	FROM tblCMBank Bank 
	WHERE LEN(TRIM(strRTN)) < @intEncryptCheckLength

	UPDATE BankAccount SET strBankAccountNo = ISNULL(dbo.fnAESDecrypt(strBankAccountNo),strBankAccountNo)
	FROM tblCMBankAccount BankAccount
	WHERE LEN(TRIM(strBankAccountNo )) < @intEncryptCheckLength
	
	UPDATE BankAccount SET strRTN = ISNULL(dbo.fnAESDecrypt(strRTN),strRTN)
	FROM tblCMBankAccount BankAccount
	WHERE LEN(TRIM(strRTN )) < @intEncryptCheckLength

	UPDATE BankAccount SET strMICRBankAccountNo = ISNULL(dbo.fnAESDecrypt(strMICRBankAccountNo),strMICRBankAccountNo)
	FROM tblCMBankAccount BankAccount
	WHERE LEN(TRIM(strMICRBankAccountNo )) < @intEncryptCheckLength

	UPDATE BankAccount SET strMICRRoutingNo = ISNULL(dbo.fnAESDecrypt(strMICRRoutingNo),strMICRRoutingNo)
	FROM tblCMBankAccount BankAccount
	WHERE LEN(TRIM(strMICRRoutingNo )) < @intEncryptCheckLength

	--Close the symmetric key
	CLOSE SYMMETRIC KEY i21EncryptionSymKey

	--enable tblCMBank triggers
	ALTER TABLE tblCMBank ENABLE TRIGGER trgInsteadOfInsertCMBank
	ALTER TABLE tblCMBank ENABLE TRIGGER trgInsteadOfUpdateCMBank

--This will fix previous ACH transaction to set intBankFileAuditId = 0 in preparation to the new approach. This is related to this jira key CM-1457
IF NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'CM Previous ACH transactions set intBankFileAuditId = 0')
BEGIN

	UPDATE tblCMBankTransaction SET intBankFileAuditId = 0 WHERE intBankTransactionTypeId IN (22,23) AND dtmCheckPrinted IS NOT NULL

	--Insert into EM Preferences. This will serve as the checking if the datafix will be executed or not.
	INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('CM Previous ACH transactions set intBankFileAuditId = 0','1')
END	

--This will fix all CM's NULL intTransactionId on tblGLDetail and tblGLDetailRecap. This is related to this jira key CM-1793
IF NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'CM Fix for NULL intTransactionId on GL table')
BEGIN

	--GL DETAIL
	UPDATE tblGLDetail
	SET intTransactionId = (SELECT TOP 1 intTransactionId FROM tblGLDetail WHERE strTransactionId = GL.strTransactionId AND strModuleName = GL.strModuleName AND intTransactionId IS NOT NULL) 
	FROM tblGLDetail GL
	WHERE GL.strModuleName = 'Cash Management'
	AND GL.intTransactionId IS NULL
	
	--GL DETAIL RECAP
	UPDATE tblGLDetailRecap 
	SET intTransactionId = (SELECT TOP 1 intTransactionId FROM tblGLDetail WHERE strTransactionId = GL.strTransactionId AND strModuleName = GL.strModuleName AND intTransactionId IS NOT NULL) 
	FROM tblGLDetailRecap GL
	WHERE GL.strModuleName = 'Cash Management'
	AND GL.intTransactionId IS NULL


	--Insert into EM Preferences. This will serve as the checking if the datafix will be executed or not.
	INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('CM Fix for NULL intTransactionId on GL table','1')
END	

--This will fix all old transaction to be included as one batch in the Archive File tab of Process Payment. This is related to this jira key CM-1904
IF NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'CM Include Old Transations in Archive Tab')
BEGIN

    INSERT INTO tblCMBankFileGenerationLog 
        (intBankAccountId
        ,intTransactionId
        ,strTransactionId
        ,strProcessType
        ,intBankFileFormatId
        ,dtmGenerated
        ,intBatchId
        ,strFileName
        ,ysnSent
        ,dtmSent
        ,intEntityId
        ,intConcurrencyId)
    SELECT
        intBankAccountId
        ,intTransactionId
        ,strTransactionId
        ,'Positive Pay'
        ,0
        ,GETDATE()
        ,1
        ,'Old Transactions'
        ,0
        ,null
        ,1
        ,1
    FROM tblCMBankTransaction 
    WHERE intBankTransactionTypeId IN (3,16,21) AND intBankFileAuditId IS NULL AND dtmCheckPrinted IS NOT NULL AND ysnCheckVoid = 0
    AND intTransactionId NOT IN (SELECT intTransactionId FROM tblCMBankFileGenerationLog)    

    --Insert into EM Preferences. This will serve as the checking if the datafix will be executed or not.
    INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('CM Include Old Transations in Archive Tab','1')
END    

-- UPDATES NULL intEntityId columns that is causing batch post error GL-6595
UPDATE Trans SET Trans.intEntityId = Undep.intLastModifiedUserId 
FROM tblCMBankTransactionDetail TransDetail 
JOIN tblCMUndepositedFund Undep ON Undep.intUndepositedFundId = TransDetail.intUndepositedFundId
JOIN tblCMBankTransaction Trans ON Trans.intTransactionId = TransDetail.intTransactionId
WHERE Trans.intEntityId is null AND Trans.ysnPosted = 0
GO

--GL-6389
PRINT('Begin removing Voided prefix in check numbers')
GO

UPDATE tblCMBankTransaction SET strReferenceNo = REPLACE(strReferenceNo,'Voided-','')
UPDATE  tblCMCheckNumberAudit SET strCheckNo = REPLACE(strCheckNo,'Voided-','') 
GO

PRINT('Finished removing Voided prefix in check numbers')
GO
PRINT('Begin cleaning up Undeposited Funds table')
GO
-- Clean up tblCMUndepositedFund
BEGIN TRY
	DELETE FROM tblCMBankTransactionDetail 	WHERE dblDebit = 0 AND dblCredit = 0 
	DELETE FROM tblCMUndepositedFund WHERE dblAmount = 0
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE()
END CATCH

GO
PRINT('Finished cleaning up Undeposited Funds table')
GO
PRINT('/*******************  END Cash Management Data Fixess *******************/')
GO