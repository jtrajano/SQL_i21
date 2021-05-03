CREATE PROCEDURE [dbo].[uspApiImportItemContractsFromStaging] (@guiUniqueId UNIQUEIDENTIFIER)
AS

DECLARE @Logs TABLE (strError NVARCHAR(500), strField NVARCHAR(100), strValue NVARCHAR(500), intLineNumber INT NULL, dblTotalAmount NUMERIC(18, 6), intLinePosition INT NULL, strLogLevel NVARCHAR(50))

-- Validations
INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the location with a companyLocationId ''' + CAST(s.intCompanyLocationId AS NVARCHAR(50)) + '''', 'companyLocationId', 'Error', CAST(s.intCompanyLocationId AS NVARCHAR(50))
FROM tblCTApiItemContractStaging s
LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = s.intCompanyLocationId
WHERE c.intCompanyLocationId IS NULL

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the customer with an entityId ''' + CAST(s.intEntityId AS NVARCHAR(50)) + '''', 'entityId', 'Error',  CAST(s.intEntityId AS NVARCHAR(50))
FROM tblCTApiItemContractStaging s
LEFT JOIN tblEMEntity e ON e.intEntityId = s.intEntityId
WHERE e.intEntityId IS NULL

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the item with an itemId ''' + CAST(s.intItemId AS NVARCHAR(50)) + '''', 'itemId', 'Error',  CAST(s.intItemId AS NVARCHAR(50))
FROM tblCTApiItemContractDetailStaging s
LEFT JOIN tblICItem i ON i.intItemId = s.intItemId
WHERE i.intItemId IS NULL

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'The item with an itemId ''' + CAST(s.intItemId AS NVARCHAR(50)) + ''' was already ' + LOWER(i.strStatus), 'itemId', 'Error',  CAST(s.intItemId AS NVARCHAR(50))
FROM tblCTApiItemContractDetailStaging s
INNER JOIN tblICItem i ON i.intItemId = s.intItemId
WHERE i.strStatus IN ('Discontinued', 'Phased Out')

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
DECLARE @dblDollarValue NUMERIC(18,6)
DECLARE @intStagingId INT

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT s.intApiItemContractStagingId
	, CASE s.strContractType WHEN 'Sale' THEN 2 ELSE 1 END
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
	, s.dtmDueDate
	, s.dblDollarValue
FROM tblCTApiItemContractStaging s
WHERE s.guiApiUniqueId = @guiUniqueId

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
, @dblDollarValue

DECLARE @strDollarContractNumber NVARCHAR(3400)
DECLARE @intItemContractHeaderId INT

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber 144, @strDollarContractNumber OUTPUT, @intCompanyLocationId
	
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
		, dblDollarValue
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
		, @dblDollarValue
		, @strDollarContractNumber
		, @guiUniqueId

	SET @intItemContractHeaderId = SCOPE_IDENTITY()

	INSERT INTO tblCTItemContractDetail(intItemContractHeaderId, intItemId, intContractStatusId, intItemUOMId, intLineNo, intTaxGroupId
		,dblApplied, dblAvailable, dblBalance, dblContracted, dblPrice, dblScheduled, dblTax, dblTotal, dtmDeliveryDate, dtmLastDeliveryDate, strItemDescription)
	SELECT @intItemContractHeaderId, ds.intItemId, s.intContractStatusId, ds.intItemUOMId, ds.intLineNo, ds.intTaxGroupId,
		ds.dblApplied, ds.dblAvailable, ds.dblBalance, ds.dblContracted ,ds.dblPrice, ds.dblScheduled, ds.dblTax, ds.dblContracted * ds.dblPrice, ds.dtmDeliveryDate, ds.dtmLastDeliveryDate
		, i.strDescription
	FROM tblCTApiItemContractDetailStaging ds
	LEFT JOIN tblCTContractStatus s ON s.strContractStatus = ds.strContractStatus
	LEFT JOIN tblICItem i ON i.intItemId = ds.intItemId
	WHERE ds.intApiItemContractStagingId = @intStagingId

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
	, @dblDollarValue

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
	, strUnitMeasure INT NULL
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
WHERE h.guiApiUniqueId = @guiUniqueId

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

DELETE FROM tblRestApiItemTaxes WHERE guiTaxesUniqueId = @guiTaxesUniqueId

INSERT INTO @Logs (intLineNumber, dblTotalAmount, strLogLevel, strField)
SELECT h.intItemContractHeaderId, SUM(ISNULL(d.dblTotal, 0)) + SUM(ISNULL(d.dblTax, 0)), 'Ids', h.strContractNumber
FROM tblCTItemContractHeader h
LEFT JOIN tblCTItemContractDetail d ON d.intItemContractHeaderId = h.intItemContractHeaderId
WHERE h.guiApiUniqueId = @guiUniqueId
GROUP BY h.intItemContractHeaderId, h.strContractNumber

SELECT * FROM @Logs

-- Cleanup
DELETE d
FROM tblCTApiItemContractDetailStaging d
INNER JOIN tblCTApiItemContractStaging s ON s.intApiItemContractStagingId = d.intApiItemContractStagingId
WHERE s.guiApiUniqueId = @guiUniqueId

DELETE FROM tblCTApiItemContractStaging
WHERE guiApiUniqueId = @guiUniqueId