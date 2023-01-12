CREATE PROCEDURE [dbo].[uspARInsertInvoiceTransactionLink]
	@InvoiceIds   InvoiceId READONLY
AS  
 
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF
 
DECLARE @IIDs					InvoiceId
DECLARE @tblTransactionLinks    udtICTransactionLinks
 
DELETE FROM @IIDs
INSERT INTO @IIDs 
SELECT * FROM @InvoiceIds
 
INSERT INTO @tblTransactionLinks (
	  intSrcId
	, strSrcTransactionNo
	, strSrcTransactionType
	, strSrcModuleName
	, intDestId
	, strDestTransactionNo
	, strDestTransactionType
	, strDestModuleName
	, strOperation
)
SELECT intSrcId					= SRC.intTransactionId
	, strSrcTransactionNo       = SRC.strTransactionNumber
	, strSrcTransactionType     = SRC.strTransactionType
	, strSrcModuleName          = SRC.strModuleName
	, intDestId                 = MAIN.intInvoiceId
	, strDestTransactionNo      = MAIN.strInvoiceNumber
	, strDestTransactionType    = 'Invoice'
	, strDestModuleName         = 'Accounts Receivable'
	, strOperation              = 'Process'
FROM tblARInvoice MAIN
INNER JOIN @IIDs II ON MAIN.intInvoiceId = II.intHeaderId
CROSS APPLY (
	--FROM SO
	SELECT intTransactionId			= SO.intSalesOrderId
		, strTransactionNumber		= SO.strSalesOrderNumber
		, strTransactionType		= 'Sales Order'
		, strModuleName				= 'Accounts Receivable'
	FROM tblARInvoice INVOICE
	INNER JOIN tblSOSalesOrder SO ON INVOICE.intSalesOrderId = SO.intSalesOrderId
	WHERE INVOICE.intInvoiceId = MAIN.intInvoiceId
	  AND INVOICE.intSalesOrderId IS NOT NULL
	  AND SO.strTransactionType = 'Order'
 
	UNION ALL
 
	--FROM IS
	SELECT DISTINCT intTransactionId		= ISS.intInventoryShipmentId
				  , strTransactionNumber	= ISS.strShipmentNumber 
				  , strTransactionType		= 'Inventory Shipment'
				  , strModuleName			= 'Inventory'
	FROM tblARInvoiceDetail ID
	INNER JOIN tblICInventoryShipmentItem ISI ON ISI.intInventoryShipmentItemId = ID.intInventoryShipmentItemId
	INNER JOIN tblICInventoryShipment ISS ON ISS.intInventoryShipmentId = ISI.intInventoryShipmentId
	WHERE ID.intInvoiceId = MAIN.intInvoiceId
	  AND ID.intInventoryShipmentItemId IS NOT NULL
 
	UNION ALL
 
	--FROM CF
	SELECT intTransactionId		= CF.intTransactionId
		, strTransactionNumber	= ISNULL(CF.strInvoiceReportNumber, CF.strTransactionId)
		, strTransactionType	= INVOICE.strTransactionType
		, strModuleName			= 'Card Fueling'
	FROM tblARInvoice INVOICE
	INNER JOIN tblCFTransaction CF ON INVOICE.intTransactionId = CF.intTransactionId
	WHERE INVOICE.intInvoiceId = MAIN.intInvoiceId
	  AND INVOICE.strType IN ('CF Tran', 'CF Invoice')
 
	UNION ALL
 
	--METER BILLING
	SELECT intTransactionId		= MR.intMeterReadingId
		, strTransactionNumber	= MR.strTransactionId
		, strTransactionType	= 'Meter Billing'
		, strModuleName         = 'Meter Billing'
	FROM tblMBMeterReading MR
	WHERE MR.intInvoiceId IS NOT NULL
	  AND MR.intInvoiceId = MAIN.intInvoiceId
 
	UNION ALL
 
	--TRANSPORTS
	SELECT intTransactionId		= LH.intLoadHeaderId
		, strTransactionNumber	= LH.strTransaction
		, strTransactionType	= 'Transport Delivery'
		, strModuleName         = 'Transport'
	FROM tblTRLoadDistributionHeader DH
	INNER JOIN tblTRLoadHeader LH ON DH.intLoadHeaderId = LH.intLoadHeaderId
	WHERE DH.intInvoiceId IS NOT NULL
	  AND DH.intInvoiceId = MAIN.intInvoiceId

	UNION ALL

	--PATRONAGE
	SELECT intTransactionId		= PIS.intIssueStockId
		, strTransactionNumber	= PIS.strIssueNo
		, strTransactionType	= 'Issue Stock'
		, strModuleName         = 'Patronage'
	FROM tblPATIssueStock PIS	
	WHERE PIS.intInvoiceId IS NOT NULL
	  AND PIS.intInvoiceId = MAIN.intInvoiceId
) SRC
WHERE ISNULL(II.ysnForDelete, 0) = 0
 
EXEC dbo.uspICAddTransactionLinks @tblTransactionLinks
 
--DELETE FROM INVENTORY LINK
WHILE EXISTS (SELECT TOP 1 NULL FROM @IIDs WHERE ISNULL(ysnForDelete, 0) = 1)
	BEGIN
		DECLARE @intInvoiceId		INT = NULL
			  , @strInvoiceNumber	NVARCHAR(100) = NULL
 
		SELECT TOP 1 @intInvoiceId		= INV.intInvoiceId
				   , @strInvoiceNumber	= INV.strInvoiceNumber
		FROM @IIDs II
		INNER JOIN tblARInvoice INV ON II.intHeaderId = INV.intInvoiceId
		WHERE ISNULL(II.ysnForDelete, 0) = 1
 
		EXEC dbo.[uspICDeleteTransactionLinks] @intInvoiceId, @strInvoiceNumber, 'Invoice', 'Accounts Receivable'
 
		DELETE 
		FROM @IIDs 
		WHERE intHeaderId = @intInvoiceId 
		AND ISNULL(ysnForDelete, 0) = 1
	END