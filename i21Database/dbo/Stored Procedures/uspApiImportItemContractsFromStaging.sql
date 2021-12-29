CREATE PROCEDURE [dbo].[uspApiImportItemContractsFromStaging] (@guiApiUniqueId UNIQUEIDENTIFIER)
AS

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'Cannot find the location with a companyLocationId ''' + CAST(s.intCompanyLocationId AS NVARCHAR(50)) + '''', 
	strField = 'companyLocationId', 
	strLogLevel = 'Error', 
	strValue = CAST(s.intCompanyLocationId AS NVARCHAR(50)),
	intLineNumber = NULL,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblCTApiItemContractStaging s
LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = s.intCompanyLocationId
WHERE c.intCompanyLocationId IS NULL
	AND s.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'Cannot find the customer with an entityId ''' + CAST(s.intEntityId AS NVARCHAR(50)) + '''',
	strField = 'entityId', 
	strLogLevel = 'Error', 
	strValue = CAST(s.intEntityId AS NVARCHAR(50)),
	intLineNumber = NULL,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblCTApiItemContractStaging s
LEFT JOIN tblEMEntity e ON e.intEntityId = s.intEntityId
WHERE e.intEntityId IS NULL
	AND s.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'The customer ''' + CAST(e.strName AS NVARCHAR(50)) + ''' is inactive.',
	strField = 'entityId', 
	strLogLevel = 'Error', 
	strValue = CAST(s.intEntityId AS NVARCHAR(50)),
	intLineNumber = NULL,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblCTApiItemContractStaging s
INNER JOIN tblEMEntity e ON e.intEntityId = s.intEntityId
INNER JOIN tblARCustomer c ON c.intEntityId = e.intEntityId
WHERE ISNULL(c.ysnActive, 0) = 0
	AND s.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'Cannot find the item with an itemId ''' + CAST(s.intItemId AS NVARCHAR(50)) + '''',
	strField = 'itemId', 
	strLogLevel = 'Error', 
	strValue = CAST(s.intItemId AS NVARCHAR(50)),
	intLineNumber = NULL,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblCTApiItemContractDetailStaging s
JOIN tblCTApiItemContractStaging ps ON ps.intApiItemContractStagingId = s.intApiItemContractStagingId
LEFT JOIN tblICItem i ON i.intItemId = s.intItemId
WHERE i.intItemId IS NULL
	AND ps.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'The item ''' + i.strItemNo + ''' is not set up for the company location: ''' + pr.strLocationName + '''',
	strField = 'itemId', 
	strLogLevel = 'Error', 
	strValue = CAST(s.intItemId AS NVARCHAR(50)) + ' (' + i.strItemNo + ')',
	intLineNumber = NULL,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblCTApiItemContractDetailStaging s
JOIN tblCTApiItemContractStaging ps ON ps.intApiItemContractStagingId = s.intApiItemContractStagingId
JOIN tblICItem i ON i.intItemId = s.intItemId
LEFT JOIN tblICItemLocation il ON il.intItemId = i.intItemId
	AND il.intLocationId = ps.intCompanyLocationId
LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = il.intLocationId
	AND c.intCompanyLocationId = ps.intCompanyLocationId
LEFT JOIN tblSMCompanyLocation pr ON pr.intCompanyLocationId = ps.intCompanyLocationId
WHERE ps.guiApiUniqueId = @guiApiUniqueId
	AND c.intCompanyLocationId IS NULL

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'The item with an itemId ''' + CAST(s.intItemId AS NVARCHAR(50)) + ''' was already ' + LOWER(i.strStatus),
	strField = 'itemId', 
	strLogLevel = 'Error', 
	strValue = CAST(s.intItemId AS NVARCHAR(50)),
	intLineNumber = NULL,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblCTApiItemContractDetailStaging s
JOIN tblCTApiItemContractStaging ps ON ps.intApiItemContractStagingId = s.intApiItemContractStagingId
INNER JOIN tblICItem i ON i.intItemId = s.intItemId
WHERE i.strStatus IN ('Discontinued', 'Phased Out')
	AND ps.guiApiUniqueId = @guiApiUniqueId 

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'Cannot find the terms with termId ''' + CAST(s.intTermId AS NVARCHAR(50)) + '''', 
	strField = 'termId', 
	strLogLevel = 'Error', 
	strValue = CAST(s.intTermId AS NVARCHAR(50)),
	intLineNumber = NULL,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblCTApiItemContractStaging s
INNER JOIN tblSMTerm t ON t.intTermID = s.intTermId
WHERE t.intTermID IS NULL 
	AND s.intTermId IS NOT NULL
	AND s.guiApiUniqueId = @guiApiUniqueId

IF EXISTS(SELECT * FROM tblRestApiTransformationLog WHERE guiApiUniqueId = @guiApiUniqueId)
	GOTO Logging

-- Transformation
DECLARE @intContractType INT
DECLARE @intEntityId INT
DECLARE @intCurrencyId INT
DECLARE @intCompanyLocationId INT
DECLARE @dtmContractDate DATETIME
DECLARE @dtmExpirationDate DATETIME
DECLARE @strEntryContract NVARCHAR(100)
DECLARE @strCPContract NVARCHAR(100)
DECLARE @intFreightTermiId INT
DECLARE @intCountryId INT
DECLARE @intTermId INT
DECLARE @intSalespersonId INT
DECLARE @intContractTextId INT
DECLARE @ysnSigned BIT
DECLARE @ysnPrinted BIT
DECLARE @intOpportunityNameId INT
DECLARE @intLineOfBusinessId INT
DECLARE @dtmDueDate DATETIME
DECLARE @intStagingId INT

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT s.intApiItemContractStagingId
	, 2
	, s.intEntityId
	, s.intCurrencyId
	, s.intCompanyLocationId
	, s.dtmContractDate
	, s.dtmExpirationDate
	, ISNULL(s.strEntryContract, '')
	, ISNULL(s.strCPContract, '')
	, s.intFreightTermId
	, s.intCountryId
	, s.intTermId
	, s.intSalespersonId
	, s.intContractTextId
	, ISNULL(s.ysnSigned, 0)
	, ISNULL(s.ysnPrinted, 0)
	, s.intOpportunityNameId
	, s.intLineOfBusinessId
	, COALESCE(s.dtmDueDate, t.dtmDueDate)
FROM tblCTApiItemContractStaging s
LEFT JOIN tblSMTerm t ON t.intTermID = s.intTermId
WHERE s.guiApiUniqueId = @guiApiUniqueId

OPEN CUR

FETCH NEXT FROM cur INTO
  @intStagingId
, @intContractType
, @intEntityId 
, @intCurrencyId 
, @intCompanyLocationId 
, @dtmContractDate 
, @dtmExpirationDate 
, @strEntryContract 
, @strCPContract 
, @intFreightTermiId 
, @intCountryId 
, @intTermId 
, @intSalespersonId 
, @intContractTextId 
, @ysnSigned 
, @ysnPrinted 
, @intOpportunityNameId 
, @intLineOfBusinessId 
, @dtmDueDate 

DECLARE @strItemContractNumber NVARCHAR(3400)
DECLARE @intItemContractHeaderId INT

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber 144, @strItemContractNumber OUTPUT, @intCompanyLocationId
	
	INSERT INTO tblCTItemContractHeader(
		  intConcurrencyId
		, intContractTypeId
		, strContractCategoryId
		, intEntityId
		, intCurrencyId
		, intCompanyLocationId
		, intShipToLocationId
		, dtmContractDate
		, dtmExpirationDate
		, strEntryContract
		, strCPContract
		, intFreightTermId
		, intCountryId
		, intTermId
		, intSalespersonId
		, intContractTextId
		, ysnSigned
		, ysnPrinted
		, intOpportunityId
		, intLineOfBusinessId
		, dtmDueDate
		, strContractNumber
		, guiApiUniqueId)
	SELECT 1
		, @intContractType
		, 'Item'
		, @intEntityId 
		, @intCurrencyId 
		, @intCompanyLocationId 
		, (SELECT TOP 1 intEntityLocationId FROM tblEMEntityLocation WHERE intEntityId = @intEntityId AND ysnDefaultLocation = 1)
		, @dtmContractDate 
		, @dtmExpirationDate 
		, @strEntryContract 
		, @strCPContract 
		, @intFreightTermiId 
		, @intCountryId 
		, @intTermId 
		, @intSalespersonId 
		, @intContractTextId 
		, @ysnSigned 
		, @ysnPrinted 
		, @intOpportunityNameId 
		, @intLineOfBusinessId 
		, @dtmDueDate 
		, @strItemContractNumber
		, @guiApiUniqueId

	SET @intItemContractHeaderId = SCOPE_IDENTITY()

	INSERT INTO tblCTItemContractDetail(
		  intItemContractHeaderId
		, intItemId
		, intContractStatusId
		, intItemUOMId
		, intLineNo
		, intTaxGroupId
		, dblApplied
		, dblAvailable
		, dblBalance
		, dblContracted
		, dblPrice
		, dblScheduled
		, dblTax
		, dblTotal
		, dtmDeliveryDate
		-- , dtmLastDeliveryDate
		, strItemDescription)
	SELECT
		  @intItemContractHeaderId
		, ds.intItemId
		, s.intContractStatusId
		, ds.intItemUOMId
		, ds.intLineNo
		, ds.intTaxGroupId
		, ISNULL(ds.dblApplied, 0)
		--, ISNULL(ds.dblAvailable, 0)
		, ISNULL(ds.dblContracted, 0)
		, ISNULL(ds.dblBalance, 0)
		, ISNULL(ds.dblContracted, 0)
		, ds.dblPrice
		, ISNULL(ds.dblScheduled, 0)
		, ISNULL(ds.dblTax, 0)
		, ISNULL(ds.dblContracted, 0) * ds.dblPrice
		, ds.dtmDeliveryDate
		-- , ds.dtmLastDeliveryDate
		, i.strDescription
	FROM tblCTApiItemContractDetailStaging ds
	JOIN tblCTApiItemContractStaging ps ON ps.intApiItemContractStagingId = ds.intApiItemContractStagingId
	LEFT JOIN tblCTContractStatus s ON s.strContractStatus = ds.strContractStatus
	LEFT JOIN tblICItem i ON i.intItemId = ds.intItemId
	WHERE ds.intApiItemContractStagingId = @intStagingId
		AND ps.guiApiUniqueId = @guiApiUniqueId

	FETCH NEXT FROM cur INTO
	  @intStagingId
	, @intContractType
	, @intEntityId 
	, @intCurrencyId 
	, @intCompanyLocationId 
	, @dtmContractDate 
	, @dtmExpirationDate 
	, @strEntryContract 
	, @strCPContract 
	, @intFreightTermiId 
	, @intCountryId 
	, @intTermId 
	, @intSalespersonId 
	, @intContractTextId 
	, @ysnSigned 
	, @ysnPrinted 
	, @intOpportunityNameId 
	, @intLineOfBusinessId 
	, @dtmDueDate 

END

CLOSE cur
DEALLOCATE cur

-- Calculate taxes & totals
DECLARE @guiTaxesUniqueId UNIQUEIDENTIFIER = NEWID()

DECLARE @tblRestApiItemTaxes TABLE (
	  intTransactionDetailTaxId INT NULL
	, intInvoiceDetailId INT NULL
	, intTaxGroupMasterId INT NULL
	, intTaxGroupId INT  NULL
	, intTaxCodeId INT  NULL
	, intTaxClassId INT  NULL
	, strTaxableByOtherTaxes NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strCalculationMethod NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblRate NUMERIC(18, 6) NULL
	, dblBaseRate NUMERIC(18, 6) NULL
	, dblExemptionPercent NUMERIC(18, 6) NULL
	, dblTax NUMERIC(18, 6) NULL
	, dblAdjustedTax NUMERIC(18, 6) NULL
	, dblBaseAdjustedTax NUMERIC(18, 6) NULL
	, intSalesTaxAccountId INT NULL
	, intSalesTaxExemptionAccountId INT NULL
	, ysnSeparateOnInvoice BIT NULL
	, ysnCheckoffTax BIT NULL
	, strTaxCode NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, ysnTaxExempt BIT NULL
	, ysnTaxOnly BIT NULL
	, ysnInvalidSetup  BIT NULL
	, strTaxGroup NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strNotes NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL
	, intUnitMeasureId INT NULL
	, strUnitMeasure NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL
	, strTaxClass NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, ysnAddToCost BIT NULL
)

DECLARE dcur CURSOR LOCAL FAST_FORWARD
FOR
SELECT 
	  d.intItemContractDetailId
	, d.intItemId
	, h.intCompanyLocationId
	, h.intEntityId
	, h.intShipToLocationId
	, h.dtmContractDate
	, d.intTaxGroupId
	, h.intFreightTermId
	, d.intItemUOMId
	, h.intCurrencyId
FROM tblCTItemContractDetail d
INNER JOIN tblCTItemContractHeader h ON h.intItemContractHeaderId = d.intItemContractHeaderId
WHERE h.guiApiUniqueId = @guiApiUniqueId

OPEN dcur

DECLARE @ItemContractDetailId INT
DECLARE @ItemId INT
DECLARE @LocationId INT
DECLARE @CustomerId INT
DECLARE @CustomerLocationId INT
DECLARE @TransactionDate DATETIME
DECLARE @TaxGroupId INT
DECLARE @FreightTermId INT
DECLARE @ItemUOMId INT
DECLARE @CurrencyId INT

FETCH NEXT FROM dcur INTO
	  @ItemContractDetailId
	, @ItemId
	, @LocationId
	, @CustomerId
	, @CustomerLocationId
	, @TransactionDate
	, @TaxGroupId
	, @FreightTermId
	, @ItemUOMId
	, @CurrencyId

WHILE @@FETCH_STATUS = 0
BEGIN
	DELETE FROM @tblRestApiItemTaxes
	INSERT INTO @tblRestApiItemTaxes (
		  intTransactionDetailTaxId
		, intInvoiceDetailId
		, intTaxGroupMasterId
		, intTaxGroupId
		, intTaxCodeId
		, intTaxClassId
		, strTaxableByOtherTaxes
		, strCalculationMethod
		, dblRate
		, dblBaseRate
		, dblExemptionPercent
		, dblTax
		, dblAdjustedTax
		, dblBaseAdjustedTax
		, intSalesTaxAccountId
		, intSalesTaxExemptionAccountId
		, ysnSeparateOnInvoice
		, ysnCheckoffTax
		, strTaxCode
		, ysnTaxExempt
		, ysnTaxOnly
		, ysnInvalidSetup
		, strTaxGroup
		, strNotes
		, intUnitMeasureId
		, strUnitMeasure
		, strTaxClass
		, ysnAddToCost)
	EXEC [dbo].[uspARGetItemTaxes]
		@ItemId= @ItemId,
		@LocationId= @LocationId,
		@CustomerId= @CustomerId,
		@CustomerLocationId= default,
		@TransactionDate= @TransactionDate,
		@TaxGroupId= @TaxGroupId,
		@SiteId= default,
		@FreightTermId= @FreightTermId,
		@CardId= default,
		@VehicleId= default,
		@ItemUOMId= @ItemUOMId,
		@CurrencyId= @CurrencyId,
		@CurrencyExchangeRateTypeId= default,
		@CurrencyExchangeRate= 1

	INSERT INTO tblRestApiItemTaxes (
		  guiTaxesUniqueId
		, intItemContractDetailId
		, intTransactionDetailTaxId
		, intInvoiceDetailId
		, intTaxGroupMasterId
		, intTaxGroupId
		, intTaxCodeId
		, intTaxClassId
		, strTaxableByOtherTaxes
		, strCalculationMethod
		, dblRate
		, dblBaseRate
		, dblExemptionPercent
		, dblTax
		, dblAdjustedTax
		, dblBaseAdjustedTax
		, intSalesTaxAccountId
		, intSalesTaxExemptionAccountId
		, ysnSeparateOnInvoice
		, ysnCheckoffTax
		, strTaxCode
		, ysnTaxExempt
		, ysnTaxOnly
		, ysnInvalidSetup
		, strTaxGroup
		, strNotes
		, intUnitMeasureId
		, strUnitMeasure
		, strTaxClass
		, ysnAddToCost)
	SELECT @guiTaxesUniqueId, @ItemContractDetailId, *
	FROM @tblRestApiItemTaxes

	-- UPDATE tblRestApiItemTaxes
	-- SET guiTaxesUniqueId = @guiTaxesUniqueId
	-- WHERE guiTaxesUniqueId IS NULL

	UPDATE ct
	SET dblTax = dbo.fnRestApiCalculateItemtax(ct.dblContracted, ct.dblPrice, ct.intItemUOMId, NULL, @guiTaxesUniqueId, t.intRestApiItemTaxesId)
	FROM tblCTItemContractDetail ct
	INNER JOIN tblRestApiItemTaxes t ON t.intItemContractDetailId = ct.intItemContractDetailId
		AND t.guiTaxesUniqueId = @guiTaxesUniqueId
	WHERE ct.intItemContractDetailId = @ItemContractDetailId

	UPDATE ct
	SET dblTotal = (ct.dblContracted * ct.dblPrice)
	FROM tblCTItemContractDetail ct
	WHERE ct.intItemContractDetailId = @ItemContractDetailId

	FETCH NEXT FROM dcur INTO
		  @ItemContractDetailId
		, @ItemId
		, @LocationId
		, @CustomerId
		, @CustomerLocationId
		, @TransactionDate
		, @TaxGroupId
		, @FreightTermId
		, @ItemUOMId
		, @CurrencyId
END

CLOSE dcur
DEALLOCATE dcur

Logging:

DELETE FROM tblRestApiItemTaxes WHERE guiTaxesUniqueId = @guiTaxesUniqueId

INSERT INTO tblRestApiTransformationDelta (guiTransformationDeltaId,intTransactionId, strTransactionNo, dblTotalAmount,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	intTransactionId = h.intItemContractHeaderId,
	strTransactionNo = h.strContractNumber, 
	dblTotalAmount = SUM(ISNULL(d.dblTotal, 0)) + SUM(ISNULL(d.dblTax, 0)),
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblCTItemContractHeader h
LEFT JOIN tblCTItemContractDetail d ON d.intItemContractHeaderId = h.intItemContractHeaderId
WHERE h.guiApiUniqueId = @guiApiUniqueId
GROUP BY h.intItemContractHeaderId, h.strContractNumber

SELECT * FROM tblRestApiTransformationLog WHERE guiApiUniqueId = @guiApiUniqueId

-- Cleanup
DELETE d
FROM tblCTApiItemContractDetailStaging d
INNER JOIN tblCTApiItemContractStaging s ON s.intApiItemContractStagingId = d.intApiItemContractStagingId
WHERE s.guiApiUniqueId = @guiApiUniqueId

DELETE FROM tblCTApiItemContractStaging
WHERE guiApiUniqueId = @guiApiUniqueId