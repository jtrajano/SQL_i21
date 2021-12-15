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
DECLARE @dtmDateTo						DATETIME
      , @dtmDateFrom					DATETIME
	  , @strSalespersonIds				NVARCHAR(MAX)
	  , @strCustomerIds					NVARCHAR(MAX)	  
	  , @strAccountStatusIds			NVARCHAR(MAX)
	  , @strCompanyLocationIds			NVARCHAR(MAX)
	  , @xmlDocumentId					INT
	  , @fieldname						NVARCHAR(50)
	  , @condition						NVARCHAR(20)
	  , @id								INT 
	  , @from							NVARCHAR(100)
	  , @to								NVARCHAR(100)
	  , @strSourceTransaction			NVARCHAR(50)
	  , @ysnPrintOnlyOverCreditLimit	BIT
	  , @ysnRollCredits					BIT
	  , @ysnExcludeAccountStatus		BIT
	  , @ysnOverrideCashFlow			BIT = 0
	  , @intEntityUserId				INT
	  , @strReportLogId					NVARCHAR(MAX)
		
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

WHILE EXISTS (SELECT TOP 1 NULL FROM @temp_xml_table WHERE [fieldname] IN ('strCustomerName', 'strSalespersonName', 'strAccountStatusCode', 'strCompanyLocation'))
	BEGIN
		SELECT TOP 1 @condition = [condition]
				   , @from		= REPLACE(ISNULL([from], ''), '''''', '''')
				   , @to		= REPLACE(ISNULL([to], ''), '''''', '''')
				   , @fieldname = [fieldname]
				   , @id		= [id]
		FROM @temp_xml_table 
		WHERE [fieldname] IN ('strCustomerName', 'strSalespersonName', 'strAccountStatusCode', 'strCompanyLocation')

		IF UPPER(@condition) = UPPER('Equal To')
			BEGIN				
				IF @fieldname = 'strCustomerName'
					BEGIN
						SELECT @strCustomerIds = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
						FROM (
							SELECT DISTINCT CAST(C.intEntityCustomerId AS VARCHAR(200))  + ', '
							FROM vyuARCustomerSearch C
							INNER JOIN @temp_xml_table TT ON C.strName = REPLACE(ISNULL(TT.[from], ''), '''''', '''')
							WHERE TT.fieldname = 'strCustomerName'
							  AND TT.condition = 'Equal To'
							FOR XML PATH ('')
						) C (intEntityCustomerId)
					END
				ELSE IF @fieldname = 'strSalespersonName'
					BEGIN
						SELECT @strSalespersonIds = ISNULL(@strSalespersonIds, '') + LEFT(intEntityId, LEN(intEntityId) - 1)
						FROM (
							SELECT DISTINCT CAST(S.intEntityId AS VARCHAR(200))  + ', '
							FROM vyuEMSalesperson S
							INNER JOIN @temp_xml_table TT ON S.strSalespersonName = REPLACE(ISNULL(TT.[from], ''), '''''', '''')
							WHERE TT.fieldname = 'strSalespersonName'
							  AND TT.condition = 'Equal To'
							FOR XML PATH ('')
						) C (intEntityId)
					END
				ELSE IF @fieldname = 'strAccountStatusCode'
					BEGIN
						SELECT @strAccountStatusIds = ISNULL(@strAccountStatusIds, '') + LEFT(intAccountStatusId, LEN(intAccountStatusId) - 1)
						FROM (
							SELECT DISTINCT CAST(S.intAccountStatusId AS VARCHAR(200))  + ', '
							FROM tblARAccountStatus S
							INNER JOIN @temp_xml_table TT ON S.strAccountStatusCode = REPLACE(ISNULL(TT.[from], ''), '''''', '''')
							WHERE TT.fieldname = 'strAccountStatusCode'
							  AND TT.condition = 'Equal To'
							FOR XML PATH ('')
						) C (intAccountStatusId)
					END
				ELSE IF @fieldname = 'strCompanyLocation'
					BEGIN
						SELECT @strCompanyLocationIds = ISNULL(@strCompanyLocationIds, '') + LEFT(intCompanyLocationId, LEN(intCompanyLocationId) - 1)
						FROM (
							SELECT DISTINCT CAST(intCompanyLocationId AS VARCHAR(200))  + ', '
							FROM tblSMCompanyLocation CL
							INNER JOIN @temp_xml_table TT ON CL.strLocationName = REPLACE(ISNULL(TT.[from], ''), '''''', '''')
							WHERE TT.fieldname = 'strCompanyLocation'
							  AND TT.condition = 'Equal To'
							FOR XML PATH ('')
						) C (intCompanyLocationId)
					END
			END
		ELSE IF UPPER(@condition) = UPPER('Not Equal To')
			BEGIN
				IF @fieldname = 'strCustomerName'
					BEGIN
						SELECT @strCustomerIds = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
						FROM (
							SELECT DISTINCT CAST(intEntityCustomerId AS VARCHAR(200))  + ', '
							FROM vyuARCustomerSearch 
							WHERE strName <> @from
							FOR XML PATH ('')
						) C (intEntityCustomerId)
					END
				ELSE IF @fieldname = 'strSalespersonName'
					BEGIN
						SELECT @strSalespersonIds = LEFT(intEntityId, LEN(intEntityId) - 1)
						FROM (
							SELECT DISTINCT CAST(intEntityId AS VARCHAR(200))  + ', '
							FROM vyuEMSalesperson 
							WHERE strSalespersonName <> @from
							FOR XML PATH ('')
						) C (intEntityId)
					END
				ELSE IF @fieldname = 'strAccountStatusCode'
					BEGIN
						SELECT @strAccountStatusIds = LEFT(intAccountStatusId, LEN(intAccountStatusId) - 1)
						FROM (
							SELECT DISTINCT CAST(intAccountStatusId AS VARCHAR(200))  + ', '
							FROM tblARAccountStatus 
							WHERE strAccountStatusCode = @from
							FOR XML PATH ('')
						) C (intAccountStatusId)

						SET @ysnExcludeAccountStatus = CAST(1 AS BIT)
					END
				ELSE IF @fieldname = 'strCompanyLocation'
					BEGIN
						SELECT @strCompanyLocationIds = LEFT(intCompanyLocationId, LEN(intCompanyLocationId) - 1)
						FROM (
							SELECT DISTINCT CAST(intCompanyLocationId AS VARCHAR(200))  + ', '
							FROM tblSMCompanyLocation 
							WHERE strLocationName <> @from
							FOR XML PATH ('')
						) C (intCompanyLocationId)
					END
			END
		ELSE IF UPPER(@condition) = UPPER('Between')
			BEGIN
				IF @fieldname = 'strCustomerName'
					BEGIN
						SELECT @strCustomerIds = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
						FROM (
							SELECT DISTINCT CAST(intEntityCustomerId AS VARCHAR(200))  + ', '
							FROM vyuARCustomerSearch 
							WHERE strName BETWEEN @from AND @to
							FOR XML PATH ('')
						) C (intEntityCustomerId)
					END
				ELSE IF @fieldname = 'strSalespersonName'
					BEGIN
						SELECT @strSalespersonIds = LEFT(intEntityId, LEN(intEntityId) - 1)
						FROM (
							SELECT DISTINCT CAST(intEntityId AS VARCHAR(200))  + ', '
							FROM vyuEMSalesperson 
							WHERE strSalespersonName BETWEEN @from AND @to
							FOR XML PATH ('')
						) C (intEntityId)
					END
				ELSE IF @fieldname = 'strAccountStatusCode'
					BEGIN
						SELECT @strAccountStatusIds = LEFT(intAccountStatusId, LEN(intAccountStatusId) - 1)
						FROM (
							SELECT DISTINCT CAST(intAccountStatusId AS VARCHAR(200))  + ', '
							FROM tblARAccountStatus 
							WHERE strAccountStatusCode BETWEEN @from AND @to
							FOR XML PATH ('')
						) C (intAccountStatusId)
					END
				ELSE IF @fieldname = 'strCompanyLocation'
					BEGIN
						SELECT @strCompanyLocationIds = LEFT(intCompanyLocationId, LEN(intCompanyLocationId) - 1)
						FROM (
							SELECT DISTINCT CAST(intCompanyLocationId AS VARCHAR(200))  + ', '
							FROM tblSMCompanyLocation 
							WHERE strLocationName BETWEEN @from AND @to
							FOR XML PATH ('')
						) C (intCompanyLocationId)
					END
			END

		DELETE FROM @temp_xml_table WHERE [fieldname] = @fieldname
		SET @condition = NULL
		SET @from = NULL
		SET @to = NULL
		SET @fieldname = NULL
		SET @id =  NULL
	END
	
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

SELECT	@ysnRollCredits = CASE WHEN ISNULL([from], 'False') = 'False' THEN 0 ELSE 1 END
FROM	@temp_xml_table
WHERE	[fieldname] = 'ysnRollCredits'

SELECT	@ysnOverrideCashFlow = CASE WHEN ISNULL([from], 'False') = 'False' THEN 0 ELSE 1 END
FROM	@temp_xml_table
WHERE	[fieldname] = 'ysnOverrideCashFlow'

SELECT	@intEntityUserId = [from]
FROM	@temp_xml_table 
WHERE	[fieldname] = 'intSrCurrentUserId'

SELECT @strReportLogId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strReportLogId'

IF NOT EXISTS(SELECT * FROM tblSRReportLog WHERE strReportLogId = @strReportLogId)
BEGIN
	INSERT INTO tblSRReportLog (strReportLogId, dtmDate)
	VALUES (@strReportLogId, GETDATE())

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

	EXEC dbo.uspARCustomerAgingDetailAsOfDateReport @dtmDateFrom				= @dtmDateFrom
												  , @dtmDateTo					= @dtmDateTo											  
												  , @strSourceTransaction		= @strSourceTransaction
												  , @strCustomerIds				= @strCustomerIds
												  , @strSalespersonIds			= @strSalespersonIds
												  , @strCompanyLocationIds		= @strCompanyLocationIds
												  , @strAccountStatusIds		= @strAccountStatusIds
												  , @ysnInclude120Days			= 0
												  , @ysnExcludeAccountStatus	= @ysnExcludeAccountStatus
												  , @intEntityUserId			= @intEntityUserId
												  , @ysnOverrideCashFlow		= @ysnOverrideCashFlow
												  , @strReportLogId				= @strReportLogId

	IF(OBJECT_ID('tempdb..#AGEDBALANCES') IS NOT NULL)
	BEGIN
		DROP TABLE #AGEDBALANCES
	END

	IF(OBJECT_ID('tempdb..#CUSTOMERSWITHCREDITS') IS NOT NULL)
	BEGIN
		DROP TABLE #CUSTOMERSWITHCREDITS
	END

	IF ISNULL(@ysnRollCredits, 0) = 1
		BEGIN
			--GET CUSTOMERS WITH OPEN CREDITS AND INVOICES
			SELECT DISTINCT intEntityCustomerId
			INTO #CUSTOMERSWITHCREDITS
			FROM tblARCustomerAgingStagingTable
			WHERE intEntityUserId = @intEntityUserId 
			  AND strAgingType = 'Detail'
			  AND strReportLogId = @strReportLogId
			GROUP BY intEntityCustomerId 
			HAVING SUM(ABS(ISNULL(dblCredits, 0)) + ABS(ISNULL(dblPrepayments, 0))) <> 0
			   AND SUM(ISNULL(dbl0Days, 0) + ISNULL(dbl10Days, 0) + ISNULL(dbl30Days, 0) + ISNULL(dbl60Days, 0) + ISNULL(dbl90Days, 0) + ISNULL(dbl91Days, 0) + ISNULL(dbl120Days, 0)) <> 0

			WHILE EXISTS (SELECT TOP 1 NULL FROM #CUSTOMERSWITHCREDITS)
				BEGIN
					DECLARE @intEntityCustomerId INT = NULL
					SELECT TOP 1 @intEntityCustomerId = intEntityCustomerId FROM #CUSTOMERSWITHCREDITS

					IF(OBJECT_ID('tempdb..#OPENINVOICES') IS NOT NULL)
					BEGIN
							DROP TABLE #OPENINVOICES
					END

					IF(OBJECT_ID('tempdb..#OPENCREDITS') IS NOT NULL)
					BEGIN
							DROP TABLE #OPENCREDITS
					END

					--GET OPEN CREDITS
					SELECT intInvoiceId
						 , dtmDate
						 , dblTotalAR	= ABS(dblTotalAR)
					INTO #OPENCREDITS
					FROM tblARCustomerAgingStagingTable
					WHERE intEntityUserId = @intEntityUserId 
					  AND strAgingType = 'Detail'
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
					  AND strAgingType = 'Detail'
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
											  AND strAgingType = 'Detail' 
											  AND strReportLogId = @strReportLogId
											  AND intInvoiceId = @intInvoiceId
											  AND strRecordNumber IS NULL

											DELETE FROM tblARCustomerAgingStagingTable 
											WHERE intEntityUserId = @intEntityUserId 
											  AND strAgingType = 'Detail' 
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
											  AND strAgingType = 'Detail' 
											  AND strReportLogId = @strReportLogId
											  AND intInvoiceId = @intPrepaidId										  

											DELETE FROM tblARCustomerAgingStagingTable 
											WHERE intEntityUserId = @intEntityUserId
											  AND strAgingType = 'Detail'
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

			SELECT DISTINCT intEntityCustomerId 
			INTO #CUSTOMERWITHBALANCES
			FROM tblARCustomerAgingStagingTable
			WHERE intEntityUserId = @intEntityUserId
			AND strAgingType = 'Detail'
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
			  AND strAgingType = 'Detail'
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
			  AND strAgingType = 'Detail'
			  AND strReportLogId = @strReportLogId
			  AND ISNULL(BAL.intEntityCustomerId, 0) = 0
			  AND strTransactionType NOT IN  ('Credit Memo','Customer Prepayment')  
		END

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
	  AND strReportLogId = @strReportLogId

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
			AND strReportLogId = @strReportLogId
		END

	IF EXISTS (SELECT TOP 1 NULL FROM tblARCustomerAgingStagingTable WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail' AND strReportLogId = @strReportLogId)
		BEGIN
			UPDATE AGING
			SET  dblTotalCustomerAR = ISNULL(dbl0Days, 0) + ISNULL(dbl10Days, 0) + ISNULL(dbl30Days, 0) + ISNULL(dbl60Days, 0) + ISNULL(dbl90Days, 0) + ISNULL(dbl91Days, 0) + ISNULL(dbl120Days, 0) + ISNULL(dbl121Days, 0) + ISNULL(dblCredits, 0) + ISNULL(dblPrepayments, 0)
				,strReportLogId = @strReportLogId
			FROM tblARCustomerAgingStagingTable AGING
			WHERE intEntityUserId = @intEntityUserId 
			  AND strAgingType = 'Detail'
			  AND strReportLogId = @strReportLogId
		END
	
	IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerAgingStagingTable AGING WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail')
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
		END
END

SELECT AGING.* 
FROM tblARCustomerAgingStagingTable AGING
WHERE AGING.intEntityUserId = @intEntityUserId 
  AND AGING.strAgingType = 'Detail'
  AND strReportLogId = @strReportLogId