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
	strVendorAddress = dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode),
	CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1 SC.intTicketId FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.intTicketId FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END AS intTicketId,
	CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1 SC.strTicketNumber FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.strTicketNumber FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END AS strTicketNumber,
	INVRCPT.strReceiptNumber,
	INVRCPTITEM.intInventoryReceiptItemId,
	--LOCATION.strLocationName,
	Bill.strBillId as RecordId,
	CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1 EM.strSplitNumber
			FROM tblGRCustomerStorage GR 
			INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
			INNER JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId AND SC.intSplitId <> 0
			WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)	
		ELSE
		(SELECT TOP 1 EM.strSplitNumber
			FROM tblSCTicket SC
			INNER JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId AND SC.intSplitId <> 0 
			WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		END AS strSplitNumber,
	Bill.dtmDate,
	CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1 SC.dblGrossWeight FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.dblGrossWeight FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END AS dblGrossWeight,
	CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1  SC.dblShrink / SC.dblConvertedUOMQty FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)	
		ELSE
		(SELECT TOP 1 SC.dblShrink / SC.dblConvertedUOMQty FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END AS dblShrinkWeight,
	CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1  SC.dblGrossWeight - SC.dblTareWeight FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.dblGrossWeight - SC.dblTareWeight FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END AS dblNetWeight,
	BillDtl.dblCost,
	BillDtl.dblQtyOrdered as Net,
	UOM.strUnitMeasure,
	BillDtl.dblTotal,
	BillDtl.dblTax,
	CNTRCT.strContractNumber,
	ISNULL((SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = BillDtl.intBillId AND intInventoryReceiptChargeId IS NOT NULL),0) AS TotalDiscount,
	(BillDtl.dblTotal + BillDtl.dblTax +  ISNULL((SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = BillDtl.intBillId AND intInventoryReceiptChargeId IS NOT NULL),0)) as NetDue,
	Bill.strBillId as strId,
	PYMT.intPaymentId,

	--Settlement Total
	BillDtl.dblQtyOrdered as InboundNetWeight,
	0 as OutboundNetWeight,
	BillDtl.dblTotal as InboundGrossDollars,
	0 as OutboundGrossDollars,
	BillDtl.dblTax as InboundTax,
	0 as OutboundTax,
	ISNULL((SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = BillDtl.intBillId AND intInventoryReceiptChargeId IS NOT NULL),0) as InboundDiscount,
	0 as OutboundDiscount,
	(BillDtl.dblTotal + BillDtl.dblTax +  ISNULL((SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = BillDtl.intBillId AND intInventoryReceiptChargeId IS NOT NULL),0)) as InboundNetDue,
	0 as OutboundNetDue,
	ISNULL((SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = BillDtl.intBillId AND (intInventoryReceiptItemId IS NULL AND intInventoryReceiptChargeId IS NULL)),0) AS VoucherAdjustment,
	0 as SalesAdjustment,
	PYMT.dblAmountPaid as CheckAmount
	 
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
	--INNER JOIN tblSCTicket TICKET ON INVRCPTITEM.intSourceId = TICKET.intTicketId
	LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityVendorId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityVendorId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1 
	--LEFT JOIN tblEMEntityLocation LOCATION ON VENDOR.intEntityVendorId = LOCATION.intEntityId AND ysnDefaultLocation = 1 
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (SElECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	--LEFT JOIN tblEMEntitySplit SPLIT ON TICKET.intSplitId = SPLIT.intSplitId AND TICKET.intSplitId <> 0
	WHERE BNKTRN.intBankAccountId = @intBankAccountId  --AND BNKTRN.strTransactionId = @strTransactionId

	UNION ALL SELECT
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
	strVendorAddress = '',--dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode),
	CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1 SC.intTicketId FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.intTicketId FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END AS intTicketId,
	CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1 SC.strTicketNumber FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.strTicketNumber FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END AS strTicketNumber,
	INVSHIP.strShipmentNumber,
	0,
	--LOCATION.strLocationName,
	INV.strInvoiceNumber as RecordId,
	CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1 EM.strSplitNumber
			FROM tblGRCustomerStorage GR 
			INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
			INNER JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId AND SC.intSplitId <> 0
			WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)	
		ELSE
		(SELECT TOP 1 EM.strSplitNumber
			FROM tblSCTicket SC
			INNER JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId AND SC.intSplitId <> 0 
			WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		END AS strSplitNumber,
	INV.dtmDate,
	CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1 SC.dblGrossWeight FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.dblGrossWeight FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END AS dblGrossWeight,
	CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1  SC.dblShrink / SC.dblConvertedUOMQty FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)	
		ELSE
		(SELECT TOP 1 SC.dblShrink / SC.dblConvertedUOMQty FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END AS dblShrinkWeight,
	CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1  SC.dblGrossWeight - SC.dblTareWeight FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.dblGrossWeight - SC.dblTareWeight FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END AS dblNetWeight,
	INVDTL.dblPrice as dblCost,
	INVDTL.dblQtyShipped as Net,
	UOM.strUnitMeasure,
	INVDTL.dblTotal,
	INVDTL.dblTotalTax,
	CNTRCT.strContractNumber,
	ISNULL((SELECT SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceId = INVDTL.intInvoiceId AND intInventoryShipmentChargeId IS NOT NULL),0)  AS TotalDiscount,
	(INVDTL.dblTotal + INVDTL.dblTotalTax + ISNULL((SELECT SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceId = INVDTL.intInvoiceId AND intInventoryShipmentChargeId IS NOT NULL),0)) as NetDue,
	INV.strInvoiceNumber as strId,
	PYMT.intPaymentId,

	--Settlement Total
	0 as InboundNetWeight,
	INVDTL.dblQtyShipped as OutboundNetWeight,
	0 as InboundGrossDollars,
	INVDTL.dblTotal as OutboundGrossDollars,
	0 as InboundTax,
	INVDTL.dblTotalTax as OutboundTax,
	0 as InboundDiscount,
	ISNULL((SELECT SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceId = INVDTL.intInvoiceId AND intInventoryShipmentChargeId IS NOT NULL),0)  as OutboundDiscount,
	0 as InboundNetDue,
	(INVDTL.dblTotal + INVDTL.dblTotalTax + ISNULL((SELECT SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceId = INVDTL.intInvoiceId AND intInventoryShipmentChargeId IS NOT NULL),0)) as OutboundNetDue,
	0 as VoucherAdjustment,
	ISNULL((SELECT SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceId = INVDTL.intInvoiceId AND (intInventoryShipmentItemId IS NULL AND intInventoryShipmentChargeId IS NULL)),0) AS SalesAdjustment,
	PYMT.dblAmountPaid as CheckAmount

	FROM tblCMBankTransaction BNKTRN
	INNER JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL ON BNKTRN.strTransactionId = PRINTSPOOL.strTransactionId
	            AND BNKTRN.intBankAccountId = PRINTSPOOL.intBankAccountId
	INNER JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId =  PYMT.strPaymentRecordNum
	INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
	INNER JOIN tblARInvoice INV ON PYMTDTL.intInvoiceId = INV.intInvoiceId
	INNER JOIN tblARInvoiceDetail INVDTL ON INV.intInvoiceId = INVDTL.intInvoiceId AND INVDTL.intInventoryShipmentChargeId is null
	INNER JOIN tblICItem Item ON INVDTL.intItemId = Item.intItemId
	INNER JOIN tblICInventoryShipmentItem INVSHIPITEM ON INVDTL.intInventoryShipmentItemId = INVSHIPITEM.intInventoryShipmentItemId
	INNER JOIN tblICInventoryShipment INVSHIP ON INVSHIPITEM.intInventoryShipmentId = INVSHIP.intInventoryShipmentId
	--INNER JOIN tblSCTicket TICKET ON INVSHIPITEM.intSourceId = TICKET.intTicketId
	LEFT JOIN tblCTContractHeader CNTRCT ON INVDTL.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityVendorId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityVendorId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1 
	--LEFT JOIN tblEMEntityLocation LOCATION ON VENDOR.intEntityVendorId = LOCATION.intEntityId AND ysnDefaultLocation = 1 
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (SElECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	LEFT JOIN tblICItemUOM ItemUOM ON INVDTL.intItemUOMId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	--LEFT JOIN tblEMEntitySplit SPLIT ON TICKET.intSplitId = SPLIT.intSplitId AND TICKET.intSplitId <> 0
	WHERE BNKTRN.intBankAccountId = @intBankAccountId  --AND BNKTRN.strTransactionId = @strTransactionId
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
	strVendorAddress = dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode),
	CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1 SC.intTicketId FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.intTicketId FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END AS intTicketId,
	CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1 SC.strTicketNumber FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.strTicketNumber FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END AS strTicketNumber,
	INVRCPT.strReceiptNumber,
	INVRCPTITEM.intInventoryReceiptItemId,
	--LOCATION.strLocationName,
	Bill.strBillId as RecordId,
	CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1 EM.strSplitNumber
			FROM tblGRCustomerStorage GR 
			INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
			INNER JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId AND SC.intSplitId <> 0
			WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)	
		ELSE
		(SELECT TOP 1 EM.strSplitNumber
			FROM tblSCTicket SC
			INNER JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId AND SC.intSplitId <> 0 
			WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		END AS strSplitNumber,
	Bill.dtmDate,
	CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1 SC.dblGrossWeight FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.dblGrossWeight FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END AS dblGrossWeight,
	CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1  SC.dblShrink / SC.dblConvertedUOMQty FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)	
		ELSE
		(SELECT TOP 1 SC.dblShrink / SC.dblConvertedUOMQty FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END AS dblShrinkWeight,
	CASE WHEN INVRCPT.intSourceType = 4 THEN
		(SELECT TOP 1  SC.dblGrossWeight - SC.dblTareWeight FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVRCPTITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.dblGrossWeight - SC.dblTareWeight FROM tblSCTicket SC WHERE intTicketId = INVRCPTITEM.intSourceId)
		END AS dblNetWeight,
	BillDtl.dblCost,
	BillDtl.dblQtyOrdered as Net,
	UOM.strUnitMeasure,
	BillDtl.dblTotal,
	BillDtl.dblTax,
	CNTRCT.strContractNumber,
	ISNULL((SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = BillDtl.intBillId AND intInventoryReceiptChargeId IS NOT NULL),0) AS TotalDiscount,
	(BillDtl.dblTotal + BillDtl.dblTax +  ISNULL((SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = BillDtl.intBillId AND intInventoryReceiptChargeId IS NOT NULL),0)) as NetDue,
	Bill.strBillId as strId,
	PYMT.intPaymentId,

	--Settlement Total
	BillDtl.dblQtyOrdered as InboundNetWeight,
	0 as OutboundNetWeight,
	BillDtl.dblTotal as InboundGrossDollars,
	0 as OutboundGrossDollars,
	BillDtl.dblTax as InboundTax,
	0 as OutboundTax,
	ISNULL((SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = BillDtl.intBillId AND intInventoryReceiptChargeId IS NOT NULL),0) as InboundDiscount,
	0 as OutboundDiscount,
	(BillDtl.dblTotal + BillDtl.dblTax +  ISNULL((SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = BillDtl.intBillId AND intInventoryReceiptChargeId IS NOT NULL),0)) as InboundNetDue,
	0 as OutboundNetDue,
	ISNULL((SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = BillDtl.intBillId AND (intInventoryReceiptItemId IS NULL AND intInventoryReceiptChargeId IS NULL)),0) AS VoucherAdjustment,
	0 as SalesAdjustment,
	PYMT.dblAmountPaid as CheckAmount
	 
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
	--INNER JOIN tblSCTicket TICKET ON INVRCPTITEM.intSourceId = TICKET.intTicketId
	LEFT JOIN tblCTContractHeader CNTRCT ON BillDtl.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityVendorId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityVendorId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1 
	--LEFT JOIN tblEMEntityLocation LOCATION ON VENDOR.intEntityVendorId = LOCATION.intEntityId AND ysnDefaultLocation = 1 
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (SElECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	LEFT JOIN tblICItemUOM ItemUOM ON BillDtl.intUnitOfMeasureId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	--LEFT JOIN tblEMEntitySplit SPLIT ON TICKET.intSplitId = SPLIT.intSplitId AND TICKET.intSplitId <> 0
	WHERE BNKTRN.intBankAccountId = @intBankAccountId  AND BNKTRN.strTransactionId = @strTransactionId

	UNION ALL SELECT
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
	strVendorAddress = '',--dbo.fnConvertToFullAddress(Bill.strShipFromAddress, Bill.strShipFromCity, Bill.strShipFromState, Bill.strShipFromZipCode),
	CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1 SC.intTicketId FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.intTicketId FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END AS intTicketId,
	CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1 SC.strTicketNumber FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.strTicketNumber FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END AS strTicketNumber,
	INVSHIP.strShipmentNumber,
	0,
	--LOCATION.strLocationName,
	INV.strInvoiceNumber as RecordId,
	CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1 EM.strSplitNumber
			FROM tblGRCustomerStorage GR 
			INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId
			INNER JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId AND SC.intSplitId <> 0
			WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)	
		ELSE
		(SELECT TOP 1 EM.strSplitNumber
			FROM tblSCTicket SC
			INNER JOIN tblEMEntitySplit EM ON SC.intSplitId = EM.intSplitId AND SC.intSplitId <> 0 
			WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		END AS strSplitNumber,
	INV.dtmDate,
	CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1 SC.dblGrossWeight FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.dblGrossWeight FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END AS dblGrossWeight,
	CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1  SC.dblShrink / SC.dblConvertedUOMQty FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)	
		ELSE
		(SELECT TOP 1 SC.dblShrink / SC.dblConvertedUOMQty FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END AS dblShrinkWeight,
	CASE WHEN INVSHIP.intSourceType = 4 THEN
		(SELECT TOP 1  SC.dblGrossWeight - SC.dblTareWeight FROM tblGRCustomerStorage GR INNER JOIN tblSCTicket SC ON GR.intTicketId = SC.intTicketId WHERE intCustomerStorageId = INVSHIPITEM.intSourceId)
		ELSE
		(SELECT TOP 1 SC.dblGrossWeight - SC.dblTareWeight FROM tblSCTicket SC WHERE intTicketId = INVSHIPITEM.intSourceId)
		END AS dblNetWeight,
	INVDTL.dblPrice as dblCost,
	INVDTL.dblQtyShipped as Net,
	UOM.strUnitMeasure,
	INVDTL.dblTotal,
	INVDTL.dblTotalTax,
	CNTRCT.strContractNumber,
	ISNULL((SELECT SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceId = INVDTL.intInvoiceId AND intInventoryShipmentChargeId IS NOT NULL),0)  AS TotalDiscount,
	(INVDTL.dblTotal + INVDTL.dblTotalTax + ISNULL((SELECT SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceId = INVDTL.intInvoiceId AND intInventoryShipmentChargeId IS NOT NULL),0)) as NetDue,
	INV.strInvoiceNumber as strId,
	PYMT.intPaymentId,

	--Settlement Total
	0 as InboundNetWeight,
	INVDTL.dblQtyShipped as OutboundNetWeight,
	0 as InboundGrossDollars,
	INVDTL.dblTotal as OutboundGrossDollars,
	0 as InboundTax,
	INVDTL.dblTotalTax as OutboundTax,
	0 as InboundDiscount,
	ISNULL((SELECT SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceId = INVDTL.intInvoiceId AND intInventoryShipmentChargeId IS NOT NULL),0)  as OutboundDiscount,
	0 as InboundNetDue,
	(INVDTL.dblTotal + INVDTL.dblTotalTax + ISNULL((SELECT SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceId = INVDTL.intInvoiceId AND intInventoryShipmentChargeId IS NOT NULL),0)) as OutboundNetDue,
	0 as VoucherAdjustment,
	ISNULL((SELECT SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceId = INVDTL.intInvoiceId AND (intInventoryShipmentItemId IS NULL AND intInventoryShipmentChargeId IS NULL)),0) AS SalesAdjustment,
	PYMT.dblAmountPaid as CheckAmount

	FROM tblCMBankTransaction BNKTRN
	--INNER JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL ON BNKTRN.strTransactionId = PRINTSPOOL.strTransactionId
	--            AND BNKTRN.intBankAccountId = PRINTSPOOL.intBankAccountId
	INNER JOIN tblAPPayment PYMT ON BNKTRN.strTransactionId =  PYMT.strPaymentRecordNum
	INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
	INNER JOIN tblARInvoice INV ON PYMTDTL.intInvoiceId = INV.intInvoiceId
	INNER JOIN tblARInvoiceDetail INVDTL ON INV.intInvoiceId = INVDTL.intInvoiceId  AND INVDTL.intInventoryShipmentChargeId is null
	INNER JOIN tblICItem Item ON INVDTL.intItemId = Item.intItemId
	INNER JOIN tblICInventoryShipmentItem INVSHIPITEM ON INVDTL.intInventoryShipmentItemId = INVSHIPITEM.intInventoryShipmentItemId
	INNER JOIN tblICInventoryShipment INVSHIP ON INVSHIPITEM.intInventoryShipmentId = INVSHIP.intInventoryShipmentId
	--INNER JOIN tblSCTicket TICKET ON INVSHIPITEM.intSourceId = TICKET.intTicketId
	LEFT JOIN tblCTContractHeader CNTRCT ON INVDTL.intContractHeaderId = CNTRCT.intContractHeaderId
	LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityVendorId] = ISNULL(PYMT.[intEntityVendorId], BNKTRN.intEntityId)
	LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityVendorId] = ENTITY.intEntityId
	LEFT JOIN tblEMEntityEFTInformation EFT ON ENTITY.intEntityId = EFT.intEntityId AND EFT.ysnActive = 1 
	--LEFT JOIN tblEMEntityLocation LOCATION ON VENDOR.intEntityVendorId = LOCATION.intEntityId AND ysnDefaultLocation = 1 
	LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (SElECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	LEFT JOIN tblICItemUOM ItemUOM ON INVDTL.intItemUOMId = ItemUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	--LEFT JOIN tblEMEntitySplit SPLIT ON TICKET.intSplitId = SPLIT.intSplitId AND TICKET.intSplitId <> 0
	WHERE BNKTRN.intBankAccountId = @intBankAccountId  AND BNKTRN.strTransactionId = @strTransactionId
END
