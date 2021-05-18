CREATE PROCEDURE [dbo].[uspRestApiSchemaTransformItemContract] (@guiApiUniqueId UNIQUEIDENTIFIER)
AS
-- Validations
INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
	strError, strField, strLogLevel, strValue, intLineNumber,
	guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
SELECT
	NEWID(),
	strError = 'Cannot find the location: ''' + sc.strLocation + '''',
	strField = 'Location', 
	strLogLevel = 'Error', 
	strValue = sc.strLocation,
	intLineNumber = NULL,
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
	strError = 'Cannot find the customer with Customer No.: ''' + sc.strCustomerNo + '''',
	strField = 'Customer No', 
	strLogLevel = 'Error', 
	strValue = sc.strCustomerNo,
	intLineNumber = NULL,
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
	strError = 'Cannot find the salesperson: ''' + sc.strSalesperson + '''',
	strField = 'Salesperson', 
	strLogLevel = 'Error', 
	strValue = sc.strSalesperson,
	intLineNumber = NULL,
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
	strError = 'Cannot find the currency: ''' + sc.strCurrency + '''',
	strField = 'Currency', 
	strLogLevel = 'Error', 
	strValue = sc.strCurrency,
	intLineNumber = NULL,
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
	intLineNumber = NULL,
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
	intLineNumber = NULL,
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
	intLineNumber = NULL,
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
    , sc.strEntryContract
    , sc.strContract
    , sc.ysnIsSigned
    , sc.ysnIsPrinted
    , sc.dtmDueDate
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
FROM tblRestApiSchemaItemContract sc
INNER JOIN vyuARCustomer customer ON customer.strCustomerNumber = sc.strCustomerNo OR customer.strName = sc.strCustomerNo
INNER JOIN tblSMCompanyLocation loc ON loc.strLocationName = sc.strLocation OR loc.strLocationNumber = sc.strLocation
INNER JOIN tblSMCurrency currency ON currency.strCurrency = sc.strCurrency OR currency.strDescription = sc.strCurrency
INNER JOIN vyuCTEntity sp ON (sp.strEntityName = sc.strSalesperson OR sp.strEntityNumber = sc.strSalesperson) AND sp.strEntityType = 'Salesperson'
LEFT JOIN tblSMFreightTerms ft ON ft.strFreightTerm = sc.strFreightTerm OR ft.strDescription = sc.strFreightTerm
LEFT JOIN tblSMTerm t ON t.strTerm = sc.strTerms OR t.strTermCode = sc.strTerms
LEFT JOIN tblSMCountry ct ON ct.strCountry = sc.strCountry OR ct.strCountryCode = sc.strCountry
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

DECLARE @Date DATETIME = GETDATE()

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
        strError = 'Cannot find the Item No.: ''' + ISNULL(sc.strItemNo, '') + '''',
        strField = 'Item No', 
        strLogLevel = 'Error', 
        strValue = sc.strItemNo,
        intLineNumber = NULL,
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
        AND ISNULL(sc.dtmDueDate, @Date) = ISNULL(@dtmDueDate, @Date)
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

    INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
		strError, strField, strLogLevel, strValue, intLineNumber,
		guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
	SELECT
		NEWID(),
        strError = 'In valid UOM: ''' + ISNULL(sc.strUnitMeasure, '') + '''',
        strField = 'UOM', 
        strLogLevel = 'Error', 
        strValue = sc.strUnitMeasure,
        intLineNumber = NULL,
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
        AND ISNULL(sc.dtmDueDate, @Date) = ISNULL(@dtmDueDate, @Date)
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

    INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
		strError, strField, strLogLevel, strValue, intLineNumber,
		guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
	SELECT
		NEWID(),
        strError = 'Invalid tax group: ''' + sc.strTaxGroup + '''',
        strField = 'Tax Group', 
        strLogLevel = 'Error', 
        strValue = sc.strTaxGroup,
        intLineNumber = NULL,
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
        AND ISNULL(sc.dtmDueDate, @Date) = ISNULL(@dtmDueDate, @Date)
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

    INSERT INTO tblRestApiTransformationLog (guiTransformationLogId,
		strError, strField, strLogLevel, strValue, intLineNumber,
		guiApiUniqueId, strIntegrationType, strTransactionType, strApiVersion, guiSubscriptionId)
	SELECT
		NEWID(),
        strError = 'Invalid contract status: ''' + ISNULL(sc.strStatus, '') + '''',
        strField = 'Status', 
        strLogLevel = 'Error', 
        strValue = sc.strStatus,
        intLineNumber = NULL,
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
        AND ISNULL(sc.dtmDueDate, @Date) = ISNULL(@dtmDueDate, @Date)
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
        AND ISNULL(sc.dtmDueDate, @Date) = ISNULL(@dtmDueDate, @Date)
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

SELECT * FROM tblRestApiTransformationLog WHERE guiApiUniqueId = @guiApiUniqueId