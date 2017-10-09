CREATE PROCEDURE [dbo].[uspARCustomerAgingDetailReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = ''
	BEGIN 
		SET @xmlParam = NULL

		SELECT * FROM tblARCustomerAgingStagingTable
	END

-- Declare the variables.
DECLARE @dtmDateTo				DATETIME
      , @dtmDateFrom			DATETIME
	  , @strSalesperson			NVARCHAR(100)
	  , @strCustomerName		NVARCHAR(100)
	  , @xmlDocumentId			INT
	  , @query					NVARCHAR(MAX)
	  , @filter					NVARCHAR(MAX) = ''
	  , @fieldname				NVARCHAR(50)
	  , @condition				NVARCHAR(20)
	  , @id						INT 
	  , @from					NVARCHAR(100)
	  , @to						NVARCHAR(100)
	  , @join					NVARCHAR(10)
	  , @begingroup				NVARCHAR(50)
	  , @endgroup				NVARCHAR(50)
	  , @datatype				NVARCHAR(50)
	  , @strSourceTransaction	NVARCHAR(50)
		
-- Create a table variable to hold the XML data. 		
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

DECLARE @temp_open_invoices TABLE (intInvoiceId INT)

-- Prepare the XML 
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

-- Gather the variables values from the xml table.
SELECT  @strCustomerName = ISNULL([from], '')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strCustomerName'

SELECT  @strSalesperson = ISNULL([from], '')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strSalespersonName'

SELECT  @dtmDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmAsOfDate'

SELECT  @strSourceTransaction = ISNULL([from], '')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strSourceTransaction'

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)
ELSE 			  
	SET @dtmDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST(-53690 AS DATETIME)

TRUNCATE TABLE tblARCustomerAgingStagingTable
INSERT INTO tblARCustomerAgingStagingTable (
	   strCustomerName
	, strCustomerNumber
	, strInvoiceNumber
	, strRecordNumber
	, intInvoiceId
	, strBOLNumber
	, intEntityCustomerId
	, dblCreditLimit
	, dblTotalAR
	, dblFuture
	, dbl0Days
	, dbl10Days
	, dbl30Days
	, dbl60Days
	, dbl90Days
	, dbl91Days
	, dblTotalDue
	, dblAmountPaid
	, dblInvoiceTotal
	, dblCredits
	, dblPrepayments
	, dblPrepaids
	, dtmDate
	, dtmDueDate
	, dtmAsOfDate
	, strSalespersonName
	, intCompanyLocationId
	, strSourceTransaction
	, strCompanyName
	, strCompanyAddress
)
EXEC dbo.uspARCustomerAgingDetailAsOfDateReport @dtmDateFrom = @dtmDateFrom
											  , @dtmDateTo = @dtmDateTo
											  , @strSalesperson = @strSalesperson
											  , @strSourceTransaction = @strSourceTransaction
											  , @strCustomerName = @strCustomerName

DELETE FROM tblARCustomerAgingStagingTable WHERE intEntityCustomerId IN (SELECT intEntityCustomerId FROM tblARCustomerAgingStagingTable GROUP BY intEntityCustomerId HAVING SUM(ISNULL(dblTotalAR, 0)) = 0)

INSERT INTO @temp_open_invoices
SELECT DISTINCT intInvoiceId FROM tblARCustomerAgingStagingTable GROUP BY intInvoiceId HAVING SUM(ISNULL(dblTotalAR, 0)) <> 0

SELECT AGING.* FROM tblARCustomerAgingStagingTable AGING
INNER JOIN @temp_open_invoices UNPAID ON AGING.intInvoiceId = UNPAID.intInvoiceId