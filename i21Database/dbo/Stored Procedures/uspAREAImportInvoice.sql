CREATE PROCEDURE [dbo].[uspAREAImportInvoice]
	@InvoiceEAEntries	InvoiceEAStagingTable	READONLY
AS

DECLARE @InvoiceEntries		AS InvoiceStagingTable
DECLARE @LineItemTaxEntries	AS LineItemTaxDetailStagingTable
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
FROM @InvoiceEAEntries I
INNER JOIN tblARCustomer C ON RTRIM(LTRIM(I.strCustomerNumber)) = RTRIM(LTRIM(C.strCustomerNumber))
INNER JOIN tblSMCompanyLocation CL ON RTRIM(LTRIM(I.strCompanyLocation)) = RTRIM(LTRIM(CL.strLocationNumber))
LEFT JOIN tblICItem ITEM ON I.strItemNo = ITEM.strItemNo
LEFT JOIN tblICUnitMeasure UOM ON I.intUnitMeasureId = UOM.intUnitMeasureId
LEFT JOIN tblICItemUOM IUOM ON ITEM.intItemId = IUOM.intItemId AND I.intUnitMeasureId = IUOM.intUnitMeasureId

DELETE IE
FROM @InvoiceEntries IE
INNER JOIN tblARInvoice I ON IE.strInvoiceOriginId = I.strInvoiceOriginId

IF EXISTS (SELECT TOP 1 NULL FROM @InvoiceEntries)
	EXEC uspARProcessInvoicesByBatch @InvoiceEntries, @LineItemTaxEntries, @intUserId, 15, 1
ELSE
	RAISERROR('No Invoices to import', 16, 1)

RETURN 0