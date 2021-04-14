CREATE PROCEDURE [dbo].[uspRestApiImportInvoice] (@guiUniqueId UNIQUEIDENTIFIER)
AS

DECLARE @InvoiceEntries		AS InvoiceStagingTable
DECLARE @LineItemTaxEntries	AS LineItemTaxDetailStagingTable
DECLARE @ErrorMessage		NVARCHAR(250)	= NULL
DECLARE @LogId				INT				= NULL
DECLARE @intUserId	INT = (SELECT TOP 1 intEntityId FROM tblSMUserSecurity)

DECLARE @Logs TABLE (strError NVARCHAR(500), strField NVARCHAR(100), strValue NVARCHAR(500), intLineNumber INT NULL, intLinePosition INT NULL, strLogLevel NVARCHAR(50))

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'The item does not exists.', 'itemId', 'Error', e.strItemNo
FROM tblRestApiInvoiceStaging e
LEFT JOIN tblICItem i ON i.intItemId = e.intItemId
WHERE e.guiUniqueId = @guiUniqueId
	AND (e.intDollarContractDetailId IS NULL AND e.intDollarContractHeaderId IS NULL)
	AND i.intItemId IS NULL
	AND e.intItemId IS NOT NULL

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'The item does not exists.', 'itemId', 'Error', e.strItemNo
FROM tblRestApiInvoiceStaging e
LEFT JOIN tblICItem i ON i.strItemNo = e.strItemNo
WHERE e.guiUniqueId = @guiUniqueId
	AND (e.intDollarContractDetailId IS NULL AND e.intDollarContractHeaderId IS NULL)
	AND i.intItemId IS NULL
	AND e.strItemNo IS NOT NULL

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Invalid item contract ID.', 'itemContractDetailId', 'Error', CAST(e.intItemContractDetailId AS NVARCHAR(50))
FROM tblRestApiInvoiceStaging e
LEFT JOIN tblCTItemContractDetail i ON i.intItemContractDetailId = e.intItemContractDetailId
	AND i.intItemContractHeaderId = e.intItemContractHeaderId
WHERE e.guiUniqueId = @guiUniqueId
	AND (e.intItemContractDetailId IS NOT NULL AND e.intItemContractHeaderId IS NOT NULL)
	AND i.intItemContractDetailId IS NULL

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Invalid dollar contract ID.', 'dollarContractDetailId', 'Error', CAST(e.intDollarContractDetailId AS NVARCHAR(50))
FROM tblRestApiInvoiceStaging e
LEFT JOIN tblCTItemContractHeaderCategory c ON c.intItemCategoryId = e.intDollarContractDetailId
	AND c.intItemContractHeaderId = e.intDollarContractHeaderId
WHERE e.guiUniqueId = @guiUniqueId
	AND (e.intDollarContractDetailId IS NOT NULL AND e.intDollarContractHeaderId IS NOT NULL)
	AND c.intCategoryId IS NULL

IF NOT EXISTS (SELECT TOP 1 NULL FROM tblRestApiInvoiceStaging IE INNER JOIN tblARCustomer C ON RTRIM(LTRIM(IE.strCustomerNumber)) = RTRIM(LTRIM(C.strCustomerNumber)) OR C.intEntityId = ISNULL(IE.intEntityId, 0) WHERE guiUniqueId = @guiUniqueId)
BEGIN
	INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
	SELECT 'The customer does not exists. Please ensure that the entityId is correct.', 'entityId', 'Error',
		(SELECT TOP 1 ISNULL(CAST(IE.intEntityId AS NVARCHAR(200)), IE.strCustomerNumber) FROM tblRestApiInvoiceStaging IE LEFT JOIN tblARCustomer C ON RTRIM(LTRIM(IE.strCustomerNumber)) = RTRIM(LTRIM(C.strCustomerNumber)) OR C.intEntityId = ISNULL(IE.intEntityId, 0) WHERE guiUniqueId = @guiUniqueId)
END

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'The location does not exists.', 'locationId', 'Error', IE.strCompanyLocation
FROM tblRestApiInvoiceStaging IE
LEFT JOIN tblSMCompanyLocation CL ON RTRIM(LTRIM(IE.strCompanyLocation)) = RTRIM(LTRIM(CL.strLocationNumber)) 
	OR RTRIM(LTRIM(IE.strCompanyLocation)) = RTRIM(LTRIM(CL.strLocationName))
WHERE IE.guiUniqueId = @guiUniqueId
	AND NULLIF(IE.intLocationId, 0) IS NULL
	AND CL.intCompanyLocationId IS NULL

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Invalid locationId.', 'locationId', 'Error', NULLIF(IE.intLocationId, 0)
FROM tblRestApiInvoiceStaging IE
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = NULLIF(IE.intLocationId, 0)
WHERE IE.guiUniqueId = @guiUniqueId
	AND NULLIF(IE.intLocationId, 0) IS NOT NULL
	AND CL.intCompanyLocationId IS NULL

IF NOT EXISTS(SELECT * FROM @Logs)
BEGIN
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
	, ysnPost
	, intItemContractHeaderId
	, intItemContractDetailId
)
SELECT 
	  intId					= I.intRestApiInvoiceStagingId
	, strTransactionType	= I.strTransactionType
	, strType				= I.strType
	, strSourceTransaction	= I.strSourceTransaction
	, strSourceId			= I.strSourceId
	, intEntityCustomerId	= C.intEntityId
	, intCompanyLocationId	= COALESCE(CLL.intCompanyLocationId, CL.intCompanyLocationId)
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
	, ysnPost				= CAST(0 AS BIT)
	, intItemContractHeaderId = I.intItemContractHeaderId
	, intItemContractDetailId = I.intItemContractDetailId
FROM tblRestApiInvoiceStaging I
INNER JOIN tblARCustomer C ON RTRIM(LTRIM(I.strCustomerNumber)) = RTRIM(LTRIM(C.strCustomerNumber)) OR C.intEntityId = ISNULL(I.intEntityId, 0)
LEFT JOIN tblSMCompanyLocation CLL ON CLL.intCompanyLocationId = I.intLocationId
LEFT JOIN tblSMCompanyLocation CL ON RTRIM(LTRIM(I.strCompanyLocation)) = RTRIM(LTRIM(CL.strLocationNumber)) OR RTRIM(LTRIM(I.strCompanyLocation)) = RTRIM(LTRIM(CL.strLocationName))
LEFT JOIN tblICItem ITEM ON I.strItemNo = ITEM.strItemNo
LEFT JOIN tblICUnitMeasure UOM ON I.intUnitMeasureId = UOM.intUnitMeasureId
LEFT JOIN tblICItemUOM IUOM ON ITEM.intItemId = IUOM.intItemId AND I.intUnitMeasureId = IUOM.intUnitMeasureId
WHERE I.guiUniqueId = @guiUniqueId
END

IF EXISTS (SELECT TOP 1 NULL FROM @InvoiceEntries IE INNER JOIN tblARInvoice I ON IE.strInvoiceOriginId = I.strInvoiceOriginId)
BEGIN
	INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
	SELECT 'The invoice already exists. Ensure that the invoiceOriginId is not yet in the system.', 'invoiceOriginId', 'Error',
		(SELECT TOP 1 IE.strInvoiceOriginId FROM @InvoiceEntries IE LEFT JOIN tblARInvoice I ON IE.strInvoiceOriginId = I.strInvoiceOriginId)
END

IF NOT EXISTS (SELECT TOP 1 NULL FROM @InvoiceEntries)
BEGIN
	IF NOT EXISTS(SELECT * FROM @Logs)
		INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
		SELECT 'There are no invoices to import.', null, 'Error', NULL
END
ELSE 
BEGIN
	EXEC uspARProcessInvoicesByBatch @InvoiceEntries, @LineItemTaxEntries, @intUserId, 15, 1, NULL, @ErrorMessage OUTPUT, @LogId OUTPUT
	
	SET @ErrorMessage = ISNULL(@ErrorMessage, 'Failed to import invoice')
	IF NOT EXISTS(SELECT TOP 1 NULL FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @LogId)
	BEGIN
		INSERT INTO @Logs (strError, strLogLevel)
		SELECT @ErrorMessage, 'Error'
		RAISERROR (@ErrorMessage, 16, 1)
	END
	ELSE
	BEGIN
		INSERT INTO @Logs (intLineNumber, strLogLevel)
		SELECT i.intInvoiceId, 'Ids'
		FROM tblARInvoice i
		INNER JOIN tblARInvoiceIntegrationLogDetail d ON i.intInvoiceId = d.intInvoiceId
		WHERE d.intIntegrationLogId = @LogId 
		  AND d.ysnSuccess = 1
		  AND d.ysnHeader = 1
	END
END

DELETE FROM tblRestApiInvoiceStaging WHERE guiUniqueId = @guiUniqueId
SELECT * FROM @Logs

RETURN 0