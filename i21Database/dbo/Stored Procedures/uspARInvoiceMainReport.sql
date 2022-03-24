CREATE PROCEDURE [dbo].[uspARInvoiceMainReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

IF(OBJECT_ID('tempdb..#DELIMITEDROWS') IS NOT NULL) DROP TABLE #DELIMITEDROWS
IF(OBJECT_ID('tempdb..#INVOICETABLE') IS NOT NULL) DROP TABLE #INVOICETABLE
IF(OBJECT_ID('tempdb..#MCPINVOICES') IS NOT NULL) DROP TABLE #MCPINVOICES
IF(OBJECT_ID('tempdb..#STANDARDINVOICES') IS NOT NULL) DROP TABLE #STANDARDINVOICES

CREATE TABLE #INVOICETABLE
(
	 [intInvoiceId]		INT	NOT NULL PRIMARY KEY
	,[intEntityUserId]	INT	NULL
	,[strRequestId]		NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
	,[strInvoiceFormat]	NVARCHAR(200)	COLLATE Latin1_General_CI_AS	NULL
	,[strType]			NVARCHAR(200)	COLLATE Latin1_General_CI_AS	NULL
	,[ysnStretchLogo]	BIT NULL
);
CREATE TABLE #MCPINVOICES
(
	 [intInvoiceId]		INT	NOT NULL PRIMARY KEY
	,[intEntityUserId]	INT	NULL
	,[strRequestId]		NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
	,[strInvoiceFormat]	NVARCHAR(200)	COLLATE Latin1_General_CI_AS	NULL
	,[strType]			NVARCHAR(200)	COLLATE Latin1_General_CI_AS	NULL
	,[ysnStretchLogo]	BIT NULL
);
CREATE TABLE #STANDARDINVOICES
(
	 [intInvoiceId]		INT	NOT NULL PRIMARY KEY
	,[intEntityUserId]	INT	NULL
	,[strRequestId]		NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
	,[strInvoiceFormat]	NVARCHAR(200)	COLLATE Latin1_General_CI_AS	NULL
	,[strType]			NVARCHAR(200)	COLLATE Latin1_General_CI_AS	NULL
	,[ysnStretchLogo]	BIT NULL
);

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = ''
	BEGIN 
		SET @xmlParam = NULL

		SELECT * FROM #INVOICETABLE
	END

-- Declare the variables.
DECLARE  @dtmDateTo				AS DATETIME
		,@dtmDateFrom			AS DATETIME
		,@strInvoiceIds			AS NVARCHAR(MAX)
		,@strTransactionType	AS NVARCHAR(MAX)
		,@strRequestId			AS NVARCHAR(MAX)
		,@intInvoiceIdTo		AS INT
		,@intInvoiceIdFrom		AS INT
		,@xmlDocumentId			AS INT
		,@intEntityUserId		AS INT
		,@strMainQuery			AS NVARCHAR(MAX)
		,@strReportLogId		AS NVARCHAR(MAX)
			
-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	 [id]			INT IDENTITY(1,1)
	,[fieldname]	NVARCHAR(50)
	,[condition]	NVARCHAR(20)
	,[from]			NVARCHAR(MAX)
	,[to]			NVARCHAR(MAX)
	,[join]			NVARCHAR(10)
	,[begingroup]	NVARCHAR(50)
	,[endgroup]		NVARCHAR(50)
	,[datatype]		NVARCHAR(50)
)

-- Prepare the XML 
EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT, @xmlParam

-- Insert the XML to the xml table. 		
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
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

-- Insert the XML Dummies to the xml table. 		
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
SELECT  @dtmDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmDate'

SELECT  @intInvoiceIdFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE 0 END AS INT)
 	   ,@intInvoiceIdTo   = CASE WHEN [condition] = 'BETWEEN' THEN CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE 0 END AS INT)
							     WHEN [condition] = 'EQUAL TO' THEN CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE 0 END AS INT)
						    END
FROM	@temp_xml_table 
WHERE	[fieldname] = 'intInvoiceId'

SELECT	@intEntityUserId = [from]
FROM	@temp_xml_table
WHERE	[fieldname] = 'intSrCurrentUserId'

SELECT @strInvoiceIds = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strInvoiceIds'

SELECT @strTransactionType = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strTransactionType'

SELECT @strRequestId = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strRequestId'

SELECT @strReportLogId = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strReportLogId'

IF NOT EXISTS(SELECT TOP 1 NULL FROM tblSRReportLog WHERE strReportLogId = @strReportLogId)
	BEGIN
		INSERT INTO tblSRReportLog (strReportLogId, dtmDate)
		VALUES (@strReportLogId, GETDATE())
	END
--ELSE
--	RETURN	

IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateTo = CAST('12/31/2999' AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST('01/01/1900' AS DATETIME)

IF ISNULL(@intInvoiceIdTo, 0) = 0
	SET @intInvoiceIdTo = (SELECT MAX(intInvoiceId) FROM dbo.tblARInvoice)

IF ISNULL(@intInvoiceIdFrom, 0) = 0
	SET @intInvoiceIdFrom = (SELECT MIN(intInvoiceId) FROM dbo.tblARInvoice)

DECLARE @strInvoiceReportName			NVARCHAR(100) = NULL
	  , @strTankDeliveryInvoiceFormat	NVARCHAR(100) = NULL
	  , @strTransportsInvoiceFormat		NVARCHAR(100) = NULL
	  , @strGrainInvoiceFormat			NVARCHAR(100) = NULL
	  , @strMeterBillingInvoiceFormat	NVARCHAR(100) = NULL
	  , @strCreditMemoReportName		NVARCHAR(100) = NULL
	  , @strOtherChargeInvoiceReport	NVARCHAR(100) = NULL
	  , @strOtherChargeCreditMemoReport	NVARCHAR(100) = NULL
	  , @strServiceChargeFormat		    NVARCHAR(100) = NULL
	  , @strCompanyName					NVARCHAR(100) = NULL
	  , @ysnStretchLogo					BIT = 0
	  , @intPerformanceLogId			INT = NULL	  

SELECT TOP 1 @strInvoiceReportName				= ISNULL(strInvoiceReportName, 'Standard')
		   , @strTankDeliveryInvoiceFormat		= ISNULL(strTankDeliveryInvoiceFormat, ISNULL(strInvoiceReportName, 'Standard'))
		   , @strTransportsInvoiceFormat		= ISNULL(strTransportsInvoiceFormat, ISNULL(strInvoiceReportName, 'Standard'))
		   , @strGrainInvoiceFormat				= ISNULL(strGrainInvoiceFormat, ISNULL(strInvoiceReportName, 'Standard'))
		   , @strMeterBillingInvoiceFormat		= ISNULL(strMeterBillingInvoiceFormat, ISNULL(strInvoiceReportName, 'Standard'))
		   , @strCreditMemoReportName			= ISNULL(strCreditMemoReportName, ISNULL(strInvoiceReportName, 'Standard'))
		   , @strOtherChargeInvoiceReport		= ISNULL(strOtherChargeInvoiceReportName, ISNULL(strInvoiceReportName, 'Standard'))
		   , @strOtherChargeCreditMemoReport	= ISNULL(strOtherChargeCreditMemoReportName, ISNULL(strCreditMemoReportName, 'Standard'))
		   , @strServiceChargeFormat			= ISNULL(strServiceChargeFormat, ISNULL(strInvoiceReportName, 'Standard'))
		   , @ysnStretchLogo					= ISNULL(ysnStretchLogo, 0)
FROM dbo.tblARCompanyPreference WITH (NOLOCK)

EXEC dbo.uspARLogPerformanceRuntime 'Invoice Report', 'uspARInvoiceMainReport', @strRequestId, 1, @intEntityUserId, NULL, @intPerformanceLogId OUT

SET @strInvoiceReportName = ISNULL(@strInvoiceReportName, 'Standard')
SET @strTankDeliveryInvoiceFormat = ISNULL(@strTankDeliveryInvoiceFormat, 'Standard')
SET @strTransportsInvoiceFormat = ISNULL(@strTransportsInvoiceFormat, 'Standard')
SET @strGrainInvoiceFormat = ISNULL(@strGrainInvoiceFormat, 'Standard')
SET @strMeterBillingInvoiceFormat = ISNULL(@strMeterBillingInvoiceFormat, 'Standard')
SET @strCreditMemoReportName = ISNULL(@strInvoiceReportName, 'Standard')
SET @strServiceChargeFormat = ISNULL(@strServiceChargeFormat, 'Standard')
SET @ysnStretchLogo = ISNULL(@ysnStretchLogo, 0)
SET @strCompanyName = (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup WHERE strCompanyName LIKE '%Cel Oil%')

--GET INVOICES WITH FILTERS
SET @strMainQuery = CAST('' AS NVARCHAR(MAX)) + 
'INSERT INTO #INVOICETABLE WITH (TABLOCK) (
	intInvoiceId
  , intEntityUserId
  , strRequestId
  , strType
  , ysnStretchLogo
  , strInvoiceFormat  
)
SELECT intInvoiceId			= INVOICE.intInvoiceId
	 , intEntityUserId		= ' + CAST(@intEntityUserId AS NVARCHAR(10)) + '
	 , strRequestId			= ''' + @strRequestId + '''
	 , strType				= INVOICE.strType
	 , ysnStretchLogo		= ' + CAST(@ysnStretchLogo AS NVARCHAR(2)) + '
	 , strInvoiceFormat		= CASE WHEN INVOICE.strType IN (''Software'', ''Standard'') THEN
	 									CASE WHEN ISNULL(INVENTORY.intInvoiceId, 0) <> 0 THEN 
												CASE WHEN ISNULL(TICKET.intInvoiceId, 0) <> 0 
													 THEN ''' + @strGrainInvoiceFormat + '''
													 ELSE ''' + @strInvoiceReportName + '''
												END
											 ELSE
												CASE WHEN INVOICE.strTransactionType IN (''Invoice'', ''Debit Memo'', ''Cash'', ''Proforma Invoice'')
													 THEN ''' + @strOtherChargeInvoiceReport + '''
													 ELSE ''' + @strOtherChargeCreditMemoReport + '''
												END
										END
								   WHEN INVOICE.strType IN (''Service Charge'') THEN ''' + @strServiceChargeFormat + '''
								   WHEN INVOICE.strType IN (''Tank Delivery'') THEN ''' + @strTankDeliveryInvoiceFormat + '''
								   WHEN INVOICE.strType IN (''Transport Delivery'') THEN ''' + @strTransportsInvoiceFormat + '''
								   WHEN INVOICE.strType IN (''Meter Billing'') THEN ''' + @strMeterBillingInvoiceFormat + '''
								   ELSE ''' + @strInvoiceReportName + '''
							   END								
FROM dbo.tblARInvoice INVOICE WITH (NOLOCK)
LEFT JOIN (
	SELECT intInvoiceId
	FROM dbo.tblARInvoiceDetail DETAIL
	WHERE DETAIL.intTicketId IS NOT NULL
	GROUP BY DETAIL.intInvoiceId
) TICKET ON INVOICE.intInvoiceId = TICKET.intInvoiceId
LEFT JOIN (
	SELECT intInvoiceId
	FROM dbo.tblARInvoiceDetail DETAIL
	INNER JOIN tblICItem ITEM ON DETAIL.intItemId = ITEM.intItemId
	WHERE DETAIL.intItemId IS NOT NULL
	  AND ITEM.strType NOT IN (''Comment'', ''Other Charge'', ''Non-Inventory'')
	GROUP BY DETAIL.intInvoiceId
) INVENTORY ON INVOICE.intInvoiceId = INVENTORY.intInvoiceId
WHERE INVOICE.dtmDate BETWEEN ' + ''''+ CONVERT(NVARCHAR(50),@dtmDateFrom, 110) + ''' AND ''' + CONVERT(NVARCHAR(50),@dtmDateTo, 110) + '''
  AND INVOICE.intInvoiceId BETWEEN ' + CAST(@intInvoiceIdFrom AS NVARCHAR(100)) + ' AND ' + CAST(@intInvoiceIdTo AS NVARCHAR(100)) + ''

IF @strTransactionType IS NOT NULL
  SET @strMainQuery += ' AND INVOICE.strTransactionType = ' + '''' + @strTransactionType  + '''' 

SET @strMainQuery += ' ORDER BY INVOICE.intInvoiceId'

EXEC sp_executesql @strMainQuery

IF ISNULL(@strInvoiceIds, '') <> ''
	BEGIN
		SELECT DISTINCT intInvoiceId = intID 
		INTO #DELIMITEDROWS
		FROM fnGetRowsFromDelimitedValues(@strInvoiceIds)

		DELETE INVOICE 
		FROM #INVOICETABLE INVOICE
		LEFT JOIN #DELIMITEDROWS DR ON INVOICE.intInvoiceId = DR.intInvoiceId
		WHERE ISNULL(DR.intInvoiceId, 0) = 0
	END

UPDATE #INVOICETABLE SET strInvoiceFormat = 'Format 3 - Swink' WHERE strInvoiceFormat = 'Format 1 - Swink'

INSERT INTO #MCPINVOICES
SELECT * FROM #INVOICETABLE WHERE strInvoiceFormat IN ('Format 1 - MCP', 'Format 5 - Honstein')

IF EXISTS (SELECT TOP 1 NULL FROM #MCPINVOICES) AND @strCompanyName IS NULL
	EXEC dbo.[uspARInvoiceMCPReport] @intEntityUserId, @strRequestId
ELSE IF EXISTS (SELECT TOP 1 NULL FROM #MCPINVOICES)
	EXEC dbo.[uspARInvoiceMCPReportCustom] @intEntityUserId, @strRequestId

INSERT INTO #STANDARDINVOICES
SELECT * FROM #INVOICETABLE WHERE strInvoiceFormat NOT IN ('Format 1 - MCP', 'Format 5 - Honstein')

IF EXISTS (SELECT TOP 1 NULL FROM #STANDARDINVOICES)
	EXEC dbo.[uspARInvoiceReport] @intEntityUserId, @strRequestId

SELECT * FROM #INVOICETABLE

EXEC dbo.uspARLogPerformanceRuntime 'Invoice Report', 'uspARInvoiceMainReport', @strRequestId, 0, @intEntityUserId, @intPerformanceLogId, NULL