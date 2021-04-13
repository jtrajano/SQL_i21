CREATE PROCEDURE [dbo].[uspApiImportItemContractsFromStaging] (@guiUniqueId UNIQUEIDENTIFIER)
AS

DECLARE @Logs TABLE (strError NVARCHAR(500), strField NVARCHAR(100), strValue NVARCHAR(500), intLineNumber INT NULL, intLinePosition INT NULL, strLogLevel NVARCHAR(50))

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
		ds.dblApplied, ds.dblAvailable, ds.dblBalance, ds.dblContracted ,ds.dblPrice, ds.dblScheduled, ds.dblTax, ds.dblTotal, ds.dtmDeliveryDate, ds.dtmLastDeliveryDate
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

SELECT * FROM @Logs

-- Cleanup
DELETE d
FROM tblCTApiItemContractDetailStaging d
INNER JOIN tblCTApiItemContractStaging s ON s.intApiItemContractStagingId = d.intApiItemContractStagingId
WHERE s.guiApiUniqueId = @guiUniqueId

DELETE FROM tblCTApiItemContractStaging
WHERE guiApiUniqueId = @guiUniqueId