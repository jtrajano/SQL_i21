/*  
 This stored procedure is used as data source in the Voucher Check Middle Report
*/  
CREATE PROCEDURE uspCMVoucherCheckMiddleReport
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
		,CHK.strPayee
		,strAmountInWords = LTRIM(RTRIM(REPLACE(CHK.strAmountInWords, '*', ''))) + REPLICATE(' *', 30)
		,CHK.strMemo
		,CHK.strTransactionId
		,CHK.intTransactionId
		,PRINTSPOOL.strBatchId
		,CHK.intBankAccountId
		
		-- Bank and company info related fields
		,strCompanyName = ''
		,strCompanyAddress = ''
		,strBank = ''
		,strBankAddress = ''
		
		-- A/P Related fields: 
		,strVendorId = ISNULL(VENDOR.strVendorId, '--')
		,strVendorName = ISNULL(ENTITY.strName, CHK.strPayee)
		,strVendorAccount = ISNULL(VENDOR.strVendorAccountNum, '--')
		,strVendorAddress = CASE	
									WHEN ISNULL(dbo.fnConvertToFullAddress(LOCATION.strAddress, LOCATION.strCity, LOCATION.strState, LOCATION.strZipCode), '') <> ''  THEN 
										dbo.fnConvertToFullAddress(LOCATION.strAddress, LOCATION.strCity, LOCATION.strState, LOCATION.strZipCode)
									ELSE 
										dbo.fnConvertToFullAddress(CHK.strAddress, CHK.strCity, CHK.strState, CHK.strZipCode)
							END
		-- Used to change the sub-report during runtime. 
		,CHK.intBankTransactionTypeId		
FROM	dbo.tblCMBankTransaction CHK INNER JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL
			ON CHK.strTransactionId = PRINTSPOOL.strTransactionId
			AND CHK.intBankAccountId = PRINTSPOOL.intBankAccountId
		LEFT JOIN tblAPPayment PYMT
			ON CHK.strTransactionId = PYMT.strPaymentRecordNum
		LEFT JOIN tblAPVendor VENDOR
			ON VENDOR.[intEntityVendorId] = ISNULL(PYMT.intVendorId, CHK.intEntityId)
		LEFT JOIN tblEntity ENTITY
			ON VENDOR.[intEntityVendorId] = ENTITY.intEntityId
		LEFT JOIN tblEntityLocation LOCATION
			ON VENDOR.intDefaultLocationId = LOCATION.intEntityLocationId
			AND LOCATION.intEntityId = ENTITY.intEntityId
WHERE	CHK.intBankAccountId = @intBankAccountId
		AND CHK.strTransactionId = ISNULL(@strTransactionId, CHK.strTransactionId)
		AND PRINTSPOOL.strBatchId = ISNULL(@strBatchId, PRINTSPOOL.strBatchId)
ORDER BY CHK.strReferenceNo ASC