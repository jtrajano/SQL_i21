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
	  , @strAccountStatusCode	NVARCHAR(5)
	  , @strCompanyLocation		NVARCHAR(100)
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
	  , @strAgedBalances				AS NVARCHAR(100)
	  , @ysnPrintOnlyOverCreditLimit	AS BIT
	  , @intEntityUserId		INT
		
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

SELECT  @strAccountStatusCode = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strAccountStatusCode'

SELECT  @strCompanyLocation = REPLACE(ISNULL([from], ''), '''''', '''')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strCompanyLocation'

SELECT  @dtmDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmAsOfDate'

SELECT  @strSourceTransaction = ISNULL([from], '')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strSourceTransaction'

SELECT	@strAgedBalances = ISNULL([from], 'All')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strAgedBalances'

SELECT	@ysnPrintOnlyOverCreditLimit = CASE WHEN ISNULL([from], 'False') = 'False' THEN 0 ELSE 1 END
FROM	@temp_xml_table
WHERE	[fieldname] = 'ysnPrintOnlyOverCreditLimit'

SELECT	@intEntityUserId = [from]
FROM	@temp_xml_table 
WHERE	[fieldname] = 'intSrCurrentUserId'

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)
ELSE 			  
	SET @dtmDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST(-53690 AS DATETIME)

SET @intEntityUserId = NULLIF(@intEntityUserId, 0)

EXEC dbo.uspARCustomerAgingDetailAsOfDateReport @dtmDateFrom = @dtmDateFrom
											  , @dtmDateTo = @dtmDateTo
											  , @strSalesperson = @strSalesperson
											  , @strSourceTransaction = @strSourceTransaction
											  , @strCompanyLocation = @strCompanyLocation
											  , @strCustomerName = @strCustomerName
											  , @strAccountStatusCode = @strAccountStatusCode
											  , @ysnInclude120Days = 0
											  , @intEntityUserId = @intEntityUserId

DELETE AGING
FROM tblARCustomerAgingStagingTable AGING
INNER JOIN (
	SELECT intEntityCustomerId 
	FROM tblARCustomerAgingStagingTable 
	WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'
	GROUP BY intEntityCustomerId 
	HAVING SUM(ISNULL(dblTotalAR, 0)) = 0
		AND SUM(ISNULL(dblCredits, 0)) = 0
		AND SUM(ISNULL(dblPrepayments, 0)) = 0
) ENTITY ON AGING.intEntityCustomerId = ENTITY.intEntityCustomerId
WHERE AGING.intEntityUserId = @intEntityUserId
  AND AGING.strAgingType = 'Detail'

IF @strAgedBalances = 'Current'
	BEGIN 
		DELETE AGING 
		FROM tblARCustomerAgingStagingTable AGING
		INNER JOIN (
			SELECT intEntityCustomerId 
			FROM tblARCustomerAgingStagingTable 
			WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'
			GROUP BY intEntityCustomerId 
			HAVING SUM(ISNULL(dbl0Days, 0)) = 0
		) ENTITY ON AGING.intEntityCustomerId = ENTITY.intEntityCustomerId
		WHERE AGING.intEntityUserId = @intEntityUserId AND AGING.strAgingType = 'Detail'
	END
ELSE IF @strAgedBalances = '1-10 Days'
	BEGIN 
		DELETE FROM tblARCustomerAgingStagingTable WHERE intEntityCustomerId IN (SELECT intEntityCustomerId FROM tblARCustomerAgingStagingTable GROUP BY intEntityCustomerId HAVING SUM(ISNULL(dbl10Days, 0)) = 0)
		DELETE AGING 
		FROM tblARCustomerAgingStagingTable AGING
		INNER JOIN (
			SELECT intEntityCustomerId 
			FROM tblARCustomerAgingStagingTable 
			WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'
			GROUP BY intEntityCustomerId 
			HAVING SUM(ISNULL(dbl10Days, 0)) = 0
		) ENTITY ON AGING.intEntityCustomerId = ENTITY.intEntityCustomerId
		WHERE AGING.intEntityUserId = @intEntityUserId AND AGING.strAgingType = 'Detail'
	END
ELSE IF @strAgedBalances = '11-30 Days'
	BEGIN 
		DELETE AGING 
		FROM tblARCustomerAgingStagingTable AGING
		INNER JOIN (
			SELECT intEntityCustomerId 
			FROM tblARCustomerAgingStagingTable 
			WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'
			GROUP BY intEntityCustomerId 
			HAVING SUM(ISNULL(dbl30Days, 0)) = 0
		) ENTITY ON AGING.intEntityCustomerId = ENTITY.intEntityCustomerId
		WHERE AGING.intEntityUserId = @intEntityUserId AND AGING.strAgingType = 'Detail'
	END
ELSE IF @strAgedBalances = '31-60 Days'
	BEGIN 
		DELETE AGING 
		FROM tblARCustomerAgingStagingTable AGING
		INNER JOIN (
			SELECT intEntityCustomerId 
			FROM tblARCustomerAgingStagingTable 
			WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'
			GROUP BY intEntityCustomerId 
			HAVING SUM(ISNULL(dbl60Days, 0)) = 0
		) ENTITY ON AGING.intEntityCustomerId = ENTITY.intEntityCustomerId
		WHERE AGING.intEntityUserId = @intEntityUserId AND AGING.strAgingType = 'Detail'
	END
ELSE IF @strAgedBalances = '61-90 Days'
	BEGIN 
		DELETE AGING 
		FROM tblARCustomerAgingStagingTable AGING
		INNER JOIN (
			SELECT intEntityCustomerId 
			FROM tblARCustomerAgingStagingTable 
			WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'
			GROUP BY intEntityCustomerId 
			HAVING SUM(ISNULL(dbl90Days, 0)) = 0
		) ENTITY ON AGING.intEntityCustomerId = ENTITY.intEntityCustomerId
		WHERE AGING.intEntityUserId = @intEntityUserId AND AGING.strAgingType = 'Detail'
	END
ELSE IF @strAgedBalances = 'Over 90 Days'
	BEGIN 
		DELETE AGING 
		FROM tblARCustomerAgingStagingTable AGING
		INNER JOIN (
			SELECT intEntityCustomerId 
			FROM tblARCustomerAgingStagingTable 
			WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'
			GROUP BY intEntityCustomerId 
			HAVING SUM(ISNULL(dbl120Days, 0)) = 0
		) ENTITY ON AGING.intEntityCustomerId = ENTITY.intEntityCustomerId
		WHERE AGING.intEntityUserId = @intEntityUserId AND AGING.strAgingType = 'Detail'
	END

IF ISNULL(@ysnPrintOnlyOverCreditLimit, 0) = 1
	BEGIN
		DELETE AGING
		FROM tblARCustomerAgingStagingTable AGING
		INNER JOIN (
			SELECT intEntityCustomerId 
			FROM tblARCustomerAgingStagingTable
			WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'
			GROUP BY intEntityCustomerId 
			HAVING AVG(ISNULL(dblCreditLimit, 0)) > SUM(ISNULL(dblTotalAR, 0))
				OR (AVG(ISNULL(dblCreditLimit, 0)) = 0 AND SUM(ISNULL(dblTotalAR, 0)) = 0)
				OR AVG(ISNULL(dblCreditLimit, 0)) = 0
		) ENTITY ON AGING.intEntityCustomerId = ENTITY.intEntityCustomerId
		WHERE AGING.intEntityUserId = @intEntityUserId
		  AND AGING.strAgingType = 'Detail'
	END

INSERT INTO @temp_open_invoices
SELECT DISTINCT intInvoiceId 
FROM tblARCustomerAgingStagingTable 
WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'
GROUP BY intInvoiceId HAVING SUM(ISNULL(dblTotalAR, 0)) <> 0

IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerAgingStagingTable AGING INNER JOIN @temp_open_invoices UNPAID ON AGING.intInvoiceId = UNPAID.intInvoiceId WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail')
	BEGIN
		INSERT INTO tblARCustomerAgingStagingTable (
			  strCompanyName
			, strCompanyAddress
			, dtmAsOfDate
			, intEntityUserId
			, strAgingType
		)
		SELECT strCompanyName		= COMPANY.strCompanyName
			 , strCompanyAddress	= COMPANY.strCompanyAddress
			 , dtmAsOfDate			= @dtmDateTo
			 , intEntityUserId		= @intEntityUserId
			 , strAgingType			= 'Detail'
		FROM (
			SELECT TOP 1 strCompanyName
					   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
			FROM dbo.tblSMCompanySetup WITH (NOLOCK)
		) COMPANY

		SELECT * FROM tblARCustomerAgingStagingTable AGING
		WHERE AGING.intEntityUserId = @intEntityUserId AND AGING.strAgingType = 'Detail'
	END
ELSE
	BEGIN
		SELECT AGING.* FROM tblARCustomerAgingStagingTable AGING
		INNER JOIN @temp_open_invoices UNPAID ON AGING.intInvoiceId = UNPAID.intInvoiceId
		WHERE AGING.intEntityUserId = @intEntityUserId AND AGING.strAgingType = 'Detail'
	END