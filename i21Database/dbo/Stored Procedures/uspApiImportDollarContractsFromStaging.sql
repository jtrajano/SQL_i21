CREATE PROCEDURE [dbo].[uspApiImportDollarContractsFromStaging] (@guiApiUniqueId UNIQUEIDENTIFIER)
AS

-- Validations
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
	strTransactionType = 'Dollar Contracts',
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
	strValue = CAST(s.intCompanyLocationId AS NVARCHAR(50)),
	intLineNumber = NULL,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI',
	strTransactionType = 'Dollar Contracts',
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
	strError = 'Cannot find the category with a categoryId ''' + CAST(s.intCategoryId AS NVARCHAR(50)) + '''', 
	strField = 'categoryId', 
	strLogLevel = 'Error', 
	strValue = CAST(s.intCategoryId AS NVARCHAR(50)),
	intLineNumber = NULL,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI',
	strTransactionType = 'Dollar Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblCTApiDollarContractDetailStaging s
INNER JOIN tblCTApiItemContractStaging c ON c.intApiItemContractStagingId = s.intApiItemContractStagingId
LEFT JOIN tblICCategory e ON e.intCategoryId = s.intCategoryId
WHERE e.intCategoryId IS NULL
	AND c.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'Cannot find the term with termId ''' + CAST(s.intTermId AS NVARCHAR(50)) + '''', 
	strField = 'termId', 
	strLogLevel = 'Error', 
	strValue = CAST(s.intTermId AS NVARCHAR(50)),
	intLineNumber = NULL,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI',
	strTransactionType = 'Dollar Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblCTApiItemContractStaging s
INNER JOIN tblSMTerm t ON t.intTermID = s.intTermId
WHERE t.intTermID IS NULL
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
DECLARE @dblDollarValue NUMERIC(18,6)
DECLARE @intStagingId INT
DECLARE @intApiRowNumber INT

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
	, s.intApiRowNumber
FROM tblCTApiItemContractStaging s
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
, @dblDollarValue
, @intApiRowNumber

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
		, guiApiUniqueId
		, intApiRowNumber)
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
		, @guiApiUniqueId
		, @intApiRowNumber

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
	, @intApiRowNumber

END

CLOSE cur
DEALLOCATE cur

Logging:

INSERT INTO tblRestApiTransformationDelta (guiTransformationDeltaId,intTransactionId, strTransactionNo, dblTotalAmount,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	intTransactionId = h.intItemContractHeaderId,
	strTransactionNo = h.strContractNumber, 
	dblTotalAmount = ISNULL(h.dblDollarValue, 0),
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI',
	strTransactionType = 'Dollar Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblCTItemContractHeader h
LEFT JOIN tblCTItemContractDetail d ON d.intItemContractHeaderId = h.intItemContractHeaderId
WHERE h.guiApiUniqueId = @guiApiUniqueId
GROUP BY h.intItemContractHeaderId, h.strContractNumber, h.dblDollarValue

SELECT * FROM tblRestApiTransformationLog WHERE guiApiUniqueId = @guiApiUniqueId

-- Cleanup
DELETE d
FROM tblCTApiDollarContractDetailStaging d
INNER JOIN tblCTApiItemContractStaging s ON s.intApiItemContractStagingId = d.intApiItemContractStagingId
WHERE s.guiApiUniqueId = @guiApiUniqueId

DELETE FROM tblCTApiItemContractStaging
WHERE guiApiUniqueId = @guiApiUniqueId
GO