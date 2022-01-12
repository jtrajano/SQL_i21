CREATE PROCEDURE [dbo].[uspApiSchemaTransformItemContract] (
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
	strError = CASE WHEN sc.strLocation IS NULL THEN 'Location is blank.' ELSE 'Cannot find the location: ''' + sc.strLocation + '''' END,
	strField = 'Location', 
	strLogLevel = 'Error', 
	strValue = sc.strLocation,
	intLineNumber = sc.intRowNumber,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI_CSV',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblRestApiSchemaItemContract sc
LEFT JOIN tblSMCompanyLocation loc ON loc.strLocationName = sc.strLocation OR loc.strLocationNumber = sc.strLocation
WHERE loc.intCompanyLocationId IS NULL
	AND sc.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = CASE WHEN sc.strCustomerNo IS NULL THEN 'The Entity No/Customer No is blank.' ELSE 'Cannot find the customer with Entity No./Customer No.: ''' + sc.strCustomerNo + '''' END,
	strField = 'Entity No/Customer No', 
	strLogLevel = 'Error', 
	strValue = sc.strCustomerNo,
	intLineNumber = sc.intRowNumber,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI_CSV',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblRestApiSchemaItemContract sc
LEFT JOIN vyuARCustomer customer ON customer.strCustomerNumber = sc.strCustomerNo OR customer.strName = sc.strCustomerNo
WHERE customer.intEntityId IS NULL
	AND sc.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = CASE WHEN sc.strSalesperson IS NULL THEN 'Salesperson is blank.' ELSE 'Cannot find the salesperson: ''' + sc.strSalesperson + '''' END,
	strField = 'Salesperson', 
	strLogLevel = 'Error', 
	strValue = sc.strSalesperson,
	intLineNumber = sc.intRowNumber,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI_CSV',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblRestApiSchemaItemContract sc
LEFT JOIN vyuCTEntity sp ON (sp.strEntityName = sc.strSalesperson OR sp.strEntityNumber = sc.strSalesperson)
	AND sp.strEntityType = 'Salesperson'
WHERE sp.intEntityId IS NULL
	AND sc.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = CASE WHEN sc.strCurrency IS NULL THEN 'Currency is blank.' ELSE 'Cannot find the currency: ''' + sc.strCurrency + '''' END,
	strField = 'Currency', 
	strLogLevel = 'Error', 
	strValue = sc.strCurrency,
	intLineNumber = sc.intRowNumber,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI_CSV',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblRestApiSchemaItemContract sc
LEFT JOIN tblSMCurrency currency ON currency.strCurrency = sc.strCurrency OR currency.strDescription = sc.strCurrency
WHERE currency.intCurrencyID IS NULL
	AND sc.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = CASE WHEN sc.strCountry IS NULL THEN 'Country is blank.' ELSE 'Cannot find the country: ''' + sc.strCountry + '''' END,
	strField = 'Country', 
	strLogLevel = 'Error', 
	strValue = sc.strCurrency,
	intLineNumber = sc.intRowNumber,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI_CSV',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblRestApiSchemaItemContract sc
LEFT JOIN tblSMCountry country ON country.strCountry = sc.strCountry OR country.strCountryCode = sc.strCountry
WHERE country.intCountryID IS NULL
    AND NULLIF(sc.strCountry, '') IS NOT NULL
	AND sc.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = CASE WHEN sc.strTerms IS NULL THEN 'Terms is blank.' ELSE 'Cannot find the terms: ''' + sc.strTerms + '''' END,
	strField = 'Terms', 
	strLogLevel = 'Error', 
	strValue = sc.strTerms,
	intLineNumber = sc.intRowNumber,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI_CSV',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblRestApiSchemaItemContract sc
LEFT JOIN tblSMTerm term ON term.strTerm = sc.strTerms OR term.strTermCode = sc.strTerms
WHERE term.intTermID IS NULL
    AND NULLIF(sc.strTerms, '') IS NOT NULL
	AND sc.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = CASE WHEN sc.strFreightTerm IS NULL THEN 'Freight Term is blank.' ELSE 'Cannot find the Freight Term: ''' + sc.strFreightTerm + '''' END,
	strField = 'Freight Term', 
	strLogLevel = 'Error', 
	strValue = sc.strTerms,
	intLineNumber = sc.intRowNumber,
	@guiApiUniqueId,
	strIntegrationType = 'RESTfulAPI_CSV',
	strTransactionType = 'Item Contracts',
	strApiVersion = NULL,
	guiSubscriptionId = NULL
FROM tblRestApiSchemaItemContract sc
LEFT JOIN tblSMFreightTerms term ON term.strFreightTerm = sc.strFreightTerm OR term.strDescription = sc.strFreightTerm
WHERE term.intFreightTermId IS NULL
    AND NULLIF(sc.strFreightTerm, '') IS NOT NULL
	AND sc.guiApiUniqueId = @guiApiUniqueId

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT 
      customer.intEntityId intCustomerId
    , sc.dtmContractDate
    , sc.dtmExpirationDate
	, sc.dtmDueDate
    , sc.strEntryContract
    , sc.strContract
    , sc.ysnIsSigned
    , sc.ysnIsPrinted
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
    , lob.strLineOfBusiness
FROM tblRestApiSchemaItemContract sc
INNER JOIN vyuARCustomer customer ON customer.strCustomerNumber = sc.strCustomerNo OR customer.strName = sc.strCustomerNo
INNER JOIN tblSMCompanyLocation loc ON loc.strLocationName = sc.strLocation OR loc.strLocationNumber = sc.strLocation
INNER JOIN tblSMCurrency currency ON currency.strCurrency = sc.strCurrency OR currency.strDescription = sc.strCurrency
INNER JOIN vyuCTEntity sp ON (sp.strEntityName = sc.strSalesperson OR sp.strEntityNumber = sc.strSalesperson) AND sp.strEntityType = 'Salesperson'
LEFT JOIN tblSMFreightTerms ft ON ft.strFreightTerm = sc.strFreightTerm OR ft.strDescription = sc.strFreightTerm
LEFT JOIN tblSMTerm t ON t.strTerm = sc.strTerms OR t.strTermCode = sc.strTerms
LEFT JOIN tblSMCountry ct ON ct.strCountry = sc.strCountry OR ct.strCountryCode = sc.strCountry
LEFT JOIN tblCTContractText ctext ON ctext.strTextCode = sc.strContractText
	AND ctext.intContractType = 2
	AND ctext.ysnActive = 1
--OUTER APPLY (
--	SELECT TOP 1 l.strLineOfBusiness, l.intLineOfBusinessId
--	FROM tblSMLineOfBusiness l 
--	WHERE l.strLineOfBusiness = sc.strLineOfBusiness
--		AND NULLIF(sc.strLineOfBusiness, '') IS NOT NULL
--) lob
LEFT JOIN tblSMLineOfBusiness lob ON lob.strLineOfBusiness = sc.strLineOfBusiness
--OUTER APPLY (
--	SELECT TOP 1 sct.dtmDueDate
--	FROM tblRestApiSchemaItemContract sct
--	WHERE sct.dtmDueDate IS NOT NULL
--		AND ISNULL(sc.dtmContractDate, @Date) = ISNULL(sct.dtmContractDate, @Date)
--        AND ISNULL(sc.dtmExpirationDate, @Date) = ISNULL(sct.dtmExpirationDate, @Date)
--        AND ISNULL(sc.ysnIsSigned, 0) = ISNULL(sct.ysnIsSigned, 0)
--        AND ISNULL(sc.ysnIsPrinted, 0) = ISNULL(sct.ysnIsPrinted, 0)
--        AND ISNULL(sc.strContract, '') = ISNULL(sct.strContract, '')
--        AND ISNULL(sc.strEntryContract, '') = ISNULL(sct.strEntryContract, '')
--        AND ISNULL(sc.strCustomerNo, '') = ISNULL(sct.strCustomerNo, '')
--        AND ISNULL(sc.strCurrency, '') = ISNULL(sct.strCurrency, '')
--        AND ISNULL(sc.strLocation, '') = ISNULL(sct.strLocation, '')
--        AND ISNULL(sc.strFreightTerm, '') = ISNULL(sct.strFreightTerm, '')
--        AND ISNULL(sc.strCountry, '') = ISNULL(sct.strCountry, '')
--        AND ISNULL(sc.strTerms, '') = ISNULL(sct.strTerms, '')
--        AND ISNULL(sc.strSalesperson, '') = ISNULL(sct.strSalesperson, '')
--        AND ISNULL(sc.strContractText, '') = ISNULL(sct.strContractText, '')
--) dueDate
WHERE sc.guiApiUniqueId = @guiApiUniqueId 
GROUP BY
      customer.intEntityId
    , sc.dtmContractDate
    , sc.dtmExpirationDate
	, sc.dtmDueDate
    , sc.strEntryContract
    , sc.strContract
    , sc.ysnIsSigned
    , sc.ysnIsPrinted
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
	, lob.strLineOfBusiness

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

OPEN cur;

FETCH NEXT FROM cur INTO 
      @intCustomerId
	, @dtmContractDate
	, @dtmExpirationDate
	, @dtmDueDate
	, @strEntryContract
	, @strContract
	, @ysnIsSigned
	, @ysnIsPrinted
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

    SET @intItemContractStagingId = SCOPE_IDENTITY()

    INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
		strError, strField, strLogLevel, strValue, intLineNumber,
		guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
	SELECT
		NEWID(),
        strError = CASE WHEN sc.strItemNo IS NULL THEN 'Item No is blank.' ELSE 'Cannot find the Item No.: ''' + ISNULL(sc.strItemNo, '') + '''' END,
        strField = 'Item No', 
        strLogLevel = 'Error', 
        strValue = sc.strItemNo,
        intLineNumber = sc.intRowNumber,
        @guiApiUniqueId,
        strIntegrationType = 'RESTfulAPI_CSV',
        strTransactionType = 'Item Contracts',
        strApiVersion = NULL,
        guiSubscriptionId = NULL
    FROM tblRestApiSchemaItemContract sc
    LEFT JOIN tblICItem i ON i.strItemNo = sc.strItemNo
    WHERE sc.guiApiUniqueId = @guiApiUniqueId
        AND i.intItemId IS NULL
        AND ISNULL(sc.dtmContractDate, @Date) = ISNULL(@dtmContractDate, @Date)
        AND ISNULL(sc.dtmExpirationDate, @Date) = ISNULL(@dtmExpirationDate, @Date)
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
		AND ISNULL(sc.dtmDueDate, @Date) = ISNULL(@dtmDueDate, @Date)

    INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
		strError, strField, strLogLevel, strValue, intLineNumber,
		guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
	SELECT
		NEWID(),
        strError = CASE WHEN sc.strUnitMeasure IS NULL THEN 'UOM is blank.' ELSE 'In valid UOM: ''' + ISNULL(sc.strUnitMeasure, '') + '''' END,
        strField = 'UOM', 
        strLogLevel = 'Error', 
        strValue = sc.strUnitMeasure,
        intLineNumber = sc.intRowNumber,
        @guiApiUniqueId,
        strIntegrationType = 'RESTfulAPI_CSV',
        strTransactionType = 'Item Contracts',
        strApiVersion = NULL,
        guiSubscriptionId = NULL
    FROM tblRestApiSchemaItemContract sc
    LEFT JOIN tblICItem i ON i.strItemNo = sc.strItemNo
    LEFT JOIN tblICUnitMeasure uom ON uom.strUnitMeasure = sc.strUnitMeasure
    LEFT JOIN tblICItemUOM u ON u.intItemId = i.intItemId AND u.intUnitMeasureId = uom.intUnitMeasureId
    WHERE sc.guiApiUniqueId = @guiApiUniqueId
        AND u.intItemUOMId IS NULL
        AND ISNULL(sc.dtmContractDate, @Date) = ISNULL(@dtmContractDate, @Date)
        AND ISNULL(sc.dtmExpirationDate, @Date) = ISNULL(@dtmExpirationDate, @Date)
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
		AND ISNULL(sc.dtmDueDate, @Date) = ISNULL(@dtmDueDate, @Date)

    INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
		strError, strField, strLogLevel, strValue, intLineNumber,
		guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
	SELECT
		NEWID(),
        strError = CASE WHEN sc.strTaxGroup IS NULL THEN 'Tax Group is blank.' ELSE 'Invalid tax group: ''' + sc.strTaxGroup + '''' END,
        strField = 'Tax Group', 
        strLogLevel = 'Error', 
        strValue = sc.strTaxGroup,
        intLineNumber = sc.intRowNumber,
        @guiApiUniqueId,
        strIntegrationType = 'RESTfulAPI_CSV',
        strTransactionType = 'Item Contracts',
        strApiVersion = NULL,
        guiSubscriptionId = NULL
    FROM tblRestApiSchemaItemContract sc
    LEFT JOIN tblSMTaxGroup taxGroup ON taxGroup.strTaxGroup = sc.strTaxGroup
    WHERE sc.guiApiUniqueId = @guiApiUniqueId
        AND taxGroup.intTaxGroupId IS NULL
        AND ISNULL(sc.dtmContractDate, @Date) = ISNULL(@dtmContractDate, @Date)
        AND ISNULL(sc.dtmExpirationDate, @Date) = ISNULL(@dtmExpirationDate, @Date)
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
		AND ISNULL(sc.dtmDueDate, @Date) = ISNULL(@dtmDueDate, @Date)

    INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
		strError, strField, strLogLevel, strValue, intLineNumber,
		guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
	SELECT
		NEWID(),
        strError = 'Invalid contract status: ''' + ISNULL(sc.strStatus, '') + '''',
        strField = 'Status', 
        strLogLevel = 'Error', 
        strValue = sc.strStatus,
        intLineNumber = sc.intRowNumber,
        @guiApiUniqueId,
        strIntegrationType = 'RESTfulAPI_CSV',
        strTransactionType = 'Item Contracts',
        strApiVersion = NULL,
        guiSubscriptionId = NULL
    FROM tblRestApiSchemaItemContract sc
    LEFT JOIN tblCTContractStatus s ON s.strContractStatus = sc.strStatus
    WHERE sc.guiApiUniqueId = @guiApiUniqueId
        AND s.intContractStatusId IS NULL
        AND ISNULL(sc.dtmContractDate, @Date) = ISNULL(@dtmContractDate, @Date)
        AND ISNULL(sc.dtmExpirationDate, @Date) = ISNULL(@dtmExpirationDate, @Date)
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
		AND ISNULL(sc.dtmDueDate, @Date) = ISNULL(@dtmDueDate, @Date)

    INSERT INTO tblCTApiItemContractDetailStaging (
          intApiItemContractStagingId
        , intItemId
        , intItemUOMId
        , dblContracted
        , dblPrice
        , dtmDeliveryDate
        , intTaxGroupId
        , strContractStatus)
    SELECT
          @intItemContractStagingId
        , i.intItemId
        , u.intItemUOMId
        , sc.dblContractedQty
        , sc.dblPrice
        , sc.dtmDeliveryDate
        , taxGroup.intTaxGroupId
        , s.intContractStatusId
    FROM tblRestApiSchemaItemContract sc
    INNER JOIN tblCTContractStatus s ON s.strContractStatus = sc.strStatus
    INNER JOIN tblICItem i ON i.strItemNo = sc.strItemNo
    INNER JOIN tblICUnitMeasure uom ON uom.strUnitMeasure = sc.strUnitMeasure
    INNER JOIN tblICItemUOM u ON u.intItemId = i.intItemId AND u.intUnitMeasureId = uom.intUnitMeasureId
    INNER JOIN tblSMTaxGroup taxGroup ON taxGroup.strTaxGroup = sc.strTaxGroup OR taxGroup.strDescription =  sc.strTaxGroup
    WHERE sc.guiApiUniqueId = @guiApiUniqueId
        AND ISNULL(sc.dtmContractDate, @Date) = ISNULL(@dtmContractDate, @Date)
        AND ISNULL(sc.dtmExpirationDate, @Date) = ISNULL(@dtmExpirationDate, @Date)
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
		AND ISNULL(sc.dtmDueDate, @Date) = ISNULL(@dtmDueDate, @Date)
    
    FETCH NEXT FROM cur INTO 
		  @intCustomerId
		, @dtmContractDate
		, @dtmExpirationDate
		, @dtmDueDate
		, @strEntryContract
		, @strContract
		, @ysnIsSigned
		, @ysnIsPrinted
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
END

CLOSE cur;
DEALLOCATE cur;

EXEC dbo.uspApiImportItemContractsFromStaging @guiApiUniqueId

DELETE FROM tblRestApiSchemaItemContract WHERE guiApiUniqueId = @guiApiUniqueId

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
    INNER JOIN tblCTItemContractDetail d ON h.intItemContractHeaderId = d.intItemContractHeaderId 
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

SELECT * FROM tblRestApiTransformationLog WHERE guiApiUniqueId = @guiApiUniqueId