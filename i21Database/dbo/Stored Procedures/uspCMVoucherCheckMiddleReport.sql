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
		,@strTransactionId AS NVARCHAR(40)
		,@strBatchId AS NVARCHAR(40)
  
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
SELECT	CHK.dtmDate
		,strCheckNumber = CHK.strReferenceNo
		,CHK.dblAmount
		,strPayee = CASE
					WHEN (SELECT COUNT(intEntityLienId) FROM tblAPVendorLien L WHERE intEntityVendorId = VENDOR.[intEntityId]) > 0 THEN
						CHK.strPayee + ' ' + (STUFF( (SELECT ' and ' + strName 
                             FROM tblAPVendorLien LIEN
							 INNER JOIN tblEMEntity ENT ON LIEN.intEntityLienId = ENT.intEntityId
							 WHERE LIEN.ysnActive = 1 AND GETDATE() BETWEEN LIEN.dtmStartDate AND LIEN.dtmEndDate
                             ORDER BY intEntityVendorLienId
                             FOR XML PATH('')), 
                            1, 1, ''))
					ELSE
						CHK.strPayee
					END
		,strAmountInWords = LTRIM(RTRIM(REPLACE(CHK.strAmountInWords, '*', ''))) + REPLICATE(' *', 30)
		,CHK.strMemo
		,CHK.strTransactionId
		,CHK.intTransactionId
		,PRINTSPOOL.strBatchId
		,CHK.intBankAccountId
		,strCurrency = (SELECT strCurrency FROM tblSMCurrency WHERE intCurrencyID = CHK.intCurrencyId)
		
		-- Bank and company info related fields
		,strCompanyName = CASE
							WHEN ISNULL([dbo].fnCMGetBankAccountMICR(CHK.intBankAccountId,CHK.strReferenceNo),'') <> '' THEN 
								COMPANY.strCompanyName
							ELSE
								NULL
							END
		,strCompanyAddress = CASE	
									WHEN ISNULL(dbo.fnConvertToFullAddress( COMPANY.strAddress,  COMPANY.strCity, COMPANY.strState,  COMPANY.strZip), '') <> '' AND ISNULL([dbo].fnCMGetBankAccountMICR(CHK.intBankAccountId,CHK.strReferenceNo),'') <> ''  THEN 
										dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip)
									ELSE 
										NULL
							END
		,strBank = CASE
						WHEN ISNULL([dbo].fnCMGetBankAccountMICR(CHK.intBankAccountId,CHK.strReferenceNo),'') <> '' THEN 
							BNK.strBankName
						ELSE
							NULL
					END
		,strBankAddress =  CASE	
									WHEN ISNULL(dbo.fnConvertToFullAddress(BNK.strAddress, BNK.strCity, BNK.strState, BNK.strZipCode), '') <> '' AND ISNULL([dbo].fnCMGetBankAccountMICR(CHK.intBankAccountId,CHK.strReferenceNo),'') <> ''  THEN 
										dbo.fnConvertToFullAddress(BNK.strAddress, BNK.strCity, BNK.strState, BNK.strZipCode) + CHAR(13) + BNKACCNT.strFractionalRoutingNumber
									ELSE 
										NULL
							END
							
		--MICR setup					
		,strMICR = [dbo].fnCMGetBankAccountMICR(CHK.intBankAccountId,CHK.strReferenceNo)
		,BNKACCNT.strUserDefineMessage
		,BNKACCNT.strSignatureLineCaption
		,ysnShowTwoSignatureLine = CONVERT(bit,CASE WHEN BNKACCNT.ysnShowTwoSignatureLine = 1 AND CHK.dblAmount >  BNKACCNT.dblGreaterThanAmount THEN 1 ELSE 0 END)
		
		-- A/P Related fields: 
		,strVendorId = ISNULL(VENDOR.strVendorId, '--')
		,strVendorName = ISNULL(ENTITY.strName, CHK.strPayee)
		,strVendorAccount = ISNULL(VENDOR.strVendorAccountNum, '--')
		,strVendorAddress = CASE	
									WHEN ISNULL(dbo.fnConvertToFullAddress(CHK.strAddress, CHK.strCity, CHK.strState, CHK.strZipCode), '') <> ''  THEN 
										dbo.fnConvertToFullAddress(CHK.strAddress, CHK.strCity, CHK.strState, CHK.strZipCode)
									ELSE 
										dbo.fnConvertToFullAddress(LOCATION.strAddress, LOCATION.strCity, LOCATION.strState, LOCATION.strZipCode)
										
							END
		-- Used to change the sub-report during runtime. 
		,CHK.intBankTransactionTypeId
		--Use to display the MICR
		,BNKACCNT.ysnCheckEnableMICRPrint		
FROM	dbo.tblCMBankTransaction CHK INNER JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL
			ON CHK.strTransactionId = PRINTSPOOL.strTransactionId
			AND CHK.intBankAccountId = PRINTSPOOL.intBankAccountId
		INNER JOIN tblCMBankAccount BNKACCNT
			ON BNKACCNT.intBankAccountId = CHK.intBankAccountId
		INNER JOIN tblCMBank BNK
			ON BNK.intBankId = BNKACCNT.intBankId
		LEFT JOIN tblAPPayment PYMT
			ON CHK.strTransactionId = PYMT.strPaymentRecordNum
		LEFT JOIN tblAPVendor VENDOR
			ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], CHK.intEntityId)
		LEFT JOIN tblEMEntity ENTITY
			ON VENDOR.[intEntityId] = ENTITY.intEntityId
		LEFT JOIN [tblEMEntityLocation] LOCATION
			ON VENDOR.[intEntityId] = LOCATION.intEntityId AND ysnDefaultLocation = 1 
		LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (SElECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
WHERE	CHK.intBankAccountId = @intBankAccountId
		AND CHK.strTransactionId = ISNULL(@strTransactionId, CHK.strTransactionId)
		AND PRINTSPOOL.strBatchId = ISNULL(@strBatchId, PRINTSPOOL.strBatchId)
ORDER BY CHK.strReferenceNo ASC

