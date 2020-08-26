/*  
 This stored procedure is used as data source in the Voucher Check Middle Report
*/  
CREATE PROCEDURE [dbo].[uspCMVoucherCheckMiddleReport]
 @xmlParam NVARCHAR(MAX) = NULL  
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  
  
DECLARE @BANK_DEPOSIT INT = 1  
  ,@BANK_WITHDRAWAL INT = 2  
  ,@MISC_CHECKS INT = 3  
  ,@BANK_TRANSFER INT = 4  
  ,@BANK_TRANSACTION INT = 5  
  ,@CREDIT_CARD_CHARGE INT = 6  
  ,@CREDIT_CARD_RETURNS INT = 7  
  ,@CREDIT_CARD_PAYMENTS INT = 8  
  ,@BANK_TRANSFER_WD INT = 9  
  ,@BANK_TRANSFER_DEP INT = 10  
  ,@ORIGIN_DEPOSIT AS INT = 11  
  ,@ORIGIN_CHECKS AS INT = 12  
  ,@ORIGIN_EFT AS INT = 13  
  ,@ORIGIN_WITHDRAWAL AS INT = 14  
  ,@ORIGIN_WIRE AS INT = 15  
  ,@AP_PAYMENT AS INT = 16  
  ,@BANK_STMT_IMPORT AS INT = 17
  ,@AR_PAYMENT AS INT = 18
  ,@VOID_CHECK AS INT = 19
  ,@AP_ECHECK AS INT = 20
  ,@PAYCHECK AS INT = 21
  
-- Sanitize the @xmlParam   
IF LTRIM(RTRIM(@xmlParam)) = ''   
 SET @xmlParam = NULL   
  
-- Declare the variables.  
DECLARE @intBankAccountId AS INT
		,@strTransactionId AS NVARCHAR(max)
		,@strBatchId AS NVARCHAR(40)
  
-- Declare the variables for the XML parameter  
DECLARE @xmlDocumentId AS INT  
    
-- Create a table variable to hold the XML data.     
DECLARE @temp_xml_table TABLE (  
 [fieldname] NVARCHAR(50)  
 ,condition NVARCHAR(20)        
 ,[from] NVARCHAR(max)  
 ,[to] NVARCHAR(max)  
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
 , [from] nvarchar(max)  
 , [to] nvarchar(max)  
 , [join] nvarchar(10)  
 , [begingroup] nvarchar(50)  
 , [endgroup] nvarchar(50)  
 , [datatype] nvarchar(50)  
)  
  
-- Gather the variables values from the xml table.   
SELECT @intBankAccountId = [from]  
FROM @temp_xml_table   
WHERE [fieldname] = 'intBankAccountId'  

SELECT	@strTransactionId = [from]
FROM @temp_xml_table   
WHERE [fieldname] = 'strTransactionId'

SELECT	@strBatchId = [from]
FROM @temp_xml_table   
WHERE [fieldname] = 'strBatchId'
  
-- Sanitize the parameters  
SET @strTransactionId = CASE WHEN LTRIM(RTRIM(ISNULL(@strTransactionId, ''))) = '' THEN NULL ELSE @strTransactionId END  
SET @strBatchId = CASE WHEN LTRIM(RTRIM(ISNULL(@strBatchId, ''))) = '' THEN NULL ELSE @strBatchId END  



-- Report Query:  
SELECT	
		 CHK.dtmDate
		,strCheckNumber = CHK.strReferenceNo
		,CHK.dblAmount
		,strPayee =  Payee.Name 
		,strPayeeAddress = Address.Value
		,strAmountInWords = AmtInWords.Val
		,CHK.strMemo
		,CHK.strTransactionId
		,CHK.intTransactionId
		--,PRINTSPOOL.strBatchId
		,CHK.intBankAccountId
		,strCurrency = CURRENCY.strCurrency
		
		-- Bank and company info related fields
		,strCompanyName = COMPANY.strCompanyName 
		,strCompanyAddress =	CASE WHEN COMPANY.strCompanyAddress <> ''
								THEN COMPANY.strCompanyAddress
								ELSE NULL
								END
		,strBank =	CASE WHEN MICR.strText <> '' 
					THEN BNK.strBankName 
					ELSE NULL 
					END
		,strBankAddress =	CASE WHEN BANK.strAddress <> '' AND MICR.strText <> ''  
							THEN BANK.strAddress + CHAR(13) + BNKACCNT.strFractionalRoutingNumber
							ELSE NULL
							END
							
		--MICR setup					
		,strMICR = MICR.strText
		,BNKACCNT.strUserDefineMessage
		,BNKACCNT.strSignatureLineCaption
		,ysnShowTwoSignatureLine = CONVERT(BIT,CASE WHEN BNKACCNT.ysnShowTwoSignatureLine = 1 AND CHK.dblAmount >  BNKACCNT.dblGreaterThanAmount THEN 1 ELSE 0 END)

		,ysnShowFirstSignature = CONVERT(BIT,CASE WHEN BNKACCNT.ysnShowFirstSignature = 1 AND CHK.dblAmount >  BNKACCNT.dblFirstAmountIsOver THEN 1 ELSE 0 END)
		,ysnShowSecondSignature = CONVERT(BIT,CASE WHEN BNKACCNT.ysnShowSecondSignature = 1 AND CHK.dblAmount >  BNKACCNT.dblSecondAmountIsOver THEN 1 ELSE 0 END)
		,blbFirstSignatureDetail = (SELECT TOP 1 blbDetail FROM tblSMSignature WHERE intSignatureId = BNKACCNT.intFirstSignatureId)
		,blbSecondSignatureDetail = (SELECT TOP 1 blbDetail FROM tblSMSignature WHERE intSignatureId = BNKACCNT.intSecondSignatureId)
		
		-- A/P Related fields: 
		,strVendor = ISNULL(LTRIM(RTRIM(VENDOR.strVendorId)) + ' ', '-- ') + ISNULL(ISNULL(RTRIM(LTRIM(ENTITY.strName)) + ' ', RTRIM(LTRIM(CHK.strPayee))),'-- ') --+ RTRIM(LTRIM (COMPANY.strCompanyName))
		,strVendorAccount = ISNULL(VENDOR.strVendorAccountNum, '--')
		-- Used to change the sub-report during runtime. 
		,CHK.intBankTransactionTypeId
		--Use to display the MICR
		,BNKACCNT.ysnCheckEnableMICRPrint
		,strCheckMessage = ISNULL(PYMT.strCheckMessage,'') 
		,CHK.ysnCheckVoid
		,BNKACCNT.intPayToDown
		,strDateFormat = CASE WHEN CURRENCY.strCurrency = 'CAD' THEN NULL ELSE CompanyPref.strReportDateFormat END
FROM	dbo.tblCMBankTransaction CHK 
		INNER JOIN tblCMBankAccount BNKACCNT ON BNKACCNT.intBankAccountId = CHK.intBankAccountId
		INNER JOIN tblCMBank BNK ON BNK.intBankId = BNKACCNT.intBankId
		LEFT JOIN tblAPPayment PYMT ON CHK.strTransactionId = PYMT.strPaymentRecordNum
		LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], CHK.intEntityId)
		LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId
		LEFT JOIN tblSMCurrency CURRENCY ON CURRENCY.intCurrencyID = CHK.intCurrencyId
		OUTER APPLY (SElECT TOP 1 strCompanyName,ISNULL(dbo.fnConvertToFullAddress(strAddress,strCity,strState,strZip),'') strCompanyAddress FROM tblSMCompanySetup) COMPANY
		OUTER APPLY (SELECT ISNULL(dbo.fnCMGetBankAccountMICR(CHK.intBankAccountId,CHK.strReferenceNo),'') strText) MICR
		OUTER APPLY (SELECT ISNULL(dbo.fnConvertToFullAddress(BNK.strAddress, BNK.strCity, BNK.strState, BNK.strZipCode), '') strAddress) BANK
		OUTER APPLY (SELECT ISNULL(dbo.fnConvertToFullAddress(CHK.strAddress, CHK.strCity, CHK.strState, CHK.strZipCode), '') strAddress) CHEK
		OUTER APPLY
		(
			SELECT LTRIM(RTRIM(REPLACE(CHK.strAmountInWords, '*', ''))) + REPLICATE(' *', (100 - LEN(LTRIM(RTRIM(REPLACE(CHK.strAmountInWords, '*', '')))))/2) Val
		)AmtInWords
		OUTER APPLY(
			SELECT
			CASE WHEN PYMT.ysnOverrideCheckPayee = 1 THEN 
					PYMT.strOverridePayee
			ELSE	
			CASE
			WHEN	(SELECT COUNT(intEntityLienId) FROM tblAPVendorLien L WHERE intEntityVendorId = VENDOR.[intEntityId]) > 0 AND ISNULL(PYMT.ysnOverrideLien, 0) = 0 
			THEN
				ISNULL(RTRIM(CHK.strPayee) + ' ' + 
					(STUFF((SELECT DISTINCT ' and ' + strName
                        FROM tblAPVendorLien LIEN
						INNER JOIN tblEMEntity ENT ON LIEN.intEntityLienId = ENT.intEntityId
						WHERE LIEN.intEntityVendorId = VENDOR.intEntityId AND LIEN.ysnActive = 1 
						AND CHK.dtmDate BETWEEN LIEN.dtmStartDate AND LIEN.dtmEndDate
						AND LIEN.intCommodityId IN (
							SELECT intCommodityId 
							FROM tblAPPayment Pay 
							INNER JOIN tblAPPaymentDetail PayDtl ON Pay.intPaymentId = PayDtl.intPaymentId
							INNER JOIN vyuAPVoucherCommodity VC ON PayDtl.intBillId = VC.intBillId
							WHERE strPaymentRecordNum = PYMT.strPaymentRecordNum)FOR XML PATH(''))
					,1, 1, ''))
				,CHK.strPayee)
			ELSE
				CHK.strPayee
			END
			END Name
		
		) Payee
		OUTER APPLY (
			SELECT 
			CASE WHEN ISNULL(PYMT.ysnOverrideCheckPayee, 0) = 0
				THEN ISNULL(CHEK.strAddress,'')
			ELSE
				''
			END
			Value
		)Address
		OUTER APPLY tblSMCompanyPreference CompanyPref
WHERE	CHK.intBankAccountId = @intBankAccountId
		AND CHK.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionId))
		AND CHK.dblAmount != 0 AND PYMT.intPaymentMethodId ! = 3
ORDER BY CHK.strReferenceNo ASC