CREATE PROCEDURE [dbo].[uspARSalesComparativeReport]
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
	  , @intEntityUserId				INT	= NULL
	  , @strSalesperson					NVARCHAR(100)
	  , @strCustomerName				NVARCHAR(MAX)
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
SELECT  @strCustomerName = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strCustomerName'

SELECT  @strSalesperson = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strSalespersonName'


SELECT  @dtmBeginningDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmBeginningDateTo = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmTransactionDate'

SELECT  @dtmEndingDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmEndingDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmTransactionDateEnding'

SELECT  @intEntityUserId = NULLIF(CAST(ISNULL([from], '') AS INT), 0)
FROM	@temp_xml_table
WHERE	[fieldname] = 'intSrCurrentUserId'

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

SELECT CONVERT(VARCHAR(10), @dtmBeginningDateFrom, 101) + ' - ' + CONVERT(VARCHAR(10), @dtmBeginningDateTo, 101) dtmBeginDate,CONVERT(VARCHAR(10), @dtmEndingDateFrom, 101) + ' - ' + CONVERT(VARCHAR(10), @dtmEndingDateTo, 101) dtmEndingDate,dtmTransactionDate,dtmTransactionDateEnding,intYear,intMonth,intEntityCustomerId,intCompanyLocationId,strName,strCustomerName,strCustomerNumber,intSourceId,strInvoiceOriginId,intItemId,strItemNo,strDescription,intCategoryId,strCategoryCode,strCategoryDescription,strSalesPersonEntityNo,strSalesPersonName,intSalesPersonId,dblSalesAmount as dblBeginSalesAmount,dblQuantity as dblBeginQuantity,0 as dblEndSalesAmount,0 as dblEndQuantity FROM vyuARTransactionSummary WHERE dtmTransactionDate BETWEEN @dtmBeginningDateFrom AND @dtmBeginningDateTo
UNION
SELECT CONVERT(VARCHAR(10), @dtmBeginningDateFrom, 101) + ' - ' + CONVERT(VARCHAR(10), @dtmBeginningDateTo, 101) dtmBeginDate,CONVERT(VARCHAR(10), @dtmEndingDateFrom, 101) + ' - ' + CONVERT(VARCHAR(10), @dtmEndingDateTo, 101) dtmEndingDate,dtmTransactionDate,dtmTransactionDateEnding,intYear,intMonth,intEntityCustomerId,intCompanyLocationId,strName,strCustomerName,strCustomerNumber,intSourceId,strInvoiceOriginId,intItemId,strItemNo,strDescription,intCategoryId,strCategoryCode,strCategoryDescription,strSalesPersonEntityNo,strSalesPersonName,intSalesPersonId,0 as dblBeginSalesAmount,0 as dblBeginQuantity,dblSalesAmount as dblEndSalesAmount,dblQuantity as dblEndQuantity FROM vyuARTransactionSummary WHERE dtmTransactionDate BETWEEN @dtmEndingDateFrom AND @dtmEndingDateTo
