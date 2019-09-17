﻿/*  
 This stored procedure is used as data source in the Voucher Check Middle Overflow Report  
*/  
CREATE PROCEDURE uspCMVoucherCheckMiddleOverflowReport
 @xmlParam NVARCHAR(MAX) = NULL  
AS  
  
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
		,@strTransactionId AS NVARCHAR(MAX)
		,@strBatchId AS NVARCHAR(40)
  
-- Declare the variables for the XML parameter  
DECLARE @xmlDocumentId AS INT  
    
-- Create a table variable to hold the XML data.     
DECLARE @temp_xml_table TABLE (  
 [fieldname] NVARCHAR(50)  
 ,condition NVARCHAR(20)        
 ,[from] NVARCHAR(MAX)  
 ,[to] NVARCHAR(MAX)  
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
 , [from] nvarchar(MAX)  
 , [to] nvarchar(MAX)  
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
		,CHK.strPayee
		,strAmountInWords = LTRIM(RTRIM(REPLACE(CHK.strAmountInWords, '*', ''))) + REPLICATE(' *', 30)
		,CHK.strMemo
		,CHK.strTransactionId
		,CHK.intTransactionId
		,CHK.intBankAccountId
		
		-- Bank and company info related fields
		,strCompanyName = COMPANY.strCompanyName
		,strCompanyAddress = CASE	
									WHEN ISNULL(dbo.fnConvertToFullAddress( COMPANY.strAddress,  COMPANY.strCity, COMPANY.strState,  COMPANY.strZip), '') <> '' AND ISNULL([dbo].fnCMGetBankAccountMICR(CHK.intBankAccountId,CHK.strReferenceNo),'') <> ''  THEN 
										dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip)
									ELSE 
										NULL
							END
		,strBank = ''
		,strBankAddress = ''
		
		-- A/P Related fields: 
		,strVendorId = ISNULL(VENDOR.strVendorId, '--')
		,strVendorName = ISNULL(LTRIM(RTRIM(VENDOR.strVendorId)) + ' ', '-- ') + ISNULL(ISNULL(RTRIM(LTRIM(ENTITY.strName)) + ' ', RTRIM(LTRIM(CHK.strPayee))),'-- ') --+ RTRIM(LTRIM (COMPANY.strCompanyName))
		,strVendorAccount = ISNULL(VENDOR.strVendorAccountNum, '--')
		,strVendorAddress = CASE	
									WHEN ISNULL(dbo.fnConvertToFullAddress(LOCATION.strAddress, LOCATION.strCity, LOCATION.strState, LOCATION.strZipCode), '') <> ''  THEN 
										dbo.fnConvertToFullAddress(LOCATION.strAddress, LOCATION.strCity, LOCATION.strState, LOCATION.strZipCode)
									ELSE 
										dbo.fnConvertToFullAddress(CHK.strAddress, CHK.strCity, CHK.strState, CHK.strZipCode)
							END
		-- Used to change the sub-report during runtime. 
		,CHK.intBankTransactionTypeId		
FROM	dbo.tblCMBankTransaction CHK
		LEFT JOIN tblAPPayment PYMT
			ON CHK.strTransactionId = PYMT.strPaymentRecordNum
		LEFT JOIN tblAPVendor VENDOR
			ON VENDOR.[intEntityId] = ISNULL(PYMT.[intEntityVendorId], CHK.intEntityId)
		LEFT JOIN tblEMEntity ENTITY
			ON VENDOR.[intEntityId] = ENTITY.intEntityId
		LEFT JOIN [tblEMEntityLocation] LOCATION
			ON VENDOR.[intEntityId] = LOCATION.intEntityId AND ysnDefaultLocation = 1 
		OUTER APPLY( SElECT TOP 1 strCompanyName, strAddress,strCity,strState, strCountry, strCounty, strZip FROM tblSMCompanySetup) COMPANY
WHERE	CHK.intBankAccountId = @intBankAccountId
		AND CHK.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionId))
		AND (SELECT COUNT(intPaymentId) FROM tblAPPaymentDetail WHERE intPaymentId = PYMT.intPaymentId) > 10
		AND CHK.dblAmount <> 0
ORDER BY CHK.strReferenceNo ASC