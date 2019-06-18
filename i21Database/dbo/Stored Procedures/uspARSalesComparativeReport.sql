﻿CREATE PROCEDURE [dbo].[uspARSalesComparativeReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
IF LTRIM(RTRIM(@xmlParam)) = ''
	BEGIN 
		SET @xmlParam = NULL
		
		SELECT * FROM vyuARTransactionSummary
	END

DECLARE @dtmBeginningDateTo				DATETIME
      , @dtmBeginningDateFrom			DATETIME
	  , @dtmEndingDateTo				DATETIME
      , @dtmEndingDateFrom				DATETIME
	  , @intEntityCustomerId			INT	= NULL
	  , @strSalesperson					NVARCHAR(100)
	  , @strName						NVARCHAR(MAX)
	  , @strCustomerNumber				NVARCHAR(MAX)
	  , @strAccountStatusCode			NVARCHAR(MAX)
	  , @strCategoryCode				NVARCHAR(300)
	  , @strItemNo						NVARCHAR(300)
	  , @strLocationName				NVARCHAR(300)
	  , @intCompanyLocationId			INT = NULL
	  , @xmlDocumentId					INT

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
SELECT  @strName = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strName'

SELECT  @strCustomerNumber = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strCustomerNumber'

SELECT  @strSalesperson = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strSalespersonName'

SELECT  @strCategoryCode = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strCategoryCode'

SELECT  @strItemNo = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strItemNo'

SELECT  @strAccountStatusCode = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strAccountStatusCode'

SELECT  @strLocationName = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strLocationName'

SELECT  @intCompanyLocationId = intCompanyLocationId
FROM	tblSMCompanyLocation
WHERE	strLocationName = @strLocationName

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
	 , dblBeginSalesAmount		= dblSalesAmount
	 , dblBeginQuantity			= dblQuantity
	 , dblEndSalesAmount		= 0
	 , dblEndQuantity 			= 0
FROM vyuARTransactionSummary 
WHERE dtmTransactionDate BETWEEN @dtmBeginningDateFrom AND @dtmBeginningDateTo
  AND (@strName IS NULL OR strName = @strName)
  AND (@strCustomerNumber IS NULL OR strCustomerNumber = @strCustomerNumber)
  AND (@strSalesperson IS NULL OR strSalesPersonName = @strSalesperson)
  AND (@strCategoryCode IS NULL OR strCategoryCode = @strCategoryCode)
  AND (@strItemNo IS NULL OR strItemNo = @strItemNo)
  AND (@strAccountStatusCode IS NULL OR strAccountStatusCode = @strAccountStatusCode)
  AND (@intCompanyLocationId IS NULL OR intCompanyLocationId = @intCompanyLocationId)

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
  AND (@strName IS NULL OR strName = @strName)
  AND (@strCustomerNumber IS NULL OR strCustomerNumber = @strCustomerNumber)
  AND (@strSalesperson IS NULL OR strSalesPersonName = @strSalesperson)
  AND (@strCategoryCode IS NULL OR strCategoryCode = @strCategoryCode)
  AND (@strItemNo IS NULL OR strItemNo = @strItemNo)
  AND (@strAccountStatusCode IS NULL OR strAccountStatusCode = @strAccountStatusCode)
  AND (@intCompanyLocationId IS NULL OR intCompanyLocationId = @intCompanyLocationId)
