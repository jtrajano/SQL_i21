/*  
 This stored procedure is used as data source in the Settlement Report
*/  
CREATE PROCEDURE [dbo].[uspCMSettlementReport]
 @xmlParam NVARCHAR(MAX) = NULL  
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

  
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
		,@strModule AS NVARCHAR(40)
  
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

SELECT	@strModule = [from]
FROM @temp_xml_table   
WHERE [fieldname] = 'strModule'
  
-- Sanitize the parameters  
SET @strTransactionId = CASE WHEN LTRIM(RTRIM(ISNULL(@strTransactionId, ''))) = '' THEN NULL ELSE @strTransactionId END  
SET @strModule = CASE WHEN LTRIM(RTRIM(ISNULL(@strModule, ''))) = '' THEN NULL ELSE @strModule END  
  
-- Report Query:  
IF @strModule = 'Cash Management'
BEGIN
	SELECT
	BNKTRN.intBankAccountId,
	BNKTRN.intTransactionId,
	BNKTRN.strTransactionId,
	--Company info related fields
	strCompanyName = COMPANY.strCompanyName,
	strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState,COMPANY.strZip),

	--Report Title related fields
	Item.strItemNo,
	--(SELECT strItemNo FROM tblICItem WHERE intItemId = (SELECT TOP 1 intItemId FROM tblAPBillDetail WHERE intBillId =BillDtl.intBillId AND intInventoryReceiptChargeId IS NULL)) as strItemNo,

	--Vendor Account Number
	strDate = CONVERT(VARCHAR(10),GETDATE(),110),
	strTime = CONVERT(VARCHAR(8),GETDATE(),108),
	strAccountNumber = EFT.strAccountNumber,
	BNKTRN.strReferenceNo,

	--Vendor Address
	strEntityName = ENTITY.strName,
	strVendorAddress = dbo.fnConvertToFullAddress(Bill.strShipToAddress, Bill.strShipToCity, Bill.strShipToState,Bill.strShipToZipCode),
	TICKET.intTicketId,
	INVRCPT.strReceiptNumber,
	TICKET.strTicketNumber,
	LOCATION.strLocationName,
	Bill.dtmDate,
	BillDtl.dblCost,
	BillDtl.dblQtyOrdered,
	BillDtl.dblTax,
	CNTRCT.strContractNumber,
	BillDtl.dblTotal
	,(SELECT SUM(dblCost) FROM tblAPBillDetail WHERE intBillId = BillDtl.intBillId AND intInventoryReceiptChargeId IS NOT NULL) AS dblTotalDiscount
	, BillDtl.intBillId
	FROM tblCMBankTransaction BNKTRN
	INNER JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL ON BNKTRN.strTransactionId = PRINTSPOOL.strTransactionId
	            AND BNKTRN.intBankAccountId = PRINTSPOOL.intBankAccountId
	INNER JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId =  PYMT.strPaymentRecordNum
	INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
	INNER JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
	INNER JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId AND BillDtl.intInventoryReceiptChargeId is null
	INNER JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
	INNER JOIN tblICInventoryReceiptItem INVRCPTITEM ON BillDtl.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceipt INVRCPT ON INVRCPTITEM.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
	INNER JOIN tblSCTicket TICKET ON INVRCPTITEM.intSourceId = TICKET.intTicketId
	LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityVendorId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityVendorId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1 
	LEFT JOIN tblEMEntityLocation LOCATION ON VENDOR.intEntityVendorId = LOCATION.intEntityId AND ysnDefaultLocation = 1 
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (SElECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	WHERE BNKTRN.intBankAccountId = @intBankAccountId
END
ELSE
BEGIN
	SELECT
	BNKTRN.intBankAccountId,
	BNKTRN.intTransactionId,
	BNKTRN.strTransactionId,
	--Company info related fields
	strCompanyName = COMPANY.strCompanyName,
	strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity, COMPANY.strState,COMPANY.strZip),

	--Report Title related fields
	Item.strItemNo,
	--(SELECT strItemNo FROM tblICItem WHERE intItemId = (SELECT TOP 1 intItemId FROM tblAPBillDetail WHERE intBillId =BillDtl.intBillId AND intInventoryReceiptChargeId IS NULL)) as strItemNo,

	--Vendor Account Number
	strDate = CONVERT(VARCHAR(10),GETDATE(),110),
	strTime = CONVERT(VARCHAR(8),GETDATE(),108),
	strAccountNumber = EFT.strAccountNumber,
	BNKTRN.strReferenceNo,

	--Vendor Address
	strEntityName = ENTITY.strName,
	strVendorAddress = dbo.fnConvertToFullAddress(Bill.strShipToAddress, Bill.strShipToCity, Bill.strShipToState,Bill.strShipToZipCode),
	TICKET.intTicketId,
	INVRCPT.strReceiptNumber,
	TICKET.strTicketNumber,
	LOCATION.strLocationName,
	Bill.dtmDate,
	BillDtl.dblCost,
	BillDtl.dblQtyOrdered,
	BillDtl.dblTax,
	CNTRCT.strContractNumber,
	BillDtl.dblTotal
	,(SELECT SUM(dblCost) FROM tblAPBillDetail WHERE intBillId = BillDtl.intBillId AND intInventoryReceiptChargeId IS NOT NULL) AS dblTotalDiscount
	, BillDtl.intBillId
	FROM tblCMBankTransaction BNKTRN
	--INNER JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL ON BNKTRN.strTransactionId = PRINTSPOOL.strTransactionId
	--            AND BNKTRN.intBankAccountId = PRINTSPOOL.intBankAccountId
	INNER JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId =  PYMT.strPaymentRecordNum
	INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
	INNER JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
	INNER JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId AND BillDtl.intInventoryReceiptChargeId is null
	INNER JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
	INNER JOIN tblICInventoryReceiptItem INVRCPTITEM ON BillDtl.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceipt INVRCPT ON INVRCPTITEM.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
	INNER JOIN tblSCTicket TICKET ON INVRCPTITEM.intSourceId = TICKET.intTicketId
	LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityVendorId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityVendorId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1 
	LEFT JOIN tblEMEntityLocation LOCATION ON VENDOR.intEntityVendorId = LOCATION.intEntityId AND ysnDefaultLocation = 1 
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (SElECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	WHERE BNKTRN.intBankAccountId = @intBankAccountId  AND BNKTRN.strTransactionId = @strTransactionId
END