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
	WHERE LEN(LTRIM(RTRIM(strRTN))) < @intEncryptCheckLength

	UPDATE BankAccount SET strBankAccountNo = ISNULL(dbo.fnAESDecrypt(strBankAccountNo),strBankAccountNo)
	FROM tblCMBankAccount BankAccount
	WHERE LEN(LTRIM(RTRIM(strBankAccountNo))) < @intEncryptCheckLength
	
	UPDATE BankAccount SET strRTN = ISNULL(dbo.fnAESDecrypt(strRTN),strRTN)
	FROM tblCMBankAccount BankAccount
	WHERE LEN(LTRIM(RTRIM(strRTN))) < @intEncryptCheckLength

	UPDATE BankAccount SET strMICRBankAccountNo = ISNULL(dbo.fnAESDecrypt(strMICRBankAccountNo),strMICRBankAccountNo)
	FROM tblCMBankAccount BankAccount
	WHERE LEN(LTRIM(RTRIM(strMICRBankAccountNo))) < @intEncryptCheckLength

	UPDATE BankAccount SET strMICRRoutingNo = ISNULL(dbo.fnAESDecrypt(strMICRRoutingNo),strMICRRoutingNo)
	FROM tblCMBankAccount BankAccount
	WHERE LEN(LTRIM(RTRIM(strMICRRoutingNo))) < @intEncryptCheckLength

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
--GL DETAIL
UPDATE GL
SET intTransactionId = GL1.intTransactionId
FROM tblGLDetail GL
CROSS APPLY(
		SELECT TOP 1 intTransactionId FROM tblGLDetail WHERE strTransactionId = GL.strTransactionId
		AND strModuleName = GL.strModuleName 
		AND intTransactionId IS NOT NULL
) GL1
WHERE GL.strModuleName = 'Cash Management'
AND GL.intTransactionId IS NULL

--GL DETAIL RECAP
DELETE FROM tblGLDetailRecap 
WHERE intTransactionId IS NULL

UPDATE tblCMBankTransaction set ysnCheckToBePrinted = 0 WHERE ISNULL(ysnCheckToBePrinted,0) = 1

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

-- UPDATES NULL intEntityId columns that is causing batch post error GL-6595,GL-7582
	UPDATE A SET intEntityId =  ISNULL(A.intLastModifiedUserId,  ISNULL(U.intEntityId, G.intEntityId))
	FROM tblCMBankTransaction A 
	OUTER APPLY(
		SELECT TOP 1 intEntityId FROM tblSMAuditLog WHERE strTransactionType LIKE 'CashManagement.view.%'
		AND strRecordNo = CONVERT(NVARCHAR(20),A.intTransactionId)
	)U
	OUTER apply(
		SELECT TOP 1 intEntityId FROM tblGLDetail WHERE strTransactionId = A.strTransactionId
		
	)G
	WHERE A.intEntityId IS NULL
	AND ysnPosted = 0
	AND A.intBankTransactionTypeId IN (1,3,4,5)
GO

--GL-6389
PRINT('Begin removing Voided prefix in check numbers')
GO

UPDATE tblCMBankTransaction SET strReferenceNo = REPLACE(strReferenceNo,'Voided-','')
UPDATE  tblCMCheckNumberAudit SET strCheckNo = REPLACE(strCheckNo,'Voided-','') 
GO

PRINT('Finished removing Voided prefix in check numbers')
GO


PRINT('Begin correcting unposted bdep with wrong dblamount')
GO
--GL-7580
 
	;WITH C AS(
		SELECT  strTransactionId,(dblAmount + dblShortAmount) dblAmount, dblShortAmount, ysnPosted,
		SUM(dblCredit-dblDebit) dblAmountDetail
		FROM
		tblCMBankTransaction CM JOIN tblCMBankTransactionDetail D ON D.intTransactionId = CM.intTransactionId
		WHERE intBankTransactionTypeId=1 AND ysnPosted  = 0
		GROUP BY strTransactionId,dblAmount,dblShortAmount,ysnPosted
		)
		UPDATE CM set dblAmount = dblAmountDetail - a.dblShortAmount from C a join tblCMBankTransaction CM 
		ON a.strTransactionId = CM.strTransactionId 
		WHERE a.dblAmount <> dblAmountDetail
	GO

PRINT('Finished correcting unposted bdep with wrong dblamount')
GO


PRINT('/*******************  END Cash Management Data Fixess *******************/')
GO