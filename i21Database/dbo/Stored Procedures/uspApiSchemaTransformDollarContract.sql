CREATE PROCEDURE [dbo].[uspApiSchemaTransformDollarContract] (
      @guiApiUniqueId UNIQUEIDENTIFIER
    , @guiLogId UNIQUEIDENTIFIER
)
AS

DECLARE @strI21Version NVARCHAR(200) = (SELECT TOP 1 strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC)
DECLARE @Date DATETIME = GETUTCDATE()

-- Validations
INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'Cannot find the company location: ''' + ISNULL(sc.strLocation, '') + '''',
	strField = 'Company Location', 
	strLogLevel = 'Error', 
	strValue = sc.strLocation,
	intLineNumber = sc.intRowNumber,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI_CSV',
	strTransactionType = 'Dollar Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblRestApiSchemaDollarContract sc
LEFT JOIN tblSMCompanyLocation loc ON loc.strLocationName = sc.strLocation OR loc.strLocationNumber = sc.strLocation
WHERE loc.intCompanyLocationId IS NULL
	AND sc.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'Cannot find the customer with Entity No./Customer No.: ''' + ISNULL(sc.strCustomerNo, '') + '''',
	strField = 'Entity No/Customer No', 
	strLogLevel = 'Error', 
	strValue = sc.strCustomerNo,
	intLineNumber = sc.intRowNumber,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI_CSV',
	strTransactionType = 'Dollar Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblRestApiSchemaDollarContract sc
LEFT JOIN vyuARCustomer customer ON customer.strCustomerNumber = sc.strCustomerNo OR customer.strName = sc.strCustomerNo
WHERE customer.intEntityId IS NULL
	AND sc.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'Cannot find the salesperson: ''' + ISNULL(sc.strSalesperson, '') + '''',
	strField = 'Salesperson', 
	strLogLevel = 'Error', 
	strValue = sc.strSalesperson,
	intLineNumber = sc.intRowNumber,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI_CSV',
	strTransactionType = 'Dollar Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblRestApiSchemaDollarContract sc
LEFT JOIN vyuCTEntity sp ON (sp.strEntityName = sc.strSalesperson OR sp.strEntityNumber = sc.strSalesperson)
	AND sp.strEntityType = 'Salesperson'
WHERE sp.intEntityId IS NULL
	AND sc.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'Cannot find the currency: ''' + ISNULL(sc.strCurrency, '') + '''',
	strField = 'Currency', 
	strLogLevel = 'Error', 
	strValue = sc.strCurrency,
	intLineNumber = sc.intRowNumber,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI_CSV',
	strTransactionType = 'Dollar Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblRestApiSchemaDollarContract sc
LEFT JOIN tblSMCurrency currency ON currency.strCurrency = sc.strCurrency OR currency.strDescription = sc.strCurrency
WHERE currency.intCurrencyID IS NULL
	AND sc.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'Cannot find the country: ''' + ISNULL(sc.strCountry, '') + '''',
	strField = 'Country', 
	strLogLevel = 'Error', 
	strValue = sc.strCountry,
	intLineNumber = sc.intRowNumber,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI_CSV',
	strTransactionType = 'Dollar Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblRestApiSchemaDollarContract sc
LEFT JOIN tblSMCountry country ON country.strCountry = sc.strCountry OR country.strCountryCode = sc.strCountry
WHERE country.intCountryID IS NULL
  AND NULLIF(sc.strCountry, '') IS NOT NULL
	AND sc.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'Cannot find the terms: ''' + ISNULL(sc.strTerms, '') + '''',
	strField = 'Terms', 
	strLogLevel = 'Error', 
	strValue = sc.strTerms,
	intLineNumber = sc.intRowNumber,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI_CSV',
	strTransactionType = 'Dollar Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblRestApiSchemaDollarContract sc
LEFT JOIN tblSMTerm term ON term.strTerm = sc.strTerms OR term.strTermCode = sc.strTerms
WHERE term.intTermID IS NULL
  AND NULLIF(sc.strTerms, '') IS NOT NULL
	AND sc.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'Cannot find the freight term: ''' + ISNULL(sc.strFreightTerm, '') + '''',
	strField = 'Freight Terms', 
	strLogLevel = 'Error', 
	strValue = sc.strFreightTerm,
	intLineNumber = sc.intRowNumber,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI_CSV',
	strTransactionType = 'Dollar Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblRestApiSchemaDollarContract sc
LEFT JOIN tblSMFreightTerms term ON term.strFreightTerm = sc.strFreightTerm OR term.strDescription = sc.strFreightTerm
WHERE term.intFreightTermId IS NULL
  AND NULLIF(sc.strFreightTerm, '') IS NOT NULL
	AND sc.guiApiUniqueId = @guiApiUniqueId

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT DISTINCT
      customer.intEntityId intCustomerId
    , sc.dtmContractDate
    , sc.dtmExpirationDate
    , sc.strEntryContract
    , sc.strContract
    , sc.ysnIsSigned
    , sc.ysnIsPrinted
    , sc.dtmDueDate
    , sc.dblContractValue
    , loc.intCompanyLocationId
    , currency.intCurrencyID
    , sp.intEntityId AS intSalespersonId
    , ft.intFreightTermId
    , t.intTermID
    , ct.intCountryID
    , ctext.intContractTextId
    , lob.intLineOfBusinessId
    , sc.strCustomerNo
    , sc.strCurrency
    , sc.strLocation
    , sc.strFreightTerm
    , sc.strCountry
    , sc.strTerms
    , sc.strSalesperson
    , sc.strContractText
    , sc.strLineOfBusiness
    , MIN(sc.intRowNumber)
FROM tblRestApiSchemaDollarContract sc
CROSS APPLY (
  SELECT TOP 1 intEntityId
  FROM vyuARCustomer 
  WHERE strCustomerNumber = sc.strCustomerNo OR strName = sc.strCustomerNo
) customer
CROSS APPLY (
  SELECT TOP 1 intCompanyLocationId
  FROM tblSMCompanyLocation
  WHERE strLocationName = sc.strLocation OR strLocationNumber = sc.strLocation
) loc
CROSS APPLY (
  SELECT TOP 1 intCurrencyID
  FROM tblSMCurrency
  WHERE strCurrency = sc.strCurrency OR strDescription = sc.strCurrency
) currency
CROSS APPLY (
  SELECT TOP 1 x.intEntityId
  FROM vyuCTEntity x
  WHERE (x.strEntityName = sc.strSalesperson OR x.strEntityNumber = sc.strSalesperson) AND x.strEntityType = 'Salesperson'
) sp
OUTER APPLY (
  SELECT TOP 1 xf.intFreightTermId
  FROM tblSMFreightTerms xf
  WHERE xf.strFreightTerm = sc.strFreightTerm OR xf.strDescription = sc.strFreightTerm
) ft
OUTER APPLY (
  SELECT TOP 1 xt.intTermID
  FROM tblSMTerm xt
  WHERE xt.strTerm = sc.strTerms OR xt.strTermCode = sc.strFreightTerm
) t
OUTER APPLY (
  SELECT TOP 1 xc.intCountryID
  FROM tblSMCountry xc
  WHERE xc.strCountry = sc.strCountry OR xc.strCountryCode = sc.strCountry
) ct
LEFT JOIN tblCTContractText ctext ON ctext.strTextCode = sc.strContractText
LEFT JOIN tblSMLineOfBusiness lob ON lob.strLineOfBusiness = sc.strLineOfBusiness
WHERE sc.guiApiUniqueId = @guiApiUniqueId
GROUP BY
      customer.intEntityId
    , sc.dtmContractDate
    , sc.dtmExpirationDate
    , sc.strEntryContract
    , sc.strContract
    , sc.ysnIsSigned
    , sc.ysnIsPrinted
    , sc.dtmDueDate
    , sc.dblContractValue
    , loc.intCompanyLocationId
    , currency.intCurrencyID
    , sp.intEntityId
    , ft.intFreightTermId
    , t.intTermID
    , ct.intCountryID
    , ctext.intContractTextId
    , lob.intLineOfBusinessId
    , sc.strCustomerNo
    , sc.strCurrency
    , sc.strLocation
    , sc.strFreightTerm
    , sc.strCountry
    , sc.strTerms
    , sc.strSalesperson
    , sc.strContractText
    , sc.strLineOfBusiness

DECLARE @intCustomerId INT
DECLARE @dtmContractDate DATETIME
DECLARE @dtmExpirationDate DATETIME
DECLARE @strEntryContract NVARCHAR(200)
DECLARE @strContract NVARCHAR(200)
DECLARE @ysnIsSigned BIT
DECLARE @ysnIsPrinted BIT
DECLARE @dtmDueDate DATETIME
DECLARE @dblContractValue NUMERIC(18,6)
DECLARE @intCompanyLocationId INT
DECLARE @intCurrencyID INT
DECLARE @intSalespersonId INT
DECLARE @intFreightTermId INT
DECLARE @intTermID INT
DECLARE @intCountryID INT
DECLARE @intContractTextId INT
DECLARE @intLineOfBusinessId INT
DECLARE @intItemContractStagingId INT

DECLARE @strCustomerNo NVARCHAR(200)
DECLARE @strCurrency NVARCHAR(200)
DECLARE @strLocation NVARCHAR(200)
DECLARE @strFreightTerm NVARCHAR(200)
DECLARE @strCountry NVARCHAR(200)
DECLARE @strTerms NVARCHAR(200)
DECLARE @strSalesperson NVARCHAR(200)
DECLARE @strContractText NVARCHAR(200)
DECLARE @strLineOfBusiness NVARCHAR(200)
DECLARE @intApiRowNumber INT

OPEN cur;

FETCH NEXT FROM cur INTO 
      @intCustomerId
    , @dtmContractDate
    , @dtmExpirationDate
    , @strEntryContract
    , @strContract
    , @ysnIsSigned
    , @ysnIsPrinted
    , @dtmDueDate
    , @dblContractValue
    , @intCompanyLocationId
    , @intCurrencyID
    , @intSalespersonId
    , @intFreightTermId
    , @intTermID
    , @intCountryID
    , @intContractTextId
    , @intLineOfBusinessId
    , @strCustomerNo
    , @strCurrency
    , @strLocation
    , @strFreightTerm
    , @strCountry
    , @strTerms
    , @strSalesperson
    , @strContractText
    , @strLineOfBusiness
    , @intApiRowNumber

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO tblCTApiItemContractStaging (
          guiApiUniqueId
        , intEntityId
        , intCompanyLocationId
        , dtmContractDate
        , intSalespersonId
        , strContractType
        , intCountryId
        , strCPContract
        , strEntryContract
        , intCurrencyId
        , dtmExpirationDate
        , dtmDueDate
        , intFreightTermId
        , ysnPrinted
        , ysnSigned
        , intContractTextId
        , intTermId
        , intLineOfBusinessId
        , dblDollarValue
        , intApiRowNumber
    )
    SELECT
          guiApiUniqueId = @guiApiUniqueId
        , intEntityId = @intCustomerId
        , intCompanyLocationId = @intCompanyLocationId
        , dtmContractDate = @dtmContractDate
        , intSalespersonId = @intSalespersonId
        , strContractType = 'Sale'
        , intCountryId = @intCountryID
        , strCPContract = @strContract
        , strEntryContract = @strEntryContract
        , intCurrencyId = @intCurrencyID
        , dtmExpirationDate = @dtmExpirationDate
        , dtmDueDate = @dtmDueDate
        , intFreightTermId = @intFreightTermId
        , ysnPrinted = @ysnIsPrinted
        , ysnSigned = @ysnIsSigned
        , intContractTextId = @intContractTextId
        , intTermId = @intTermID
        , intLineOfBusinessId = @intLineOfBusinessId
        , dblDollarValue = @dblContractValue
        , intApiRowNumber = @intApiRowNumber

    SET @intItemContractStagingId = SCOPE_IDENTITY()

    INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
      strError, strField, strLogLevel, strValue, intLineNumber,
		  guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
    SELECT
		NEWID(),
        strError = 'Cannot find the category: ''' + ISNULL(sc.strCategory, '') + '''',
        strField = 'Category', 
        strLogLevel = 'Error', 
        strValue = sc.strCategory,
        intLineNumber = sc.intRowNumber,
        @guiApiUniqueId,
        strIntegrationType = 'RESTfulAPI_CSV',
        strTransactionType = 'Dollar Contracts',
        strApiVersion = NULL,
        guiSubscriptionId = NULL
    FROM tblRestApiSchemaDollarContract sc
    LEFT JOIN tblICCategory c ON c.strCategoryCode = sc.strCategory OR c.strDescription = sc.strCategory
    WHERE sc.guiApiUniqueId = @guiApiUniqueId
        AND c.intCategoryId IS NULL
        AND ISNULL(sc.dtmContractDate, @Date) = ISNULL(@dtmContractDate, @Date)
        AND ISNULL(sc.dtmExpirationDate, @Date) = ISNULL(@dtmExpirationDate, @Date)
        AND ISNULL(sc.dtmDueDate, @Date) = ISNULL(@dtmDueDate, @Date)
        AND sc.dblContractValue = @dblContractValue
        AND ISNULL(sc.ysnIsSigned, 0) = ISNULL(@ysnIsSigned, 0)
        AND ISNULL(sc.ysnIsPrinted, 0) = ISNULL(@ysnIsPrinted, 0)
        AND ISNULL(sc.strContract, '') = ISNULL(@strContract, '')
        AND ISNULL(sc.strEntryContract, '') = ISNULL(@strEntryContract, '')
        AND ISNULL(sc.strCustomerNo, '') = ISNULL(@strCustomerNo, '')
        AND ISNULL(sc.strCurrency, '') = ISNULL(@strCurrency, '')
        AND ISNULL(sc.strLocation, '') = ISNULL(@strLocation, '')
        AND ISNULL(sc.strFreightTerm, '') = ISNULL(@strFreightTerm, '')
        AND ISNULL(sc.strCountry, '') = ISNULL(@strCountry, '')
        AND ISNULL(sc.strTerms, '') = ISNULL(@strTerms, '')
        AND ISNULL(sc.strSalesperson, '') = ISNULL(@strSalesperson, '')
        AND ISNULL(sc.strContractText, '') = ISNULL(@strContractText, '')
        AND ISNULL(sc.strLineOfBusiness, '') = ISNULL(@strLineOfBusiness, '')

    INSERT INTO tblCTApiDollarContractDetailStaging (intApiItemContractStagingId, intCategoryId)
    SELECT @intItemContractStagingId, c.intCategoryId
    FROM tblRestApiSchemaDollarContract sc
    INNER JOIN tblICCategory c ON c.strCategoryCode = sc.strCategory OR c.strDescription = sc.strCategory
    WHERE sc.guiApiUniqueId = @guiApiUniqueId
        AND ISNULL(sc.dtmContractDate, @Date) = ISNULL(@dtmContractDate, @Date)
        AND ISNULL(sc.dtmExpirationDate, @Date) = ISNULL(@dtmExpirationDate, @Date)
        AND ISNULL(sc.dtmDueDate, @Date) = ISNULL(@dtmDueDate, @Date)
        AND sc.dblContractValue = @dblContractValue
        AND ISNULL(sc.ysnIsSigned, 0) = ISNULL(@ysnIsSigned, 0)
        AND ISNULL(sc.ysnIsPrinted, 0) = ISNULL(@ysnIsPrinted, 0)
        AND ISNULL(sc.strContract, '') = ISNULL(@strContract, '')
        AND ISNULL(sc.strEntryContract, '') = ISNULL(@strEntryContract, '')
        AND ISNULL(sc.strCustomerNo, '') = ISNULL(@strCustomerNo, '')
        AND ISNULL(sc.strCurrency, '') = ISNULL(@strCurrency, '')
        AND ISNULL(sc.strLocation, '') = ISNULL(@strLocation, '')
        AND ISNULL(sc.strFreightTerm, '') = ISNULL(@strFreightTerm, '')
        AND ISNULL(sc.strCountry, '') = ISNULL(@strCountry, '')
        AND ISNULL(sc.strTerms, '') = ISNULL(@strTerms, '')
        AND ISNULL(sc.strSalesperson, '') = ISNULL(@strSalesperson, '')
        AND ISNULL(sc.strContractText, '') = ISNULL(@strContractText, '')
        AND ISNULL(sc.strLineOfBusiness, '') = ISNULL(@strLineOfBusiness, '')
    
    FETCH NEXT FROM cur INTO 
          @intCustomerId
        , @dtmContractDate
        , @dtmExpirationDate
        , @strEntryContract
        , @strContract
        , @ysnIsSigned
        , @ysnIsPrinted
        , @dtmDueDate
        , @dblContractValue
        , @intCompanyLocationId
        , @intCurrencyID
        , @intSalespersonId
        , @intFreightTermId
        , @intTermID
        , @intCountryID
        , @intContractTextId
        , @intLineOfBusinessId
        , @strCustomerNo
        , @strCurrency
        , @strLocation
        , @strFreightTerm
        , @strCountry
        , @strTerms
        , @strSalesperson
        , @strContractText
        , @strLineOfBusiness
        , @intApiRowNumber
END

CLOSE cur;
DEALLOCATE cur;

EXEC dbo.uspApiImportDollarContractsFromStaging @guiApiUniqueId

--DELETE FROM tblRestApiSchemaDollarContract WHERE guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblApiImportLogDetail (
      guiApiImportLogDetailId
    , guiApiImportLogId
    , strLogLevel
    , strStatus
    , strField
    , strValue
    , strMessage
    , intRowNo
)
SELECT
      NEWID()
    , @guiLogId
    , strLogLevel
    , 'Failed'
    , strField
    , strValue
    , strError
    , intLineNumber
FROM tblRestApiTransformationLog
WHERE guiApiUniqueId = @guiApiUniqueId

DECLARE @intTotalRowsImported INT
SET @intTotalRowsImported = (
    SELECT COUNT(*) 
    FROM tblCTItemContractHeader h
    INNER JOIN tblCTItemContractHeaderCategory d ON h.intItemContractHeaderId = d.intItemContractHeaderId 
    WHERE h.guiApiUniqueId = @guiApiUniqueId
)

UPDATE tblApiImportLog
SET 
      strStatus = 'Completed'
    , strResult = CASE WHEN @intTotalRowsImported = 0 THEN 'Failed' ELSE 'Success' END
    , intTotalRecordsCreated = @intTotalRowsImported
    , intTotalRowsImported = @intTotalRowsImported
    , dtmImportFinishDateUtc = GETUTCDATE()
WHERE guiApiImportLogId = @guiLogId

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Dollar Contract'
    , strValue = ch.strContractNumber
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = ch.intApiRowNumber 
    , strMessage = 'The dollar contract has been successfully imported.'
FROM tblCTItemContractHeader ch
WHERE ch.guiApiUniqueId = @guiApiUniqueId

SELECT * FROM tblRestApiTransformationLog WHERE guiApiUniqueId = @guiApiUniqueId