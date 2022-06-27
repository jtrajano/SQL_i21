CREATE PROCEDURE [dbo].[uspARSalesTrendReport]
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

DECLARE @dtmTransactionDateTo			DATETIME
      , @dtmTransactionDateFrom			DATETIME
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

SELECT  @dtmTransactionDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmTransactionDateTo = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmTransactionDate'

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmTransactionDateTo IS NOT NULL
	SET @dtmTransactionDateTo = CAST(FLOOR(CAST(@dtmTransactionDateTo AS FLOAT)) AS DATETIME)
ELSE 			  
	SET @dtmTransactionDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmTransactionDateFrom IS NOT NULL
	SET @dtmTransactionDateFrom = CAST(FLOOR(CAST(@dtmTransactionDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmTransactionDateFrom = CAST(-53690 AS DATETIME)

SELECT @blbLogo = dbo.fnSMGetCompanyLogo('Header')

DELETE FROM tblARSalesTrendStagingTable

INSERT INTO tblARSalesTrendStagingTable
SELECT *
,CASE WHEN intMonth = 1  THEN dblQuantity   ELSE 0 END AS dblJanuary
,CASE WHEN intMonth = 2  THEN dblQuantity   ELSE 0 END AS dblFebruary
,CASE WHEN intMonth = 3  THEN dblQuantity   ELSE 0 END AS dblMarch
,CASE WHEN intMonth = 4  THEN dblQuantity   ELSE 0 END AS dblApril
,CASE WHEN intMonth = 5  THEN dblQuantity   ELSE 0 END AS dblMay
,CASE WHEN intMonth = 6  THEN dblQuantity   ELSE 0 END AS dblJune
,CASE WHEN intMonth = 7  THEN dblQuantity   ELSE 0 END AS dblJuly
,CASE WHEN intMonth = 8  THEN dblQuantity   ELSE 0 END AS dblAugust
,CASE WHEN intMonth = 9  THEN dblQuantity   ELSE 0 END AS dblSeptember
,CASE WHEN intMonth = 10 THEN dblQuantity   ELSE 0 END AS dblOctober
,CASE WHEN intMonth = 11 THEN dblQuantity   ELSE 0 END AS dblNovember
,CASE WHEN intMonth = 12 THEN dblQuantity   ELSE 0 END AS dblDecember
,CASE WHEN intMonth = 1  THEN dblSalesAmount ELSE 0 END AS dblSalesJanuary
,CASE WHEN intMonth = 2  THEN dblSalesAmount ELSE 0 END AS dblSalesFebruary
,CASE WHEN intMonth = 3  THEN dblSalesAmount ELSE 0 END AS dblSalesMarch
,CASE WHEN intMonth = 4  THEN dblSalesAmount ELSE 0 END AS dblSalesApril
,CASE WHEN intMonth = 5  THEN dblSalesAmount ELSE 0 END AS dblSalesMay
,CASE WHEN intMonth = 6  THEN dblSalesAmount ELSE 0 END AS dblSalesJune
,CASE WHEN intMonth = 7  THEN dblSalesAmount ELSE 0 END AS dblSalesJuly
,CASE WHEN intMonth = 8  THEN dblSalesAmount ELSE 0 END AS dblSalesAugust
,CASE WHEN intMonth = 9  THEN dblSalesAmount ELSE 0 END AS dblSalesSeptember
,CASE WHEN intMonth = 10 THEN dblSalesAmount ELSE 0 END AS dblSalesOctober
,CASE WHEN intMonth = 11 THEN dblSalesAmount ELSE 0 END AS dblSalesNovember
,CASE WHEN intMonth = 12 THEN dblSalesAmount ELSE 0 END AS dblSalesDecember
,CASE intMonth
	WHEN 1 THEN 'January' 
	WHEN 2 THEN 'February' 
	WHEN 3 THEN 'March' 
	WHEN 4 THEN 'April' 
	WHEN 5 THEN 'May' 
	WHEN 6 THEN 'June' 
	WHEN 7 THEN 'July' 
	WHEN 8 THEN 'August' 
	WHEN 9 THEN 'September' 
	WHEN 10 THEN 'October' 
	WHEN 11 THEN 'November' 
	WHEN 12 THEN 'December' 
	ELSE '' END AS strMonth
, strLogoType	= CASE WHEN SMLP.imgLogo IS NOT NULL THEN 'Logo' ELSE 'Attachment' END
, blbLogo		= ISNULL(SMLP.imgLogo, @blbLogo)
FROM vyuARTransactionSummary ARTS
LEFT JOIN tblSMLogoPreference SMLP ON SMLP.intCompanyLocationId = ARTS.intCompanyLocationId AND (ysnARInvoice = 1 OR ysnDefault = 1)
WHERE dtmTransactionDate BETWEEN @dtmTransactionDateFrom AND @dtmTransactionDateTo
  AND (intEntityCustomerId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strCustomerIds, '|^|', ','))) OR ISNULL(@strCustomerIds, '') = '')
  AND (intSalesPersonId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strSalesPersonIds, '|^|', ','))) OR ISNULL(@strSalesPersonIds, '') = '')
  AND (intCategoryId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strCategoryCodeIds, '|^|', ','))) OR ISNULL(@strCategoryCodeIds, '') = '')
  AND (intItemId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strItemIds, '|^|', ','))) OR ISNULL(@strItemIds, '') = '')
  AND (intItemId IN (
		SELECT intItemId
		FROM tblICItem
		WHERE strDescription IN (
			SELECT strDescription
			FROM tblICItem
			WHERE intItemId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strItemDescriptions, '|^|', ',')))
		)) OR ISNULL(@strItemDescriptions, '') = '')
  AND (ARTS.intCompanyLocationId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(REPLACE (@strCompanyLocationIds, '|^|', ','))) OR ISNULL(@strCompanyLocationIds, '') = '')
  AND (@strAccountStatusCodes + '|^|' LIKE '%' + strAccountStatusCode + '|^|%' OR ISNULL(@strAccountStatusCodes, '') = '' OR @strAccountStatusCodes = strAccountStatusCode)
  AND (@strSources + '|^|' LIKE '%' + strSource + '|^|%' OR ISNULL(@strSources, '') = '' OR @strSources = strSource)

SELECT *
FROM tblARSalesTrendStagingTable

RETURN 0
