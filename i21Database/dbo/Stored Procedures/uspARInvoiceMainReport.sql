CREATE PROCEDURE [dbo].[uspARInvoiceMainReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @INVOICETABLE 		AS dbo.InvoiceReportTable
DECLARE @MCPINVOICES  		AS dbo.InvoiceReportTable
DECLARE @STANDARDINVOICES	AS dbo.InvoiceReportTable

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = ''
	BEGIN 
		SET @xmlParam = NULL

		SELECT * FROM @INVOICETABLE
	END

-- Declare the variables.
DECLARE  @dtmDateTo						AS DATETIME
		,@dtmDateFrom					AS DATETIME
		,@strInvoiceIds					AS NVARCHAR(MAX)
		,@strTransactionType			AS NVARCHAR(MAX)
		,@strRequestId					AS NVARCHAR(MAX)
		,@intInvoiceIdTo				AS INT
		,@intInvoiceIdFrom				AS INT
		,@xmlDocumentId					AS INT
		,@intEntityUserId				AS INT
		
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

--GET INVOICES WITH FILTERS
INSERT INTO @INVOICETABLE (
	intInvoiceId
  , intEntityUserId
  , strRequestId
  , strType
  , strInvoiceFormat  
)
SELECT intInvoiceId			= INVOICE.intInvoiceId
	 , intEntityUserId		= @intEntityUserId
	 , strRequestId			= @strRequestId
	 , strType				= INVOICE.strType
	 , strInvoiceFormat		= CASE WHEN INVOICE.strType IN ('Software', 'Standard') THEN 
	 									CASE WHEN ISNULL(TICKET.intTicketId, 0) <> 0 THEN ISNULL(COMPANYPREFERENCE.strGrainInvoiceFormat, 'Standard') 
											 ELSE ISNULL(COMPANYPREFERENCE.strInvoiceReportName, 'Standard') 
										END
								   WHEN INVOICE.strType IN ('Tank Delivery') THEN ISNULL(COMPANYPREFERENCE.strTankDeliveryInvoiceFormat, 'Standard')
								   WHEN INVOICE.strType IN ('Transport Delivery') THEN ISNULL(COMPANYPREFERENCE.strTransportsInvoiceFormat, 'Standard')
								   WHEN INVOICE.strType IN ('Meter Billing') THEN 'Meter Billing'
								   ELSE ISNULL(COMPANYPREFERENCE.strInvoiceReportName, 'Standard')
							   END								
FROM dbo.tblARInvoice INVOICE WITH (NOLOCK)
OUTER APPLY (
	SELECT TOP 1 strReportGroupName
			   , strInvoiceReportName
			   , strCreditMemoReportName
			   , strTankDeliveryInvoiceFormat
			   , strTransportsInvoiceFormat
			   , strGrainInvoiceFormat
	FROM dbo.tblARCompanyPreference WITH (NOLOCK)
) COMPANYPREFERENCE
OUTER APPLY (
	SELECT TOP 1 intTicketId
	FROM dbo.tblARInvoiceDetail DETAIL
	WHERE DETAIL.intInvoiceId = INVOICE.intInvoiceId
	  AND DETAIL.intTicketId IS NOT NULL
) TICKET
WHERE INVOICE.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
  AND INVOICE.intInvoiceId BETWEEN @intInvoiceIdFrom AND @intInvoiceIdTo
  AND ((@strTransactionType IS NOT NULL AND INVOICE.strTransactionType = @strTransactionType) OR @strTransactionType IS NULL)
ORDER BY INVOICE.intInvoiceId

IF ISNULL(@strInvoiceIds, '') <> ''
	BEGIN
		DELETE INVOICE 
		FROM @INVOICETABLE INVOICE
		WHERE INVOICE.intInvoiceId NOT IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@strInvoiceIds))
	END

INSERT INTO @MCPINVOICES
SELECT * FROM @INVOICETABLE WHERE strInvoiceFormat IN ('Format 1 - MCP')

IF EXISTS (SELECT TOP 1 NULL FROM @MCPINVOICES)
	EXEC dbo.[uspARInvoiceMCPReport] @MCPINVOICES, @intEntityUserId, @strRequestId

INSERT INTO @STANDARDINVOICES
SELECT * FROM @INVOICETABLE WHERE strInvoiceFormat NOT IN ('Format 1 - MCP')

IF EXISTS (SELECT TOP 1 NULL FROM @STANDARDINVOICES)
	EXEC dbo.[uspARInvoiceReport] @STANDARDINVOICES, @intEntityUserId, @strRequestId

SELECT * FROM @INVOICETABLE