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

--This will correctly update the Bank Routing No to encrypted value
IF EXISTS (SELECT * FROM tblCMBank WHERE LEN(strRTN) > 20) --Greater than 20 means value is already encrypted
BEGIN
	DECLARE @strRTN AS NVARCHAR(100),
			@intBankId AS INT

	SELECT * INTO #tmpCMBank FROM tblCMBank

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpCMBank)
	BEGIN
			OPEN SYMMETRIC KEY i21EncryptionSymKey
			   DECRYPTION BY CERTIFICATE i21EncryptionCert
			   WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

				SELECT TOP 1
				@intBankId = intBankId,
				@strRTN = dbo.fnAESDecrypt(strRTN)
			    FROM #tmpCMBank

			IF @strRTN IS NOT NULL OR @strRTN <> ''
			BEGIN
				UPDATE tblCMBank SET strRTN = @strRTN WHERE intBankId = @intBankId
			END

			DELETE FROM #tmpCMBank WHERE intBankId = @intBankId
			
			--CLOSE SYMMETRIC KEY i21EncryptionSymKey
	END	
END

--This will update the Bank Routing No to encrypted value
IF EXISTS (SELECT * FROM tblCMBank WHERE LEN(strRTN) < 20)
BEGIN
	UPDATE tblCMBank SET strRTN = strRTN
END	

--This will update the BankAccount Account No, Routing No, MICR Bank Account No, MICR Routing No to encrypted value
IF EXISTS (SELECT * FROM tblCMBankAccount WHERE LEN(strRTN) < 20)
BEGIN
	UPDATE vyuCMBankAccount SET strRTN = strRTN
END	

print('/*******************  END Cash Management Data Fixess *******************/')