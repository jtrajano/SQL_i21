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
		,@strReportLogId				AS NVARCHAR(MAX)
		
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
	  , @ysnStretchLogo					BIT = 0

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

SET @strInvoiceReportName = ISNULL(@strInvoiceReportName, 'Standard')
SET @strTankDeliveryInvoiceFormat = ISNULL(@strTankDeliveryInvoiceFormat, 'Standard')
SET @strTransportsInvoiceFormat = ISNULL(@strTransportsInvoiceFormat, 'Standard')
SET @strGrainInvoiceFormat = ISNULL(@strGrainInvoiceFormat, 'Standard')
SET @strMeterBillingInvoiceFormat = ISNULL(@strMeterBillingInvoiceFormat, 'Standard')
SET @strCreditMemoReportName = ISNULL(@strInvoiceReportName, 'Standard')
SET @strServiceChargeFormat = ISNULL(@strServiceChargeFormat, 'Standard')
SET @ysnStretchLogo = ISNULL(@ysnStretchLogo, 0)

--GET INVOICES WITH FILTERS
INSERT INTO @INVOICETABLE (
	intInvoiceId
  , intEntityUserId
  , strRequestId
  , strType
  , ysnStretchLogo
  , strInvoiceFormat  
)
SELECT intInvoiceId			= INVOICE.intInvoiceId
	 , intEntityUserId		= @intEntityUserId
	 , strRequestId			= @strRequestId
	 , strType				= INVOICE.strType
	 , ysnStretchLogo		= @ysnStretchLogo
	 , strInvoiceFormat		= CASE WHEN INVOICE.strType IN ('Software', 'Standard') THEN
	 									CASE WHEN ISNULL(INVENTORY.intInvoiceId, 0) <> 0 THEN 
												CASE WHEN ISNULL(TICKET.intInvoiceId, 0) <> 0 
													 THEN @strGrainInvoiceFormat
													 ELSE @strInvoiceReportName
												END
											 ELSE
												CASE WHEN INVOICE.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice')
													 THEN @strOtherChargeInvoiceReport
													 ELSE @strOtherChargeCreditMemoReport
												END
										END
								   WHEN INVOICE.strType IN ('Service Charge') THEN @strServiceChargeFormat
								   WHEN INVOICE.strType IN ('Tank Delivery') THEN @strTankDeliveryInvoiceFormat
								   WHEN INVOICE.strType IN ('Transport Delivery') THEN @strTransportsInvoiceFormat
								   WHEN INVOICE.strType IN ('Meter Billing') THEN @strMeterBillingInvoiceFormat
								   ELSE @strInvoiceReportName
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
	  AND ITEM.strType NOT IN ('Comment', 'Other Charge', 'Non-Inventory')
	GROUP BY DETAIL.intInvoiceId
) INVENTORY ON INVOICE.intInvoiceId = INVENTORY.intInvoiceId
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

UPDATE @INVOICETABLE SET strInvoiceFormat = 'Format 3 - Swink' WHERE strInvoiceFormat = 'Format 1 - Swink'

INSERT INTO @MCPINVOICES
SELECT * FROM @INVOICETABLE WHERE strInvoiceFormat IN ('Format 1 - MCP', 'Format 5 - Honstein')

IF EXISTS (SELECT TOP 1 NULL FROM @MCPINVOICES)
	EXEC dbo.[uspARInvoiceMCPReport] @MCPINVOICES, @intEntityUserId, @strRequestId

INSERT INTO @STANDARDINVOICES
SELECT * FROM @INVOICETABLE WHERE strInvoiceFormat NOT IN ('Format 1 - MCP', 'Format 5 - Honstein')

IF EXISTS (SELECT TOP 1 NULL FROM @STANDARDINVOICES)
	EXEC dbo.[uspARInvoiceReport] @STANDARDINVOICES, @intEntityUserId, @strRequestId

SELECT * FROM @INVOICETABLE