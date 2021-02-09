CREATE PROCEDURE [dbo].[uspAREAImportInvoice]
	@InvoiceEAEntries	InvoiceEAStagingTable	READONLY
AS

DECLARE @InvoiceEntries		AS InvoiceStagingTable
DECLARE @LineItemTaxEntries	AS LineItemTaxDetailStagingTable
DECLARE @ErrorMessage		NVARCHAR(250)	= NULL
DECLARE @LogId				INT				= NULL
DECLARE @intUserId	INT = (SELECT TOP 1 intEntityId FROM tblSMUserSecurity)

INSERT INTO @InvoiceEntries (
	  intId
	, strTransactionType
	, strType
	, strSourceTransaction
	, strSourceId
	, intEntityCustomerId
	, intCompanyLocationId
	, intEntityId
	, dtmDate
	, dtmDueDate
	, dtmShipDate
	, dtmPostDate
	, strInvoiceOriginId
	, strComments
	, ysnImpactInventory
	, strAcresApplied		
	, strNutrientAnalysis	
	, strBillingMethod		
	, strApplicatorLicense
	, strPONumber	

	, intItemId
	, intItemUOMId
	, intPriceUOMId
	, strItemDescription
	, strSubFormula	
	, dblQtyShipped
	, dblDiscount
	, dblPrice
	, ysnRefreshPrice
	, ysnAllowRePrice
	, ysnRecomputeTax
	, ysnConvertToStockUOM
	, strBinNumber
	, strGroupNumber
	, strFeedDiet
)
SELECT intId				= I.intId 
	, strTransactionType	= I.strTransactionType
	, strType				= I.strType
	, strSourceTransaction	= I.strSourceTransaction
	, strSourceId			= I.strSourceId
	, intEntityCustomerId	= C.intEntityId
	, intCompanyLocationId	= CL.intCompanyLocationId
	, intEntityId			= @intUserId
	, dtmDate				= I.dtmDate
	, dtmDueDate			= I.dtmDueDate
	, dtmShipDate			= ISNULL(I.dtmShipDate, I.dtmDate)
	, dtmPostDate			= ISNULL(I.dtmPostDate, I.dtmDate)
	, strInvoiceOriginId	= I.strInvoiceOriginId
	, strComments			= I.strComments
	, ysnImpactInventory	= I.ysnImpactInventory
	, strAcresApplied		= I.strAcresApplied
	, strNutrientAnalysis	= I.strNutrientAnalysis
	, strBillingMethod		= I.strBillingMethod
	, strApplicatorLicense	= I.strApplicatorLicense
	, strPONumber			= I.strPONumber

	, intItemId				= ITEM.intItemId
	, intItemUOMId			= IUOM.intItemUOMId
	, intPriceUOMId			= IUOM.intItemUOMId
	, strItemDescription	= I.strItemDescription
	, strSubFormula			= I.strSubFormula
	, dblQtyShipped			= I.dblQtyShipped
	, dblDiscount			= I.dblDiscount
	, dblPrice				= I.dblPrice
	, ysnRefreshPrice		= I.ysnRefreshPrice
	, ysnAllowRePrice		= I.ysnAllowRePrice
	, ysnRecomputeTax		= I.ysnRecomputeTax
	, ysnConvertToStockUOM	= I.ysnConvertToStockUOM
	, strBinNumber			= I.strBinNumber
	, strGroupNumber		= I.strGroupNumber
	, strFeedDiet			= I.strFeedDiet
FROM @InvoiceEAEntries I
INNER JOIN tblARCustomer C ON RTRIM(LTRIM(I.strCustomerNumber)) = RTRIM(LTRIM(C.strCustomerNumber)) OR C.intEntityId = ISNULL(I.intEntityId, 0)
INNER JOIN tblSMCompanyLocation CL ON RTRIM(LTRIM(I.strCompanyLocation)) = RTRIM(LTRIM(CL.strLocationNumber))
LEFT JOIN tblICItem ITEM ON I.strItemNo = ITEM.strItemNo
LEFT JOIN tblICUnitMeasure UOM ON I.intUnitMeasureId = UOM.intUnitMeasureId
LEFT JOIN tblICItemUOM IUOM ON ITEM.intItemId = IUOM.intItemId AND I.intUnitMeasureId = IUOM.intUnitMeasureId

IF EXISTS (SELECT TOP 1 NULL FROM @InvoiceEntries IE INNER JOIN tblARInvoice I ON IE.strInvoiceOriginId = I.strInvoiceOriginId)
	RAISERROR('Invoice already exists', 16, 1)
ELSE IF NOT EXISTS (SELECT TOP 1 NULL FROM @InvoiceEAEntries IE INNER JOIN tblARCustomer C ON RTRIM(LTRIM(IE.strCustomerNumber)) = RTRIM(LTRIM(C.strCustomerNumber)) OR C.intEntityId = ISNULL(IE.intEntityId, 0))
	 RAISERROR('Customer not found', 16, 1)
ELSE IF NOT EXISTS (SELECT TOP 1 NULL FROM @InvoiceEAEntries IE INNER JOIN tblSMCompanyLocation CL ON RTRIM(LTRIM(IE.strCompanyLocation)) = RTRIM(LTRIM(CL.strLocationNumber)))
	RAISERROR('Location not found', 16, 1)
ELSE IF NOT EXISTS (SELECT TOP 1 NULL FROM @InvoiceEAEntries WHERE strSourceTransaction IN ('Sale OffSite','Settle Storage','Process Grain Storage','Transfer Storage','Load/Shipment Schedules','Credit Card Reconciliation', 'CF Invoice', 'Direct'))
	RAISERROR('Invalid source transaction', 16, 1)
ELSE IF NOT EXISTS (SELECT TOP 1 NULL FROM @InvoiceEntries)
	RAISERROR('No invoice to import', 16, 1)
ELSE 
BEGIN
	EXEC uspARProcessInvoicesByBatch @InvoiceEntries, @LineItemTaxEntries, @intUserId, 15, 1, NULL, @ErrorMessage OUTPUT, @LogId OUTPUT

	SET @ErrorMessage = ISNULL(@ErrorMessage, 'Failed to import invoice')
	IF NOT EXISTS(SELECT TOP 1 NULL FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @LogId)
		RAISERROR(@ErrorMessage, 16, 1)
END

RETURN 0