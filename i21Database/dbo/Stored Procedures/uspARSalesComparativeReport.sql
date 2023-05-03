CREATE PROCEDURE [dbo].[uspARSalesComparativeReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
IF LTRIM(RTRIM(@xmlParam)) = ''
	BEGIN 
		SET @xmlParam = NULL
		
		SELECT * FROM vyuARTransactionSummary
		
  		OUTER APPLY (
		SELECT TOP 1 strCompanyName
				   , strCompanyAddress = 
				   dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, 
				   strCity, strState, strZip, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
		FROM dbo.tblSMCompanySetup WITH (NOLOCK)
		) COMPANY
	END

DECLARE @dtmBeginningDateTo				DATETIME
      , @dtmBeginningDateFrom			DATETIME
	  , @dtmEndingDateTo				DATETIME
      , @dtmEndingDateFrom				DATETIME
	  , @intEntityCustomerId			INT	= NULL
	  , @strSalesPersonIds				NVARCHAR(100)
	  , @strName						NVARCHAR(MAX)
	  , @strCustomerIds					NVARCHAR(MAX)
	  , @strAccountStatusCodes			NVARCHAR(MAX)
	  , @strCategoryCodeIds				NVARCHAR(300)
	  , @strItemIds						NVARCHAR(300)
	  , @strItemDescriptions			NVARCHAR(MAX)
	  , @strCompanyLocationIds			NVARCHAR(300)
	  , @strSources						NVARCHAR(MAX)
	  , @intCompanyLocationId			INT = NULL
	  , @xmlDocumentId					INT
	  , @blbLogo						VARBINARY(MAX)
	  , @strLogoType					NVARCHAR(10)

DECLARE @temp_xml_table TABLE (
	 [id]			INT IDENTITY(1,1)
	,[fieldname]	NVARCHAR(50)
	,[condition]	NVARCHAR(20)
	,[from]			NVARCHAR(100)
	,[to]			NVARCHAR(100)
	,[join]			NVARCHAR(10)
	,[begingroup]	NVARCHAR(50)
	,[endgroup]		NVARCHAR(50)
	,[datatype]		NVARCHAR(50)
)

EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT, @xmlParam

-- Insert the XML to the xml table. 		
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
WITH (
	  [fieldname]  NVARCHAR(50)
	, [condition]  NVARCHAR(20)
	, [from]	   NVARCHAR(100)
	, [to]		   NVARCHAR(100)
	, [join]	   NVARCHAR(10)
	, [begingroup] NVARCHAR(50)
	, [endgroup]   NVARCHAR(50)
	, [datatype]   NVARCHAR(50)
)

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2)
WITH (
	  [fieldname]  NVARCHAR(50)
	, [condition]  NVARCHAR(20)
	, [from]	   NVARCHAR(MAX)
	, [to]		   NVARCHAR(MAX)
	, [join]	   NVARCHAR(10)
	, [begingroup] NVARCHAR(50)
	, [endgroup]   NVARCHAR(50)
	, [datatype]   NVARCHAR(50)
)

-- Gather the variables values from the xml table.
SELECT  @strCustomerIds = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strCustomerIds'

SELECT  @strSalesPersonIds = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strSalesPersonIds'

SELECT  @strCategoryCodeIds = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strCategoryCodeIds'

SELECT  @strItemIds = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strItemIds'

SELECT  @strItemDescriptions = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strItemDescriptions'

SELECT  @strAccountStatusCodes = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strAccountStatusCodes'

SELECT  @strSources = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strSources'

SELECT  @strCompanyLocationIds = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strCompanyLocationIds'

SELECT  @dtmBeginningDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmBeginningDateTo = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmTransactionDate'

SELECT  @dtmEndingDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmEndingDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmTransactionDateEnding'

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmBeginningDateTo IS NOT NULL
	SET @dtmBeginningDateTo = CAST(FLOOR(CAST(@dtmBeginningDateTo AS FLOAT)) AS DATETIME)
ELSE 			  
	SET @dtmBeginningDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmBeginningDateFrom IS NOT NULL
	SET @dtmBeginningDateFrom = CAST(FLOOR(CAST(@dtmBeginningDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmBeginningDateFrom = CAST(-53690 AS DATETIME)

IF @dtmEndingDateTo IS NOT NULL
	SET @dtmEndingDateTo = CAST(FLOOR(CAST(@dtmEndingDateTo AS FLOAT)) AS DATETIME)
ELSE 			  
	SET @dtmEndingDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmEndingDateFrom IS NOT NULL
	SET @dtmEndingDateFrom = CAST(FLOOR(CAST(@dtmEndingDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmEndingDateFrom = CAST(-53690 AS DATETIME)

-- SET LOGO
SELECT @blbLogo = dbo.fnSMGetCompanyLogo('Header'), @strLogoType = 'Attachment'
 
SELECT TOP 1 @blbLogo = ISNULL(imgLogo, @blbLogo), @strLogoType = CASE WHEN imgLogo IS NOT NULL THEN 'Logo' ELSE 'Attachment' END
FROM tblSMLogoPreference 
WHERE (intCompanyLocationId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strCompanyLocationIds, '|^|', ','))) OR ISNULL(@strCompanyLocationIds, '') = '')
	AND (ysnARInvoice = 1 OR ysnDefault = 1)

SELECT dtmBeginDate				= MIN(CONVERT(VARCHAR(10), @dtmBeginningDateFrom, 101) + ' - ' + CONVERT(VARCHAR(10), @dtmBeginningDateTo, 101) )
     , dtmEndingDate			= MIN(CONVERT(VARCHAR(10), @dtmEndingDateFrom, 101) + ' - ' + CONVERT(VARCHAR(10), @dtmEndingDateTo, 101) )
	 , dtmTransactionDate		= MIN(dtmTransactionDate)
	 , dtmTransactionDateEnding	= MIN(dtmTransactionDateEnding)
	 , intYear					= MIN(intYear)
	 , intMonth					= MIN(intMonth)
	 , intEntityCustomerId		= MIN(intEntityCustomerId)
	 , intCompanyLocationId		= MIN(intCompanyLocationId)
	 , strName					= strName
	 , strCustomerName			= MIN(strCustomerName)
	 , strCustomerNumber		= MIN(strCustomerNumber)
	 , intSourceId				= MIN(intSourceId)
	 , strInvoiceOriginId		= MIN(strInvoiceOriginId)
	 , intItemId				= MIN(intItemId)
	 , strItemNo				= strItemNo
	 , strDescription			= MIN(strDescription)
	 , intCategoryId			= MIN(intCategoryId)
	 , strCategoryCode			= MIN(strCategoryCode)
	 , strCategoryDescription	= MIN(strCategoryDescription)
	 , strSalesPersonEntityNo	= MIN(strSalesPersonEntityNo)
	 , strSalesPersonName		= MIN(strSalesPersonName)
	 , intSalesPersonId			= MIN(intSalesPersonId)
	 , dblBeginSalesAmount		= SUM(dblBeginSalesAmount)
	 , dblBeginQuantity			= SUM(dblBeginQuantity)
	 , dblEndSalesAmount		= 0
	 , dblEndQuantity 			= 0
	 , strCompanyName		    = strCompanyName
	 , strCompanyAddress		= strCompanyAddress
	 , blbLogo					= @blbLogo
	 , strLogoType				= @strLogoType

 FROM (
      SELECT dtmBeginDate		= CONVERT(VARCHAR(10), @dtmBeginningDateFrom, 101) + ' - ' + CONVERT(VARCHAR(10), @dtmBeginningDateTo, 101) 
     , dtmEndingDate			= CONVERT(VARCHAR(10), @dtmEndingDateFrom, 101) + ' - ' + CONVERT(VARCHAR(10), @dtmEndingDateTo, 101) 
	 , dtmTransactionDate		= dtmTransactionDate
	 , dtmTransactionDateEnding	= dtmTransactionDateEnding
	 , intYear					= intYear
	 , intMonth					= intMonth
	 , intEntityCustomerId		= intEntityCustomerId
	 , intCompanyLocationId		= intCompanyLocationId
	 , strName					= strName
	 , strCustomerName			= strCustomerName
	 , strCustomerNumber		= strCustomerNumber
	 , intSourceId				= intSourceId
	 , strInvoiceOriginId		= strInvoiceOriginId
	 , intItemId				= intItemId
	 , strItemNo				= strItemNo
	 , strDescription			= strDescription
	 , intCategoryId			= intCategoryId
	 , strCategoryCode			= strCategoryCode
	 , strCategoryDescription	= strCategoryDescription
	 , strSalesPersonEntityNo	= strSalesPersonEntityNo
	 , strSalesPersonName		= strSalesPersonName
	 , intSalesPersonId			= intSalesPersonId
	 , dblBeginSalesAmount		= dblSalesAmount
	 , dblBeginQuantity			= dblQuantity
	 , dblEndSalesAmount		= 0
	 , dblEndQuantity 			= 0
FROM vyuARTransactionSummary 
WHERE dtmTransactionDate BETWEEN @dtmBeginningDateFrom AND @dtmBeginningDateTo
  AND (intEntityCustomerId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strCustomerIds, '|^|', ','))) OR ISNULL(@strCustomerIds, '') = '')
  AND (intSalesPersonId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strSalesPersonIds, '|^|', ','))) OR ISNULL(@strSalesPersonIds, '') = '')
  AND (intCategoryId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strCategoryCodeIds, '|^|', ','))) OR ISNULL(@strCategoryCodeIds, '') = '')
  AND (intItemId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strItemIds, '|^|', ','))) OR ISNULL(@strItemIds, '') = '')
  AND (intItemId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strItemDescriptions, '|^|', ','))) OR ISNULL(@strItemDescriptions, '') = '')
  AND (intCompanyLocationId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strCompanyLocationIds, '|^|', ','))) OR ISNULL(@strCompanyLocationIds, '') = '')
  AND (@strAccountStatusCodes + '|^|' LIKE '%' + strAccountStatusCode + '|^|%' OR ISNULL(@strAccountStatusCodes, '') = '' OR @strAccountStatusCodes = strAccountStatusCode)
  AND (@strSources + '|^|' LIKE '%' + strSource + '|^|%' OR ISNULL(@strSources, '') = '' OR @strSources = strSource)

UNION ALL

SELECT dtmBeginDate				= CONVERT(VARCHAR(10), @dtmBeginningDateFrom, 101) + ' - ' + CONVERT(VARCHAR(10), @dtmBeginningDateTo, 101) 
     , dtmEndingDate			= CONVERT(VARCHAR(10), @dtmEndingDateFrom, 101) + ' - ' + CONVERT(VARCHAR(10), @dtmEndingDateTo, 101)
	 , dtmTransactionDate		= dtmTransactionDate
	 , dtmTransactionDateEnding	= dtmTransactionDateEnding
	 , intYear					= intYear
	 , intMonth					= intMonth
	 , intEntityCustomerId		= intEntityCustomerId
	 , intCompanyLocationId		= intCompanyLocationId
	 , strName					= strName
	 , strCustomerName			= strCustomerName
	 , strCustomerNumber		= strCustomerNumber
	 , intSourceId				= intSourceId
	 , strInvoiceOriginId		= strInvoiceOriginId
	 , intItemId				= intItemId
	 , strItemNo				= strItemNo
	 , strDescription			= strDescription
	 , intCategoryId			= intCategoryId
	 , strCategoryCode			= strCategoryCode
	 , strCategoryDescription	= strCategoryDescription
	 , strSalesPersonEntityNo	= strSalesPersonEntityNo
	 , strSalesPersonName		= strSalesPersonName
	 , intSalesPersonId			= intSalesPersonId
	 , dblBeginSalesAmount		= 0
	 , dblBeginQuantity			= 0
	 , dblEndSalesAmount		= dblSalesAmount
	 , dblEndQuantity			= dblQuantity 
FROM vyuARTransactionSummary 
WHERE dtmTransactionDate BETWEEN @dtmEndingDateFrom AND @dtmEndingDateTo
  AND (intEntityCustomerId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strCustomerIds, '|^|', ','))) OR ISNULL(@strCustomerIds, '') = '')
  AND (intSalesPersonId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strSalesPersonIds, '|^|', ','))) OR ISNULL(@strSalesPersonIds, '') = '')
  AND (intCategoryId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strCategoryCodeIds, '|^|', ','))) OR ISNULL(@strCategoryCodeIds, '') = '')
  AND (intItemId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strItemIds, '|^|', ','))) OR ISNULL(@strItemIds, '') = '')
  AND (intItemId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strItemDescriptions, '|^|', ','))) OR ISNULL(@strItemDescriptions, '') = '')
  AND (intCompanyLocationId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strCompanyLocationIds, '|^|', ','))) OR ISNULL(@strCompanyLocationIds, '') = '')
  AND (@strAccountStatusCodes + '|^|' LIKE '%' + strAccountStatusCode + '|^|%' OR ISNULL(@strAccountStatusCodes, '') = '' OR @strAccountStatusCodes = strAccountStatusCode)
  AND (@strSources + '|^|' LIKE '%' + strSource + '|^|%' OR ISNULL(@strSources, '') = '' OR @strSources = strSource)
  ) SUMMARY
   	OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = 
			   dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, 
			   strCity, strState, strZip, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
	) COMPANY

GROUP BY strName, strCustomerNumber, strItemNo ,strCompanyName,strCompanyAddress