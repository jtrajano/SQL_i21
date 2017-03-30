CREATE PROCEDURE [dbo].[uspPRPaycheckMiddleReport]
	@xmlParam NVARCHAR(MAX) = NULL  
AS  

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON
  
-- Sample XML string structure:  
--SET @xmlParam = '  
--<xmlparam>  
-- <filters>  
--  <filter>  
--   <fieldname>intBankAccountId</fieldname>  
--   <condition>Between</condition>  
--   <from>1</from>  
--   <to>1</to>  
--   <join>And</join>  
--   <begingroup>0</begingroup>  
--   <endgroup>0</endgroup>  
--   <datatype>String</datatype>  
--  </filter>  
-- </filters>  
-- <options />  
--</xmlparam>'  
  
-- Sanitize the @xmlParam   
IF LTRIM(RTRIM(@xmlParam)) = ''   
 SET @xmlParam = NULL   
  
-- Declare the variables.  
DECLARE @intBankAccountId AS INT
		,@intTransactionId AS INT
  
-- Declare the variables for the XML parameter  
DECLARE @xmlDocumentId AS INT  
    
-- Create a table variable to hold the XML data.     
DECLARE @temp_xml_table TABLE (  
 [fieldname] NVARCHAR(50)  
 ,condition NVARCHAR(20)        
 ,[from] NVARCHAR(50)  
 ,[to] NVARCHAR(50)  
 ,[join] NVARCHAR(10)  
 ,[begingroup] NVARCHAR(50)  
 ,[endgroup] NVARCHAR(50)  
 ,[datatype] NVARCHAR(50)  
)  
  
-- Prepare the XML   
EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
-- Insert the XML to the xml table.     
INSERT INTO @temp_xml_table  
SELECT *  
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
WITH (  
 [fieldname] nvarchar(50)  
 , condition nvarchar(20)  
 , [from] nvarchar(50)  
 , [to] nvarchar(50)  
 , [join] nvarchar(10)  
 , [begingroup] nvarchar(50)  
 , [endgroup] nvarchar(50)  
 , [datatype] nvarchar(50)  
)  
  
-- Gather the variables values from the xml table.   
SELECT @intBankAccountId = [from]  
FROM @temp_xml_table   
WHERE [fieldname] = 'intBankAccountId'  

SELECT	@intTransactionId = [from]
FROM @temp_xml_table   
WHERE [fieldname] = 'intTransactionId'

--For Encryption and Decryption
OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
	DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
	WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

-- Report Query:  
SELECT DISTINCT 
	tblCMBankTransaction.dtmDate,
	strCheckNumber = tblCMBankTransaction.strReferenceNo, 
	dblAmount = Abs (tblCMBankTransaction.dblAmount),
	tblCMBankTransaction.strPayee, 
	strAmountInWords = Ltrim (Rtrim (Replace (tblCMBankTransaction.strAmountInWords, '*', ''))) + Replicate (' *', 30), 
	tblCMBankTransaction.strMemo, 
	tblCMBankTransaction.strTransactionId,
	tblCMBankTransaction.intTransactionId,
	tblCMBankTransaction.intBankAccountId,
	tblCMBankTransaction.dtmCheckPrinted,
	tblCMCheckPrintJobSpool.strBatchId, 
	strCompanyName = CASE WHEN ISNULL([dbo].fnCMGetBankAccountMICR(tblCMBankTransaction.intBankAccountId, tblCMBankTransaction.strReferenceNo), '') <> '' 
							THEN tblSMCompanySetup.strCompanyName 
							ELSE NULL END,
	strCompanyAddress = CASE WHEN ISNULL(dbo.fnConvertToFullAddress(tblSMCompanySetup.strAddress, tblSMCompanySetup.strCity, tblSMCompanySetup.strState, tblSMCompanySetup.strZip), '') <> '' 
								AND ISNULL([dbo].fnCMGetBankAccountMICR(tblCMBankTransaction.intBankAccountId, tblCMBankTransaction.strReferenceNo), '') <> '' 
							THEN dbo.fnConvertToFullAddress(tblSMCompanySetup.strAddress, tblSMCompanySetup.strCity, tblSMCompanySetup.strState, tblSMCompanySetup.strZip) 
							ELSE NULL END,
	strBank = CASE WHEN ISNULL([dbo].fnCMGetBankAccountMICR(tblCMBankTransaction.intBankAccountId, tblCMBankTransaction.strReferenceNo), '') <> '' 
					THEN tblCMBank.strBankName ELSE NULL END,
	strBankAddress = CASE WHEN ISNULL(dbo.fnConvertToFullAddress(tblCMBank.strAddress, tblCMBank.strCity, tblCMBank.strState, tblCMBank.strZipCode), '') <> '' 
							AND ISNULL([dbo].fnCMGetBankAccountMICR(tblCMBankTransaction.intBankAccountId, tblCMBankTransaction.strReferenceNo), '') <> '' 
						THEN dbo.fnConvertToFullAddress (tblCMBank.strAddress, tblCMBank.strCity, tblCMBank.strState, tblCMBank.strZipCode) + Char (13) + tblCMBankAccount.strFractionalRoutingNumber 
						ELSE NULL END,
	strMICR = [dbo].fnCMGetBankAccountMICR (tblCMBankTransaction.intBankAccountId,tblCMBankTransaction.strReferenceNo),
	tblCMBankAccount.strUserDefineMessage,
	tblCMBankAccount.strSignatureLineCaption,
	ysnShowTwoSignatureLine = CONVERT(BIT, CASE WHEN tblCMBankAccount.ysnShowTwoSignatureLine = 1 AND tblCMBankTransaction.dblAmount > tblCMBankAccount.dblGreaterThanAmount THEN 1 ELSE 0 END),
	tblCMBankAccount.ysnCheckEnableMICRPrint,
	tblPREmployeeInfo.strEmployeeId,
	tblPREmployeeInfo.strFirstName,
	tblPREmployeeInfo.strMiddleName, tblPREmployeeInfo.strLastName,
	tblPREmployeeInfo.strNameSuffix,
	tblPREmployeeInfo.strPayPeriod, 
	strEmployeeAddress = CASE WHEN ISNULL(dbo.fnConvertToFullAddress(tblPREmployeeInfo.strAddress, tblPREmployeeInfo.strCity, tblPREmployeeInfo.strState, tblPREmployeeInfo.strZipCode), '') <> '' 
							THEN dbo.fnConvertToFullAddress(tblPREmployeeInfo.strAddress, tblPREmployeeInfo.strCity, tblPREmployeeInfo.strState, tblPREmployeeInfo.strZipCode) 
							ELSE dbo.fnConvertToFullAddress(tblCMBankTransaction.strAddress, tblCMBankTransaction.strCity, tblCMBankTransaction.strState, tblCMBankTransaction.strZipCode) END,
	tblPRPaycheck.intPaycheckId, 
	dtmDateFrom = ISNULL(tblPRPaycheck.dtmDateFrom, NULL),
	dtmDateTo = ISNULL(tblPRPaycheck.dtmDateTo, NULL), 
	dblGross = ISNULL(tblPRPaycheck.dblGross, 0),
	dblTaxTotal = ISNULL(tblPRPaycheck.dblTaxTotal, 0),
	dblDeductionTotal = ISNULL(tblPRPaycheck.dblDeductionTotal, 0),
	dblNetPayTotal = ISNULL(tblPRPaycheck.dblNetPayTotal, 0),
	tblPRPaycheck.ysnVoid, 
	dblGrossYTD = Sum(ISNULL(tblPaycheckYTD.dblGrossYTD, 0)), 
	dblTaxYTD = Sum(ISNULL(tblPaycheckYTD.dblTaxTotalYTD, 0)),
	dblDeductionYTD = Sum(ISNULL(tblPaycheckYTD.dblDeductionTotalYTD, 0)),
	dblNetYTD = Sum(ISNULL(tblPaycheckYTD.dblNetPayTotalYTD, 0))
FROM 
	tblSMCompanySetup, 
	(SELECT DISTINCT
		tblPRPaycheck.intPaycheckId, 
		strPaycheckId,
		intEntityEmployeeId,
		dtmDateFrom,
		dtmDateTo,
		dtmPayDate,
		dblGross = Sum (tblPRPaycheckEarning.dblTotal), 
		dblTaxTotal,
		dblDeductionTotal,
		dblNetPayTotal,
		ysnVoid 
	FROM 
		tblPRPaycheck
		LEFT JOIN tblPRPaycheckEarning 
			ON tblPRPaycheck.intPaycheckId = tblPRPaycheckEarning.intPaycheckId
	WHERE 
		tblPRPaycheck.ysnPosted = 1 AND tblPRPaycheck.ysnVoid = 0
		AND tblPRPaycheckEarning.strCalculationType NOT IN ('Reimbursement', 'Fringe Benefit') 
	GROUP BY
		tblPRPaycheck.intPaycheckId,
		strPaycheckId,
		intEntityEmployeeId,
		dtmDateFrom,
		dtmDateTo,
		dtmPayDate,
		dblTaxTotal,
		dblDeductionTotal,
		dblNetPayTotal,
		ysnVoid) [tblPRPaycheck] 
	LEFT JOIN 
		(SELECT 
			tblPREmployee.*,
			tblEMEntity.strName,
			tblEMEntityLocation.strAddress,
			tblEMEntityLocation.strCity,
			tblEMEntityLocation.strState,
			tblEMEntityLocation.strZipCode
		FROM 
			tblPREmployee 
			LEFT JOIN tblEMEntity
				ON tblPREmployee.[intEntityId] = tblEMEntity.intEntityId
			LEFT JOIN tblEMEntityLocation
				ON tblPREmployee.[intEntityId] = tblEMEntityLocation.intEntityId
				AND tblEMEntityLocation.ysnDefaultLocation = 1) [tblPREmployeeInfo] 
		ON [tblPRPaycheck].[intEntityEmployeeId] = [tblPREmployeeInfo].[intEntityId]
	LEFT JOIN (
		SELECT
			tblPRPaycheck.[intEntityEmployeeId],
			tblPRPaycheck.intPaycheckId, tblPRPaycheck.dtmPayDate,
			dblGrossYTD = Sum (tblPaychecks.dblGross),
			dblDeductionTotalYTD = Sum (tblPaychecks.dblDeductionTotal),
			dblNetPayTotalYTD = Sum (tblPaychecks.dblNetPayTotal),
			dblTaxTotalYTD = Sum (tblPaychecks.dblTaxTotal) 
		FROM
			tblPRPaycheck 
			LEFT JOIN 
				(SELECT 
					[intEntityEmployeeId],
					tblPRPaycheck.intPaycheckId, 
					dtmPayDate, 
					dblGross = Sum (tblPRPaycheckEarning.dblTotal), 
					dblDeductionTotal = Max (dblDeductionTotal), 
					dblNetPayTotal = Max (dblNetPayTotal),
					dblTaxTotal = Max (dblTaxTotal) 
				FROM 
					tblPRPaycheck 
					LEFT JOIN tblPRPaycheckEarning 
						ON tblPRPaycheck.intPaycheckId = tblPRPaycheckEarning.intPaycheckId
				WHERE tblPRPaycheck.ysnPosted = 1 AND tblPRPaycheck.ysnVoid = 0
					AND tblPRPaycheckEarning.strCalculationType NOT IN ('Reimbursement', 'Fringe Benefit')
				GROUP BY
					tblPRPaycheck.intEntityEmployeeId,
					tblPRPaycheck.intPaycheckId,
					tblPRPaycheck.dtmPayDate) [tblPaychecks] 
			ON [tblPRPaycheck].[intEntityEmployeeId] = [tblPaychecks].[intEntityEmployeeId]
			AND Cast (Floor (Cast (tblPaychecks.dtmPayDate AS FLOAT)) AS DATETIME) 
				BETWEEN Cast (('1/1/' + Cast (Year (tblPRPaycheck.dtmPayDate) AS NVARCHAR (4))) AS DATETIME) 
					AND Cast (Floor (Cast (tblPRPaycheck.dtmPayDate AS FLOAT)) AS DATETIME) 
		WHERE 
			tblPRPaycheck.ysnVoid = 0
		GROUP BY
			tblPRPaycheck.[intEntityEmployeeId],
			tblPRPaycheck.intPaycheckId, tblPRPaycheck.dtmPayDate) [tblPaycheckYTD]
		ON [tblPRPaycheck].intPaycheckId = [tblPaycheckYTD].intPaycheckId 
		AND Year ([tblPRPaycheck].[dtmPayDate]) = Year([tblPaycheckYTD].[dtmPayDate]) 
		AND Cast (Floor (Cast (tblPaycheckYTD.dtmPayDate AS FLOAT)) AS DATETIME) > = Cast (Floor (Cast (tblPaycheckYTD.dtmPayDate AS FLOAT)) AS DATETIME)
	LEFT JOIN tblCMBankTransaction
		ON tblCMBankTransaction.strTransactionId = tblPRPaycheck.strPaycheckId
	INNER JOIN tblCMBankAccount
		ON tblCMBankAccount.intBankAccountId = tblCMBankTransaction.intBankAccountId
	INNER JOIN tblCMBank
		ON tblCMBank.intBankId = tblCMBankAccount.intBankId
	INNER JOIN
       (SELECT DISTINCT 
			intTransactionId,
			strTransactionId, 
			strBatchId
		FROM 
			tblCMCheckPrintJobSpool) [tblCMCheckPrintJobSpool]
	   ON [tblCMBankTransaction].[intTransactionId] = [tblCMCheckPrintJobSpool].[intTransactionId]
WHERE 
	tblCMBankTransaction.intBankTransactionTypeId = 21 
GROUP BY 
	tblSMCompanySetup.strCompanyName,
	tblSMCompanySetup.strAddress, tblSMCompanySetup.strCity,
	tblSMCompanySetup.strState, tblSMCompanySetup.strZip,
	tblCMBankTransaction.dtmDate,
	tblCMBankTransaction.strReferenceNo,
	tblCMBankTransaction.dblAmount, tblCMBankTransaction.strPayee,
	tblCMBankTransaction.strAmountInWords,
	tblCMBankTransaction.strMemo,
	tblCMBankTransaction.strTransactionId,
	tblCMBankTransaction.intTransactionId,
	tblCMBankTransaction.intBankAccountId,
	tblCMBankTransaction.dtmCheckPrinted,
	tblCMBankTransaction.strAddress, tblCMBankTransaction.strCity,
	tblCMBankTransaction.strState, tblCMBankTransaction.strZipCode,
	tblCMBank.strBankName, tblCMBank.strAddress, tblCMBank.strCity,
	tblCMBank.strState, tblCMBank.strZipCode,
	tblCMBankAccount.strFractionalRoutingNumber,
	tblCMBankAccount.strUserDefineMessage,
	tblCMBankAccount.strSignatureLineCaption,
	tblCMBankAccount.dblGreaterThanAmount,
	tblCMBankAccount.ysnShowTwoSignatureLine,
	tblCMBankAccount.ysnCheckEnableMICRPrint,
	tblCMCheckPrintJobSpool.strBatchId,
	tblPREmployeeInfo.strEmployeeId,
	tblPREmployeeInfo.strFirstName,
	tblPREmployeeInfo.strMiddleName, tblPREmployeeInfo.strLastName,
	tblPREmployeeInfo.strNameSuffix,
	tblPREmployeeInfo.strPayPeriod, tblPREmployeeInfo.strAddress,
	tblPREmployeeInfo.strCity, tblPREmployeeInfo.strState,
	tblPREmployeeInfo.strZipCode, tblPRPaycheck.intPaycheckId,
	tblPRPaycheck.dtmDateFrom, tblPRPaycheck.dtmDateTo,
	tblPRPaycheck.dblGross, tblPRPaycheck.dblTaxTotal,
	tblPRPaycheck.dblDeductionTotal, tblPRPaycheck.dblNetPayTotal,
	tblPRPaycheck.ysnVoid

CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym