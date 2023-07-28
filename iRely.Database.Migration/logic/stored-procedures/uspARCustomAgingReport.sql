--liquibase formatted sql

-- changeset Von:uspAGCalculateWOTotal.1 runOnChange:true splitStatements:false
-- comment: AP-1234

CREATE OR ALTER PROCEDURE [dbo].[uspARCustomAgingReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = ''
	BEGIN 
		SET @xmlParam = NULL
		
		SELECT * FROM tblARCustomAgingStagingTable
	END

-- Declare the variables.
DECLARE @dtmDateTo						DATETIME
      , @dtmDateFrom					DATETIME	  
	  , @intEntityUserId				INT	= NULL
	  , @strCustomerIds					NVARCHAR(MAX)
	  , @strSalespersonIds				NVARCHAR(MAX)	  	  
	  , @strAccountStatusIds			NVARCHAR(MAX)
	  , @strCompanyLocationIds			NVARCHAR(MAX)
	  , @xmlDocumentId					INT	  
	  , @strSourceTransaction			NVARCHAR(100)
	  , @ysnPrintOnlyOverCreditLimit	BIT
	  , @ysnRollCredits					BIT
	  , @ysnOverrideCashFlow			BIT
	  , @ysnExcludeAccountStatus		BIT
	  , @strReportLogId					NVARCHAR(MAX)
	  , @intNewPerformanceLogId			INT 
	  , @strRequestId 					NVARCHAR(200)	= NEWID()
	  , @strCompanyName					NVARCHAR(500)	= NULL
	  , @strCompanyAddress				NVARCHAR(500)	= NULL
	  , @blbLogo						VARBINARY(MAX)	= NULL
	
-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	 [id]			INT IDENTITY(1,1)
	,[fieldname]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[condition]	NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
	,[from]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[to]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[join]			NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL
	,[begingroup]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[endgroup]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[datatype]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
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

--COMPANY DETAILS
SELECT @blbLogo = dbo.fnSMGetCompanyLogo('Header')

SELECT TOP 1 @strCompanyName = strCompanyName
		   , @strCompanyAddress = dbo.fnARFormatCustomerAddress(strPhone, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) 
FROM dbo.tblSMCompanySetup WITH (NOLOCK)

--DATE
SELECT TOP 1 @dtmDateFrom = CAST(CASE WHEN ISNULL(strFrom, '') <> '' THEN strFrom ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 		   , @dtmDateTo   = CAST(CASE WHEN ISNULL(strTo, '') <> '' THEN strTo ELSE GETDATE() END AS DATETIME)
FROM tblARCustomAgingSetupFilter 
WHERE strFilterField = 'Date'

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)
ELSE 			  
	SET @dtmDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST(-53690 AS DATETIME)

--CUSTOMER NAME
SELECT @strCustomerIds = LEFT(intEntityId, LEN(intEntityId) - 1)
FROM (
	SELECT DISTINCT CAST(E.intEntityId AS VARCHAR(200))  + ', '
	FROM tblARCustomAgingSetupFilter F
	INNER JOIN tblEMEntity E ON F.strFrom = E.strName
	INNER JOIN tblARCustomer C ON E.intEntityId = C.intEntityId
	WHERE F.strFrom <> ''
	  AND F.strFrom IS NOT NULL
	  AND F.strFilterField = 'Customer Name' 
	FOR XML PATH ('')
) C (intEntityId)

--SALESPERSON NAME
SELECT @strSalespersonIds = LEFT(intEntityId, LEN(intEntityId) - 1)
FROM (
	SELECT DISTINCT CAST(E.intEntityId AS VARCHAR(200))  + ', '
	FROM tblARCustomAgingSetupFilter F
	INNER JOIN tblEMEntity E ON F.strFrom = E.strName
	INNER JOIN tblARSalesperson SP ON E.intEntityId = SP.intEntityId
	WHERE F.strFrom <> ''
	  AND F.strFrom IS NOT NULL
	  AND F.strFilterField = 'Salesperson Name' 
	FOR XML PATH ('')
) C (intEntityId)

--SOURCE TRANSACTION
SELECT TOP 1 @strSourceTransaction = ISNULL(strFrom, '')
FROM tblARCustomAgingSetupFilter
WHERE strFilterField = 'Source Transaction'

--PRINT ONLY CUSTOMERS OVER CREDIT LIMIT
SELECT TOP 1 @ysnPrintOnlyOverCreditLimit = CASE WHEN ISNULL(strFrom, 'False') = 'False' THEN 0 ELSE 1 END
FROM tblARCustomAgingSetupFilter
WHERE strFilterField = 'Print only Customers over Credit Limit'

--ACCOUNT STATUS CODE
SELECT @strCompanyLocationIds = LEFT(intAccountStatusId, LEN(intAccountStatusId) - 1)
FROM (
	SELECT DISTINCT CAST(ACS.intAccountStatusId AS VARCHAR(200))  + ', '
	FROM tblARCustomAgingSetupFilter F
	INNER JOIN tblARAccountStatus ACS ON F.strFrom = ACS.strAccountStatusCode
	WHERE F.strFrom <> ''
	  AND F.strFrom IS NOT NULL
	  AND F.strFilterField = 'Account Status Code' 
	FOR XML PATH ('')
) C (intAccountStatusId)

--COMPANY LOCATION
SELECT @strCompanyLocationIds = LEFT(intCompanyLocationId, LEN(intCompanyLocationId) - 1)
FROM (
	SELECT DISTINCT CAST(CL.intCompanyLocationId AS VARCHAR(200))  + ', '
	FROM tblARCustomAgingSetupFilter F
	INNER JOIN tblSMCompanyLocation CL ON F.strFrom = CL.strLocationName
	WHERE F.strFrom <> ''
	  AND F.strFrom IS NOT NULL
	  AND F.strFilterField = 'Company Location' 
	FOR XML PATH ('')
) C (intCompanyLocationId)

--ROLL CREDITS
SELECT TOP 1 @ysnRollCredits = CASE WHEN ISNULL(strFrom, 'False') = 'False' THEN 0 ELSE 1 END
FROM tblARCustomAgingSetupFilter
WHERE strFilterField = 'Roll Credits'

--OVERRIDE CASH FLOW
SELECT TOP 1 @ysnOverrideCashFlow = CASE WHEN ISNULL(strFrom, 'False') = 'False' THEN 0 ELSE 1 END
FROM tblARCustomAgingSetupFilter
WHERE strFilterField = 'Override Cash Flow'

SELECT TOP 1 @intEntityUserId = NULLIF(CAST(ISNULL([from], '') AS INT), 0)
FROM @temp_xml_table
WHERE fieldname = 'intSrCurrentUserId'

SELECT TOP 1 @strReportLogId = [from]
FROM @temp_xml_table
WHERE fieldname = 'strReportLogId'

IF NOT EXISTS(SELECT * FROM tblSRReportLog WHERE strReportLogId = @strReportLogId)
BEGIN
	EXEC dbo.uspARLogPerformanceRuntime @strScreenName			= 'Custom Aging Report'
									  , @strProcedureName       = 'uspARCustomAgingReport'
									  , @strRequestId			= @strRequestId
									  , @ysnStart		        = 1
									  , @intUserId	            = 1
									  , @intPerformanceLogId    = NULL
									  , @intNewPerformanceLogId = @intNewPerformanceLogId OUT

	INSERT INTO tblSRReportLog (strReportLogId, dtmDate)
	VALUES (@strReportLogId, GETDATE())

	EXEC dbo.uspARCustomerAgingAsOfDateReport @dtmDateFrom				= @dtmDateFrom
										    , @dtmDateTo				= @dtmDateTo
										    , @strSourceTransaction		= @strSourceTransaction	
										    , @strCustomerIds			= @strCustomerIds
										    , @strSalespersonIds		= @strSalespersonIds
										    , @strCompanyLocationIds	= @strCompanyLocationIds
										    , @strAccountStatusIds		= @strAccountStatusIds	
										    , @intEntityUserId			= @intEntityUserId
										    , @ysnExcludeAccountStatus	= 0
										    , @ysnOverrideCashFlow  	= @ysnOverrideCashFlow
										    , @strReportLogId			= @strReportLogId
											, @strAgingType				= 'Custom'

	EXEC dbo.uspARGLAccountReport @dtmAsOfDate = @dtmDateTo
								, @intEntityUserId = @intEntityUserId
								, @strAgingType	= 'Custom'
															
	--ROLL CREDITS
	IF(OBJECT_ID('tempdb..#CUSTOMERSWITHCREDITS') IS NOT NULL) DROP TABLE #CUSTOMERSWITHCREDITS
	IF ISNULL(@ysnRollCredits, 0) = 1
		BEGIN
			--GET CUSTOMERS WITH OPEN CREDITS AND INVOICES
			SELECT DISTINCT intEntityCustomerId
			INTO #CUSTOMERSWITHCREDITS
			FROM tblARCustomerAgingStagingTable
			WHERE intEntityUserId = @intEntityUserId 
			  AND strAgingType = 'Custom'
			  AND strReportLogId = @strReportLogId
			GROUP BY intEntityCustomerId 
			HAVING SUM(ABS(ISNULL(dblCredits, 0)) + ABS(ISNULL(dblPrepayments, 0))) <> 0
			   AND SUM(ISNULL(dbl0Days, 0) + ISNULL(dbl10Days, 0) + ISNULL(dbl30Days, 0) + ISNULL(dbl60Days, 0) + ISNULL(dbl90Days, 0) + ISNULL(dbl91Days, 0) + ISNULL(dbl120Days, 0)) <> 0

			WHILE EXISTS (SELECT TOP 1 NULL FROM #CUSTOMERSWITHCREDITS)
				BEGIN
					DECLARE @intEntityCustomerId INT = NULL
					SELECT TOP 1 @intEntityCustomerId = intEntityCustomerId FROM #CUSTOMERSWITHCREDITS

					IF(OBJECT_ID('tempdb..#OPENINVOICES') IS NOT NULL) DROP TABLE #OPENINVOICES
					IF(OBJECT_ID('tempdb..#OPENCREDITS') IS NOT NULL) DROP TABLE #OPENCREDITS

					--GET OPEN CREDITS
					SELECT intInvoiceId
						 , dtmDate
						 , dblTotalAR	= ABS(dblTotalAR)
					INTO #OPENCREDITS
					FROM tblARCustomerAgingStagingTable
					WHERE intEntityUserId = @intEntityUserId 
					  AND strAgingType = 'Custom'
					  AND strReportLogId = @strReportLogId
					  AND intEntityCustomerId = @intEntityCustomerId
					  AND strTransactionType IN ('Overpayment', 'Customer Prepayment', 'Credit Memo')

					--GET OPEN INVOICES
					SELECT intInvoiceId
						 , dtmDate		= MIN(dtmDate)
						 , dblTotalAR	= SUM(dblTotalAR)
					INTO #OPENINVOICES
					FROM tblARCustomerAgingStagingTable
					WHERE intEntityUserId = @intEntityUserId 
					  AND strAgingType = 'Custom'
					  AND strReportLogId = @strReportLogId
					  AND intEntityCustomerId = @intEntityCustomerId
					  AND strTransactionType NOT IN ('Overpayment', 'Customer Prepayment', 'Credit Memo')
					GROUP BY intInvoiceId

					--APPLY CREDITS TO OLDEST INVOICE
					WHILE EXISTS (SELECT TOP 1 NULL FROM #OPENCREDITS)
						BEGIN
							DECLARE @intPrepaidId		INT = NULL
								  , @dblCreditToApply	NUMERIC(18, 6) = 0

							SELECT TOP 1 @intPrepaidId		= intInvoiceId
									   , @dblCreditToApply	= dblTotalAR
							FROM #OPENCREDITS ORDER BY dtmDate ASC

							WHILE EXISTS (SELECT TOP 1 NULL FROM #OPENINVOICES) AND @dblCreditToApply > 0
								BEGIN
									DECLARE @intInvoiceId	INT = NULL
										  , @dblInvoiceDue	NUMERIC(18, 6) = 0
								
									SELECT TOP 1 @intInvoiceId	= intInvoiceId
											   , @dblInvoiceDue	= dblTotalAR
									FROM #OPENINVOICES ORDER BY dtmDate ASC

									--APPLY FULL CREDIT AMOUNT IF INVOICE IS LARGER THAN CREDIT
									--UPDATE INVOICE BALANCE AND DELETE CREDIT 
									IF @dblInvoiceDue > @dblCreditToApply
										BEGIN
											UPDATE #OPENINVOICES
											SET dblTotalAR = dblTotalAR - @dblCreditToApply
											WHERE intInvoiceId = @intInvoiceId

											UPDATE tblARCustomerAgingStagingTable 
											SET dblTotalAR	= dblTotalAR - @dblCreditToApply
											  , dbl0Days	= CASE WHEN ISNULL(dbl0Days, 0) <> 0 THEN dbl0Days - @dblCreditToApply END
											  , dbl10Days	= CASE WHEN ISNULL(dbl10Days, 0) <> 0 THEN dbl10Days - @dblCreditToApply END
											  , dbl30Days	= CASE WHEN ISNULL(dbl30Days, 0) <> 0 THEN dbl30Days - @dblCreditToApply END
											  , dbl60Days	= CASE WHEN ISNULL(dbl60Days, 0) <> 0 THEN dbl60Days - @dblCreditToApply END
											  , dbl90Days	= CASE WHEN ISNULL(dbl90Days, 0) <> 0 THEN dbl90Days - @dblCreditToApply END
											  , dbl120Days	= CASE WHEN ISNULL(dbl120Days, 0) <> 0 THEN dbl120Days - @dblCreditToApply END
											  , dbl121Days	= CASE WHEN ISNULL(dbl121Days, 0) <> 0 THEN dbl121Days - @dblCreditToApply END
											  , dblTotalDue = dblTotalDue - @dblCreditToApply
											WHERE intEntityUserId = @intEntityUserId
											  AND strAgingType = 'Custom' 
											  AND strReportLogId = @strReportLogId
											  AND intInvoiceId = @intInvoiceId
											  AND strRecordNumber IS NULL

											DELETE FROM tblARCustomerAgingStagingTable 
											WHERE intEntityUserId = @intEntityUserId 
											  AND strAgingType = 'Custom' 
											  AND strReportLogId = @strReportLogId
											  AND intInvoiceId = @intPrepaidId

											SET @dblCreditToApply = 0
										END
									--IF CREDIT IS LARGER THAN THE OPEN INVOICE
									--DELETE OPEN INVOICE AND UPDATE CREDIT
									ELSE 
										BEGIN
											UPDATE #OPENINVOICES
											SET dblTotalAR = 0
											WHERE intInvoiceId = @intInvoiceId
										
											UPDATE tblARCustomerAgingStagingTable 
											SET dblTotalAR	= dblTotalAR + @dblInvoiceDue										
											  , dblTotalDue = dblTotalDue + @dblInvoiceDue
											  , dblPrepayments = dblPrepayments + @dblInvoiceDue
											  , dblPrepaids = dblPrepaids + @dblInvoiceDue
											WHERE intEntityUserId = @intEntityUserId
											  AND strAgingType = 'Custom' 
											  AND strReportLogId = @strReportLogId
											  AND intInvoiceId = @intPrepaidId										  

											DELETE FROM tblARCustomerAgingStagingTable 
											WHERE intEntityUserId = @intEntityUserId
											  AND strAgingType = 'Custom'
											  AND strReportLogId = @strReportLogId
											  AND intInvoiceId = @intInvoiceId

											SET @dblCreditToApply = @dblCreditToApply - @dblInvoiceDue
										END

									DELETE FROM #OPENINVOICES WHERE intInvoiceId = @intInvoiceId AND dblTotalAR = 0
								END
							--SELECT * FROM #OPENCREDITS
							DELETE FROM #OPENCREDITS WHERE intInvoiceId = @intPrepaidId
						END

					DELETE FROM #CUSTOMERSWITHCREDITS WHERE intEntityCustomerId = @intEntityCustomerId
					DELETE FROM #OPENCREDITS
					DELETE FROM #OPENINVOICES
				END
		END

	--PRINT CUSTOMERS WITH BALANCES
	IF(OBJECT_ID('tempdb..#AGEDBALANCES') IS NOT NULL) DROP TABLE #AGEDBALANCES
	SELECT strAgedBalances = ISNULL(strFrom, 'All')
	INTO #AGEDBALANCES
	FROM tblARCustomAgingSetupFilter
	WHERE strFilterField = 'Print Customers with Balances'

	IF EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') <> 'All')
		BEGIN
			IF(OBJECT_ID('tempdb..#CUSTOMERWITHBALANCES') IS NOT NULL) DROP TABLE #CUSTOMERWITHBALANCES

			SELECT DISTINCT intEntityCustomerId 
			INTO #CUSTOMERWITHBALANCES
			FROM tblARCustomerAgingStagingTable
			WHERE intEntityUserId = @intEntityUserId
			AND strAgingType = 'Custom'
			AND strReportLogId = @strReportLogId
			AND (
				   ((ISNULL(dbl0Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = 'Current')))
				OR ((ISNULL(dbl10Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '1-10 Days')))
				OR ((ISNULL(dbl30Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '11-30 Days')))
				OR ((ISNULL(dbl60Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '31-60 Days')))
				OR ((ISNULL(dbl90Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '61-90 Days')))
				OR ((ISNULL(dbl120Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = 'Over 90 Days')))
				OR ((ISNULL(dbl121Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = 'Over 90 Days')))
			)

			DELETE FROM tblARCustomerAgingStagingTable
			WHERE intEntityUserId = @intEntityUserId 
			  AND strAgingType = 'Custom'
			  AND strReportLogId = @strReportLogId
			  AND intEntityCustomerId  IN (SELECT intEntityCustomerId FROM #CUSTOMERWITHBALANCES)
			  AND  (
					((ISNULL(dbl0Days,  0) <> 0  AND  NOT EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = 'Current')))
				OR  ((ISNULL(dbl10Days, 0) <> 0  AND  NOT EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '1-10 Days')))
				OR  ((ISNULL(dbl30Days, 0) <> 0  AND  NOT EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '11-30 Days')))
				OR  ((ISNULL(dbl60Days, 0) <> 0  AND  NOT EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '31-60 Days')))
				OR  ((ISNULL(dbl90Days, 0) <> 0  AND  NOT EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '61-90 Days')))
				OR  ((ISNULL(dbl120Days,0) <> 0  AND  NOT EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = 'Over 90 Days')))
				OR  ((ISNULL(dbl121Days,0) <> 0  AND  NOT EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = 'Over 90 Days')))
			)

			DELETE AGING 
			FROM tblARCustomerAgingStagingTable AGING
			LEFT JOIN #CUSTOMERWITHBALANCES BAL ON AGING.intEntityCustomerId = BAL.intEntityCustomerId
			WHERE intEntityUserId = @intEntityUserId 
			  AND strAgingType = 'Custom'
			  AND strReportLogId = @strReportLogId
			  AND ISNULL(BAL.intEntityCustomerId, 0) = 0
			  AND strTransactionType NOT IN  ('Credit Memo','Customer Prepayment')  
		END

	--REMOVE CUSTOMERS WITHOUT ANY OPEN TRANSACTIONS
	DELETE AGING
	FROM tblARCustomerAgingStagingTable AGING
	INNER JOIN (
		SELECT intEntityCustomerId 
		FROM tblARCustomerAgingStagingTable 
		WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Custom'
		GROUP BY intEntityCustomerId 
		HAVING SUM(ISNULL(dblTotalAR, 0)) = 0
			AND SUM(ISNULL(dblCredits, 0)) = 0
			AND SUM(ISNULL(dblPrepayments, 0)) = 0
	) ENTITY ON AGING.intEntityCustomerId = ENTITY.intEntityCustomerId
	WHERE AGING.intEntityUserId = @intEntityUserId
	  AND AGING.strAgingType = 'Custom'
	  AND strReportLogId = @strReportLogId

	--PRINT ONLY CUSTOMERS OVER CREDIT LIMIT
	IF ISNULL(@ysnPrintOnlyOverCreditLimit, 0) = 1
		BEGIN
			DELETE AGING
			FROM tblARCustomerAgingStagingTable AGING
			INNER JOIN (
				SELECT intEntityCustomerId 
				FROM tblARCustomerAgingStagingTable
				WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Custom'
				GROUP BY intEntityCustomerId 
				HAVING AVG(ISNULL(dblCreditLimit, 0)) > SUM(ISNULL(dblTotalAR, 0))
					OR (AVG(ISNULL(dblCreditLimit, 0)) = 0 AND SUM(ISNULL(dblTotalAR, 0)) = 0)
					OR AVG(ISNULL(dblCreditLimit, 0)) = 0
			) ENTITY ON AGING.intEntityCustomerId = ENTITY.intEntityCustomerId
			WHERE AGING.intEntityUserId = @intEntityUserId
			AND AGING.strAgingType = 'Custom'
			AND strReportLogId = @strReportLogId
		END

	IF EXISTS (SELECT TOP 1 NULL FROM tblARCustomerAgingStagingTable WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Custom' AND strReportLogId = @strReportLogId)
		BEGIN
			UPDATE AGING
			SET  dblTotalCustomerAR = ISNULL(dbl0Days, 0) + ISNULL(dbl10Days, 0) + ISNULL(dbl30Days, 0) + ISNULL(dbl60Days, 0) + ISNULL(dbl90Days, 0) + ISNULL(dbl91Days, 0) + ISNULL(dbl120Days, 0) + ISNULL(dbl121Days, 0) + ISNULL(dblCredits, 0) + ISNULL(dblPrepayments, 0)
				,strReportLogId = @strReportLogId
			FROM tblARCustomerAgingStagingTable AGING
			WHERE intEntityUserId = @intEntityUserId 
			  AND strAgingType = 'Custom'
			  AND strReportLogId = @strReportLogId
		END
	
	IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerAgingStagingTable AGING WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Custom' AND strReportLogId = @strReportLogId)
		BEGIN
			INSERT INTO tblARCustomerAgingStagingTable (
				  strCompanyName
				, strCompanyAddress
				, dtmAsOfDate
				, intEntityUserId
				, strAgingType
			)
			SELECT strCompanyName		= @strCompanyName
				 , strCompanyAddress	= @strCompanyAddress
				 , dtmAsOfDate			= @dtmDateTo
				 , intEntityUserId		= @intEntityUserId
				 , strAgingType			= 'Custom'			
		END

	--AGING BUCKET
	DECLARE @strBucket1	NVARCHAR(100), @ysnShowBucket1	BIT = 0
		  , @strBucket2	NVARCHAR(100), @ysnShowBucket2	BIT = 0
		  , @strBucket3	NVARCHAR(100), @ysnShowBucket3	BIT = 0
		  , @strBucket4	NVARCHAR(100), @ysnShowBucket4	BIT = 0
		  , @strBucket5	NVARCHAR(100), @ysnShowBucket5	BIT = 0
		  , @strBucket6	NVARCHAR(100), @ysnShowBucket6	BIT = 0

	SELECT TOP 1 @strBucket1		= ISNULL(NULLIF(strCustomTitle, ''), strOriginalBucket)
			   , @ysnShowBucket1	= ISNULL(ysnShow, 1)
	FROM tblARCustomAgingSetupBucket
	WHERE strOriginalBucket = 'Current'

	SELECT TOP 1 @strBucket2		= ISNULL(NULLIF(strCustomTitle, ''), strOriginalBucket)
			   , @ysnShowBucket2	= ISNULL(ysnShow, 1)
	FROM tblARCustomAgingSetupBucket
	WHERE strOriginalBucket = '1-10 Days'

	SELECT TOP 1 @strBucket3		= ISNULL(NULLIF(strCustomTitle, ''), strOriginalBucket)
			   , @ysnShowBucket3	= ISNULL(ysnShow, 1)
	FROM tblARCustomAgingSetupBucket
	WHERE strOriginalBucket = '11-30 Days'

	SELECT TOP 1 @strBucket4		= ISNULL(NULLIF(strCustomTitle, ''), strOriginalBucket)
			   , @ysnShowBucket4	= ISNULL(ysnShow, 1)
	FROM tblARCustomAgingSetupBucket
	WHERE strOriginalBucket = '31-60 Days'

	SELECT TOP 1 @strBucket5		= ISNULL(NULLIF(strCustomTitle, ''), strOriginalBucket)
			   , @ysnShowBucket5	= ISNULL(ysnShow, 1)
	FROM tblARCustomAgingSetupBucket
	WHERE strOriginalBucket = '61-90 Days'

	SELECT TOP 1 @strBucket6		= ISNULL(NULLIF(strCustomTitle, ''), strOriginalBucket)
			   , @ysnShowBucket6	= ISNULL(ysnShow, 1)
	FROM tblARCustomAgingSetupBucket
	WHERE strOriginalBucket = 'Over 90 Days'

	DELETE FROM tblARCustomAgingStagingTable WHERE intEntityUserId = @intEntityUserId AND strReportLogId = @strReportLogId
	INSERT INTO tblARCustomAgingStagingTable WITH (TABLOCK) (
		  intEntityCustomerId
		, intEntityUserId
		, dtmAsOfDate
		, strCustomerName
		, strCustomerNumber
		, strCustomerInfo
		, strCompanyName
		, strCompanyAddress
		, dblCreditLimit
		, dblTotalAR
		, dblTotalCustomerAR
		, dblFuture
		, dblBucket1
		, dblBucket2
		, dblBucket3
		, dblBucket4
		, dblBucket5
		, dblBucket6
		, strBucket1
		, strBucket2
		, strBucket3
		, strBucket4
		, strBucket5
		, strBucket6
		, ysnShowBucket1
		, ysnShowBucket2
		, ysnShowBucket3
		, ysnShowBucket4
		, ysnShowBucket5
		, ysnShowBucket6
		, dblCredits
		, dblPrepayments
		, strReportLogId
	)
	SELECT intEntityCustomerId		= CA.intEntityCustomerId
		, intEntityUserId			= @intEntityUserId
		, dtmAsOfDate				= @dtmDateTo
		, strCustomerName			= CA.strCustomerName
		, strCustomerNumber			= CA.strCustomerNumber
		, strCustomerInfo			= CA.strCustomerInfo
		, strCompanyName			= @strCompanyName
		, strCompanyAddress			= @strCompanyAddress
		, dblCreditLimit			= CA.dblCreditLimit
		, dblTotalAR				= CA.dblTotalAR
		, dblTotalCustomerAR		= CA.dblTotalCustomerAR
		, dblFuture					= CA.dblFuture
		, dblBucket1				= CA.dbl0Days
		, dblBucket2				= CA.dbl10Days
		, dblBucket3				= CA.dbl30Days
		, dblBucket4				= CA.dbl60Days
		, dblBucket5				= CA.dbl90Days
		, dblBucket6				= CA.dbl91Days
		, strBucket1				= @strBucket1
		, strBucket2				= @strBucket2
		, strBucket3				= @strBucket3
		, strBucket4				= @strBucket4
		, strBucket5				= @strBucket5
		, strBucket6				= @strBucket6
		, ysnShowBucket1			= ISNULL(@ysnShowBucket1, 1)
		, ysnShowBucket2			= ISNULL(@ysnShowBucket2, 1)
		, ysnShowBucket3			= ISNULL(@ysnShowBucket3, 1)
		, ysnShowBucket4			= ISNULL(@ysnShowBucket4, 1)
		, ysnShowBucket5			= ISNULL(@ysnShowBucket5, 1)
		, ysnShowBucket6			= ISNULL(@ysnShowBucket6, 1)
		, dblCredits				= CA.dblCredits
		, dblPrepayments			= CA.dblPrepayments
		, strReportLogId			= @strReportLogId
	FROM tblARCustomerAgingStagingTable CA 
	WHERE CA.intEntityUserId = @intEntityUserId 
	  AND CA.strAgingType = 'Custom' 
	  AND CA.strReportLogId = @strReportLogId 
	
	IF ISNULL(@intNewPerformanceLogId, 0) <> 0
	BEGIN
		EXEC dbo.uspARLogPerformanceRuntime @strScreenName			= 'Custom Aging Report'
										  , @strProcedureName       = 'uspARCustomAgingReport'
										  , @strRequestId			= @strRequestId
										  , @ysnStart		        = 0
										  , @intUserId	            = 1
										  , @intPerformanceLogId    = @intNewPerformanceLogId
	END
END

SELECT * 
FROM tblARCustomAgingStagingTable 
WHERE intEntityUserId = @intEntityUserId 
  AND strReportLogId = @strReportLogId




END