CREATE PROCEDURE [dbo].[uspApiImportDollarContractsFromStaging] (@guiUniqueId UNIQUEIDENTIFIER)
AS

DECLARE @Logs TABLE (strError NVARCHAR(500), strField NVARCHAR(100), strValue NVARCHAR(500), intLineNumber INT NULL, dblTotalAmount NUMERIC(18, 6), intLinePosition INT NULL, strLogLevel NVARCHAR(50))

-- Validations
INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the location with a companyLocationId ''' + CAST(s.intCompanyLocationId AS NVARCHAR(50)) + '''', 'companyLocationId', 'Error', CAST(s.intCompanyLocationId AS NVARCHAR(50))
FROM tblCTApiItemContractStaging s
LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = s.intCompanyLocationId
WHERE c.intCompanyLocationId IS NULL
	AND s.guiApiUniqueId = @guiUniqueId

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the customer with an entityId ''' + CAST(s.intEntityId AS NVARCHAR(50)) + '''', 'entityId', 'Error',  CAST(s.intEntityId AS NVARCHAR(50))
FROM tblCTApiItemContractStaging s
LEFT JOIN tblEMEntity e ON e.intEntityId = s.intEntityId
WHERE e.intEntityId IS NULL
	AND s.guiApiUniqueId = @guiUniqueId

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the category with a categoryId ''' + CAST(s.intCategoryId AS NVARCHAR(50)) + '''', 'categoryId', 'Error',  CAST(s.intCategoryId AS NVARCHAR(50))
FROM tblCTApiDollarContractDetailStaging s
INNER JOIN tblCTApiItemContractStaging c ON c.intApiItemContractStagingId = s.intApiItemContractStagingId
LEFT JOIN tblICCategory e ON e.intCategoryId = s.intCategoryId
WHERE e.intCategoryId IS NULL
	AND c.guiApiUniqueId = @guiUniqueId

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the term with termId ''' + CAST(s.intTermId AS NVARCHAR(50)) + '''', 'termId', 'Error',  CAST(s.intTermId AS NVARCHAR(50))
FROM tblCTApiItemContractStaging s
INNER JOIN tblSMTerm t ON t.intTermID = s.intTermId
WHERE t.intTermID IS NULL
	AND s.guiApiUniqueId = @guiUniqueId

IF EXISTS(SELECT * FROM @Logs)
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
DECLARE @dblDollarValue NUMERIC(18,6)
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
		, dblRemainingDollarValue
		, strContractNumber
		, guiApiUniqueId)
	SELECT 1
		, @intContractType
		, 'Dollar'
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
		, @dblDollarValue
		, @strDollarContractNumber
		, @guiUniqueId

	SET @intItemContractHeaderId = SCOPE_IDENTITY()

	INSERT INTO tblCTItemContractHeaderCategory (intCategoryId, intItemContractHeaderId)
	SELECT ds.intCategoryId, @intItemContractHeaderId
	FROM tblCTApiDollarContractDetailStaging ds
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

Logging:

INSERT INTO @Logs (intLineNumber, dblTotalAmount, strLogLevel, strField)
SELECT h.intItemContractHeaderId, h.dblDollarValue, 'Ids', h.strContractNumber
FROM tblCTItemContractHeader h
WHERE h.guiApiUniqueId = @guiUniqueId

SELECT * FROM @Logs

-- Cleanup
DELETE d
FROM tblCTApiDollarContractDetailStaging d
INNER JOIN tblCTApiItemContractStaging s ON s.intApiItemContractStagingId = d.intApiItemContractStagingId
WHERE s.guiApiUniqueId = @guiUniqueId

DELETE FROM tblCTApiItemContractStaging
WHERE guiApiUniqueId = @guiUniqueId