CREATE PROCEDURE [dbo].[uspARCustomerAgingReport]
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
DECLARE @dtmDateTo						DATETIME
      , @dtmDateFrom					DATETIME
	  , @intEntityCustomerId			INT	= NULL
	  , @intEntityUserId				INT	= NULL
	  , @strSalesperson					NVARCHAR(100)
	  , @strCustomerName				NVARCHAR(MAX)
	  , @strAccountStatusCode			NVARCHAR(5)
	  , @strCompanyLocation				NVARCHAR(100)
	  , @xmlDocumentId					INT
	  , @filter							NVARCHAR(MAX) = ''
	  , @fieldname						NVARCHAR(50)
	  , @condition						NVARCHAR(20)
	  , @id								INT 
	  , @from							NVARCHAR(100)
	  , @to								NVARCHAR(100)
	  , @join							NVARCHAR(10)
	  , @begingroup						NVARCHAR(50)
	  , @endgroup						NVARCHAR(50)
	  , @datatype						NVARCHAR(50)
	  , @strSourceTransaction			NVARCHAR(100)
	  , @ysnPrintOnlyOverCreditLimit	BIT
	
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

SELECT	@ysnPrintOnlyOverCreditLimit = CASE WHEN ISNULL([from], 'False') = 'False' THEN 0 ELSE 1 END
FROM	@temp_xml_table
WHERE	[fieldname] = 'ysnPrintOnlyOverCreditLimit'

SELECT  @intEntityUserId = NULLIF(CAST(ISNULL([from], '') AS INT), 0)
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
	
EXEC dbo.uspARCustomerAgingAsOfDateReport @dtmDateFrom = @dtmDateFrom
										, @dtmDateTo = @dtmDateTo
										, @strSalesperson = @strSalesperson
										, @strSourceTransaction = @strSourceTransaction
										, @strCompanyLocation = @strCompanyLocation
										, @strCustomerName	= @strCustomerName
										, @strAccountStatusCode = @strAccountStatusCode
										, @intEntityUserId = @intEntityUserId
EXEC dbo.uspARGLAccountReport @dtmAsOfDate = @dtmDateTo
							, @intEntityUserId = @intEntityUserId

IF(OBJECT_ID('tempdb..#AGEDBALANCES') IS NOT NULL)
BEGIN
    DROP TABLE #AGEDBALANCES
END

SELECT strAgedBalances = ISNULL([from], 'All')
INTO #AGEDBALANCES
FROM	@temp_xml_table
WHERE	[fieldname] = 'strAgedBalances'

IF EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') <> 'All')
	BEGIN
		IF(OBJECT_ID('tempdb..#CUSTOMERWITHBALANCES') IS NOT NULL)
		BEGIN
			DROP TABLE #CUSTOMERWITHBALANCES
		END

		SELECT intEntityCustomerId 
		INTO #CUSTOMERWITHBALANCES
		FROM tblARCustomerAgingStagingTable
		WHERE intEntityUserId = @intEntityUserId
		AND strAgingType = 'Summary'
		AND (
			   ((ISNULL(dbl0Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = 'Current')))
			OR ((ISNULL(dbl10Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '1-10 Days')))
			OR ((ISNULL(dbl30Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '11-30 Days')))
			OR ((ISNULL(dbl60Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '31-60 Days')))
			OR ((ISNULL(dbl90Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '61-90 Days')))
			OR ((ISNULL(dbl91Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = 'Over 90 Days')))
		)

		DELETE FROM tblARCustomerAgingStagingTable
		WHERE intEntityUserId = @intEntityUserId 
		  AND strAgingType = 'Summary'
		  AND intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM #CUSTOMERWITHBALANCES)

		UPDATE GL
		SET GL.dblTotalAR 				= ISNULL(AGING.dblTotalAR, 0)
		  , GL.dblTotalReportBalance 	= ISNULL(AGING.dblTotalAR, 0) + ISNULL(AGING.dblTotalPrepayments, 0)
		FROM tblARGLSummaryStagingTable GL
		OUTER APPLY (
			SELECT dblTotalAR 			= SUM((ISNULL(dblFuture, 0) + ISNULL(dbl0Days, 0) + ISNULL(dbl10Days, 0) + ISNULL(dbl30Days, 0) + ISNULL(dbl60Days, 0) + ISNULL(dbl90Days, 0) + ISNULL(dbl91Days, 0)) + ISNULL(dblCredits, 0))
				 , dblTotalPrepayments 	= SUM(ISNULL(dblPrepayments, 0))
			FROM dbo.tblARCustomerAgingStagingTable
			WHERE intEntityUserId = @intEntityUserId 
		  	  AND strAgingType = 'Summary'
		) AGING
		WHERE intEntityUserId = @intEntityUserId 
	END

DELETE FROM tblARCustomerAgingStagingTable WHERE dbo.fnRoundBanker(dblTotalAR, 2) = 0.00 
											 AND dbo.fnRoundBanker(dblCredits, 2) = 0.00 
											 AND dbo.fnRoundBanker(dblPrepayments, 2) = 0.00
											 AND intEntityUserId = @intEntityUserId
											 AND strAgingType = 'Summary'

IF ISNULL(@ysnPrintOnlyOverCreditLimit, 0) = 1
	BEGIN
		DELETE FROM tblARCustomerAgingStagingTable WHERE (ISNULL(dblCreditLimit, 0) > ISNULL(dblTotalAR, 0)
									    OR (ISNULL(dblCreditLimit, 0) = 0 AND ISNULL(dblTotalAR, 0) = 0)
										OR ISNULL(dblCreditLimit, 0) = 0)
										AND intEntityUserId = @intEntityUserId
										AND strAgingType = 'Summary'
	END

IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerAgingStagingTable WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Summary')
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
			 , strAgingType			= 'Summary'
		FROM (
			SELECT TOP 1 strCompanyName
					   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
			FROM dbo.tblSMCompanySetup WITH (NOLOCK)
		) COMPANY
	END

SELECT * FROM tblARCustomerAgingStagingTable WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Summary'
