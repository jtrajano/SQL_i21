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
	  , @intEntityUserId				INT	= NULL
	  , @strCustomerIds					NVARCHAR(MAX)
	  , @strSalespersonIds				NVARCHAR(MAX)	  	  
	  , @strAccountStatusIds			NVARCHAR(MAX)
	  , @strCompanyLocationIds			NVARCHAR(MAX)
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
	  , @ysnRollCredits					BIT
	  , @ysnOverrideCashFlow			BIT = 0
	  , @ysnExcludeAccountStatus		BIT
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
						SELECT @strAccountStatusIds = LEFT(intAccountStatusId, LEN(intAccountStatusId) - 1) +','+ ISNULL(@strAccountStatusIds,'')
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
		ELSE IF @condition = 'Not Equal To'
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
						SELECT @strAccountStatusIds = LEFT(intAccountStatusId, LEN(intAccountStatusId) - 1) +','+ ISNULL(@strAccountStatusIds,'')
						FROM (
							SELECT DISTINCT CAST(S.intAccountStatusId AS VARCHAR(200))  + ', '
							FROM tblARAccountStatus S
							INNER JOIN @temp_xml_table TT ON S.strAccountStatusCode = REPLACE(ISNULL(TT.[from], ''), '''''', '''')
							WHERE TT.fieldname = 'strAccountStatusCode'
							  AND TT.condition = 'Not Equal To'
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
		ELSE IF @condition = 'Between'
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

SELECT  @intEntityUserId = NULLIF(CAST(ISNULL([from], '') AS INT), 0)
FROM	@temp_xml_table
WHERE	[fieldname] = 'intSrCurrentUserId'

SELECT @strReportLogId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strReportLogId'

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)
ELSE 			  
	SET @dtmDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST(-53690 AS DATETIME)
	
EXEC dbo.uspARCustomerAgingAsOfDateReport @dtmDateFrom				= @dtmDateFrom
										, @dtmDateTo				= @dtmDateTo
										, @intEntityUserId			= @intEntityUserId
										, @strCustomerIds			= @strCustomerIds
										, @strSalespersonIds		= @strSalespersonIds
										, @strCompanyLocationIds	= @strCompanyLocationIds
										, @strAccountStatusIds		= @strAccountStatusIds
										, @strSourceTransaction		= @strSourceTransaction										
										, @ysnExcludeAccountStatus	= @ysnExcludeAccountStatus
										, @ysnOverrideCashFlow		= @ysnOverrideCashFlow
										, @strReportLogId			= @strReportLogId

	EXEC dbo.uspARGLAccountReport @dtmAsOfDate = @dtmDateTo
								, @intEntityUserId = @intEntityUserId
							
	--ROLL CREDITS
	IF(OBJECT_ID('tempdb..#CUSTOMERSWITHCREDITS') IS NOT NULL)
	BEGIN
		DROP TABLE #CUSTOMERSWITHCREDITS
	END

	IF ISNULL(@ysnRollCredits, 0) = 1
		BEGIN
			--GET CUSTOMERS WITH OPEN CREDITS AND INVOICES
			SELECT intEntityCustomerId	= intEntityCustomerId
				 , dbl0Days				= ISNULL(dbl0Days, 0)	
				 , dbl10Days			= ISNULL(dbl10Days, 0)
				 , dbl30Days			= ISNULL(dbl30Days, 0)
				 , dbl60Days			= ISNULL(dbl60Days, 0)
				 , dbl90Days			= ISNULL(dbl90Days, 0)
				 , dbl91Days			= ISNULL(dbl91Days, 0)
				 , dblCredits			= ISNULL(dblCredits, 0)
				 , dblPrepayments		= ISNULL(dblPrepayments, 0)
				 , ysnComputed			= CAST(0 AS BIT)
			INTO #CUSTOMERSWITHCREDITS
			FROM tblARCustomerAgingStagingTable
			WHERE intEntityUserId = 1 
			  AND strAgingType = 'Summary'
			  AND ABS(ISNULL(dblCredits, 0)) + ABS(ISNULL(dblPrepayments, 0)) <> 0
			  AND ISNULL(dbl0Days, 0) + ISNULL(dbl10Days, 0) + ISNULL(dbl30Days, 0) + ISNULL(dbl60Days, 0) + ISNULL(dbl90Days, 0) + ISNULL(dbl91Days, 0) <> 0
			  AND strReportLogId = @strReportLogId

			WHILE EXISTS (SELECT TOP 1 NULL FROM #CUSTOMERSWITHCREDITS WHERE ysnComputed = 0)
				BEGIN
					DECLARE @intEntityCustomerId	INT = NULL
						  , @dblRunningCredits		NUMERIC(18, 6) = 0
						  , @dblRunningPrepaids		NUMERIC(18, 6) = 0
						  , @dblNewValue			NUMERIC(18, 6) = 0

					SELECT TOP 1 @intEntityCustomerId	= intEntityCustomerId
							   , @dblRunningCredits		= ABS(dblCredits)
							   , @dblRunningPrepaids	= ABS(dblPrepayments) 
					FROM #CUSTOMERSWITHCREDITS
					WHERE ysnComputed = 0

					WHILE ((SELECT ISNULL(dbl0Days, 0) + ISNULL(dbl10Days, 0) + ISNULL(dbl30Days, 0) + ISNULL(dbl60Days, 0) + ISNULL(dbl90Days, 0) + ISNULL(dbl91Days, 0) FROM #CUSTOMERSWITHCREDITS WHERE intEntityCustomerId = @intEntityCustomerId) > 0 AND (@dblRunningCredits > 0 OR @dblRunningPrepaids > 0))
						BEGIN
							--CREDITS OVER 90 DAYS
							IF @dblRunningCredits > 0
								BEGIN
									SET @dblNewValue = 0
									SELECT @dblNewValue = CASE WHEN dbl91Days > @dblRunningCredits THEN dbl91Days - @dblRunningCredits ELSE 0 END 
									FROM #CUSTOMERSWITHCREDITS 
									WHERE intEntityCustomerId = @intEntityCustomerId 
									  AND dbl91Days > 0

									UPDATE #CUSTOMERSWITHCREDITS 
									SET dbl91Days = @dblNewValue
									  , @dblRunningCredits = CASE WHEN dbl91Days > @dblRunningCredits THEN 0 ELSE @dblRunningCredits - dbl91Days END
									WHERE intEntityCustomerId = @intEntityCustomerId
									  AND dbl91Days > 0
								END

							--CREDITS 61-90 DAYS
							IF @dblRunningCredits > 0
								BEGIN
									SET @dblNewValue = 0
									SELECT @dblNewValue = CASE WHEN dbl90Days > @dblRunningCredits THEN dbl90Days - @dblRunningCredits ELSE 0 END 
									FROM #CUSTOMERSWITHCREDITS 
									WHERE intEntityCustomerId = @intEntityCustomerId 
									  AND dbl90Days > 0

									UPDATE #CUSTOMERSWITHCREDITS 
									SET dbl90Days = @dblNewValue
									  , @dblRunningCredits = CASE WHEN dbl90Days > @dblRunningCredits THEN 0 ELSE @dblRunningCredits - dbl90Days END
									WHERE intEntityCustomerId = @intEntityCustomerId
									  AND dbl90Days > 0
								END

							--CREDITS 31-60 DAYS
							IF @dblRunningCredits > 0
								BEGIN
									SET @dblNewValue = 0
									SELECT @dblNewValue = CASE WHEN dbl60Days > @dblRunningCredits THEN dbl60Days - @dblRunningCredits ELSE 0 END 
									FROM #CUSTOMERSWITHCREDITS 
									WHERE intEntityCustomerId = @intEntityCustomerId 
									  AND dbl60Days > 0

									UPDATE #CUSTOMERSWITHCREDITS 
									SET dbl60Days = @dblNewValue
									  , @dblRunningCredits = CASE WHEN dbl60Days > @dblRunningCredits THEN 0 ELSE @dblRunningCredits - dbl60Days END
									WHERE intEntityCustomerId = @intEntityCustomerId
									  AND dbl60Days > 0
								END

							--CREDITS 11-30 DAYS
							IF @dblRunningCredits > 0
								BEGIN
									SET @dblNewValue = 0
									SELECT @dblNewValue = CASE WHEN dbl30Days > @dblRunningCredits THEN dbl30Days - @dblRunningCredits ELSE 0 END 
									FROM #CUSTOMERSWITHCREDITS 
									WHERE intEntityCustomerId = @intEntityCustomerId 
									  AND dbl30Days > 0

									UPDATE #CUSTOMERSWITHCREDITS 
									SET dbl30Days = @dblNewValue
									  , @dblRunningCredits = CASE WHEN dbl30Days > @dblRunningCredits THEN 0 ELSE @dblRunningCredits - dbl30Days END
									WHERE intEntityCustomerId = @intEntityCustomerId
									  AND dbl30Days > 0
								END

							--CREDITS 1-10 DAYS
							IF @dblRunningCredits > 0
								BEGIN
									SET @dblNewValue = 0
									SELECT @dblNewValue = CASE WHEN dbl10Days > @dblRunningCredits THEN dbl10Days - @dblRunningCredits ELSE 0 END 
									FROM #CUSTOMERSWITHCREDITS 
									WHERE intEntityCustomerId = @intEntityCustomerId 
									  AND dbl10Days > 0

									UPDATE #CUSTOMERSWITHCREDITS 
									SET dbl10Days = @dblNewValue
									  , @dblRunningCredits = CASE WHEN dbl10Days > @dblRunningCredits THEN 0 ELSE @dblRunningCredits - dbl10Days END
									WHERE intEntityCustomerId = @intEntityCustomerId
									  AND dbl10Days > 0
								END

							--CREDITS CURRENT
							IF @dblRunningCredits > 0
								BEGIN
									SET @dblNewValue = 0
									SELECT @dblNewValue = CASE WHEN dbl0Days > @dblRunningCredits THEN dbl0Days - @dblRunningCredits ELSE 0 END 
									FROM #CUSTOMERSWITHCREDITS 
									WHERE intEntityCustomerId = @intEntityCustomerId 
									  AND dbl0Days > 0

									UPDATE #CUSTOMERSWITHCREDITS 
									SET dbl0Days = @dblNewValue
									  , @dblRunningCredits = CASE WHEN dbl0Days > @dblRunningCredits THEN 0 ELSE @dblRunningCredits - dbl0Days END
									WHERE intEntityCustomerId = @intEntityCustomerId
									  AND dbl0Days > 0
								END

							--PREPAIDS OVER 90 DAYS
							IF @dblRunningPrepaids > 0
								BEGIN
									SET @dblNewValue = 0
									SELECT @dblNewValue = CASE WHEN dbl91Days > @dblRunningPrepaids THEN dbl91Days - @dblRunningPrepaids ELSE 0 END 
									FROM #CUSTOMERSWITHCREDITS 
									WHERE intEntityCustomerId = @intEntityCustomerId 
									  AND dbl91Days > 0

									UPDATE #CUSTOMERSWITHCREDITS 
									SET dbl91Days = @dblNewValue
									  , @dblRunningPrepaids = CASE WHEN dbl91Days > @dblRunningPrepaids THEN 0 ELSE @dblRunningPrepaids - dbl91Days END
									WHERE intEntityCustomerId = @intEntityCustomerId
									  AND dbl91Days > 0
								END

							--PREPAIDS 61-90 DAYS
							IF @dblRunningPrepaids > 0
								BEGIN
									SET @dblNewValue = 0
									SELECT @dblNewValue = CASE WHEN dbl90Days > @dblRunningPrepaids THEN dbl90Days - @dblRunningPrepaids ELSE 0 END 
									FROM #CUSTOMERSWITHCREDITS
									WHERE intEntityCustomerId = @intEntityCustomerId 
									  AND dbl90Days > 0

									UPDATE #CUSTOMERSWITHCREDITS 
									SET dbl90Days = @dblNewValue
									  , @dblRunningPrepaids = CASE WHEN dbl90Days > @dblRunningPrepaids THEN 0 ELSE @dblRunningPrepaids - dbl90Days END
									WHERE intEntityCustomerId = @intEntityCustomerId
									  AND dbl90Days > 0
								END

							--PREPAIDS 31-60 DAYS
							IF @dblRunningPrepaids > 0
								BEGIN
									SET @dblNewValue = 0
									SELECT @dblNewValue = CASE WHEN dbl60Days > @dblRunningPrepaids THEN dbl60Days - @dblRunningPrepaids ELSE 0 END 
									FROM #CUSTOMERSWITHCREDITS
									WHERE intEntityCustomerId = @intEntityCustomerId 
									  AND dbl60Days > 0

									UPDATE #CUSTOMERSWITHCREDITS 
									SET dbl60Days = @dblNewValue
									  , @dblRunningPrepaids = CASE WHEN dbl60Days > @dblRunningPrepaids THEN 0 ELSE @dblRunningPrepaids - dbl60Days END
									WHERE intEntityCustomerId = @intEntityCustomerId
									  AND dbl60Days > 0
								END

							--PREPAIDS 11-30 DAYS
							IF @dblRunningPrepaids > 0
								BEGIN
									SET @dblNewValue = 0
									SELECT @dblNewValue = CASE WHEN dbl30Days > @dblRunningPrepaids THEN dbl30Days - @dblRunningPrepaids ELSE 0 END 
									FROM #CUSTOMERSWITHCREDITS
									WHERE intEntityCustomerId = @intEntityCustomerId 
									  AND dbl30Days > 0

									UPDATE #CUSTOMERSWITHCREDITS 
									SET dbl30Days = @dblNewValue
									  , @dblRunningPrepaids = CASE WHEN dbl30Days > @dblRunningPrepaids THEN 0 ELSE @dblRunningPrepaids - dbl30Days END
									WHERE intEntityCustomerId = @intEntityCustomerId
									  AND dbl30Days > 0
								END

							--PREPAIDS 1-10 DAYS
							IF @dblRunningPrepaids > 0
								BEGIN
									SET @dblNewValue = 0
									SELECT @dblNewValue = CASE WHEN dbl10Days > @dblRunningPrepaids THEN dbl10Days - @dblRunningPrepaids ELSE 0 END 
									FROM #CUSTOMERSWITHCREDITS
									WHERE intEntityCustomerId = @intEntityCustomerId 
									  AND dbl10Days > 0

									UPDATE #CUSTOMERSWITHCREDITS 
									SET dbl10Days = @dblNewValue
									  , @dblRunningPrepaids = CASE WHEN dbl10Days > @dblRunningPrepaids THEN 0 ELSE @dblRunningPrepaids - dbl10Days END
									WHERE intEntityCustomerId = @intEntityCustomerId
									  AND dbl10Days > 0
								END

							--PREPAIDS CURRENT
							IF @dblRunningPrepaids > 0
								BEGIN
									SET @dblNewValue = 0
									SELECT @dblNewValue = CASE WHEN dbl0Days > @dblRunningPrepaids THEN dbl0Days - @dblRunningPrepaids ELSE 0 END 
									FROM #CUSTOMERSWITHCREDITS
									WHERE intEntityCustomerId = @intEntityCustomerId 
									  AND dbl0Days > 0

									UPDATE #CUSTOMERSWITHCREDITS 
									SET dbl0Days = @dblNewValue
									  , @dblRunningPrepaids = CASE WHEN dbl0Days > @dblRunningPrepaids THEN 0 ELSE @dblRunningPrepaids - dbl0Days END
									WHERE intEntityCustomerId = @intEntityCustomerId
									  AND dbl0Days > 0
								END
						END

					UPDATE #CUSTOMERSWITHCREDITS 
					SET ysnComputed		= CAST(1 AS BIT) 
					  , dblCredits		= @dblRunningCredits * -1
					  , dblPrepayments	= @dblRunningPrepaids * -1
					WHERE intEntityCustomerId = @intEntityCustomerId
				END
		
			UPDATE AGING 
			SET dbl0Days		= CC.dbl0Days
			  , dbl10Days		= CC.dbl10Days
			  , dbl30Days		= CC.dbl30Days
			  , dbl60Days		= CC.dbl60Days
			  , dbl90Days		= CC.dbl90Days
			  , dbl91Days		= CC.dbl91Days
			  , dblCredits		= CC.dblCredits
			  , dblPrepayments	= CC.dblPrepayments
			  , dblPrepaids		= CC.dblPrepayments
			FROM tblARCustomerAgingStagingTable AGING
			INNER JOIN #CUSTOMERSWITHCREDITS CC ON CC.intEntityCustomerId = AGING.intEntityCustomerId
			WHERE AGING.intEntityUserId = 1 
			  AND AGING.strAgingType = 'Summary'
			  AND strReportLogId = @strReportLogId
			  AND CC.ysnComputed = 1
		END

	--AGED BALANCES
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
			AND strReportLogId = @strReportLogId
			AND (
				   ((ISNULL(dbl0Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = 'Current')))
				OR ((ISNULL(dbl10Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '1-10 Days')))
				OR ((ISNULL(dbl30Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '11-30 Days')))
				OR ((ISNULL(dbl60Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '31-60 Days')))
				OR ((ISNULL(dbl90Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = '61-90 Days')))
				OR ((ISNULL(dbl91Days, 0) <> 0 AND EXISTS (SELECT TOP 1 NULL FROM #AGEDBALANCES WHERE ISNULL(strAgedBalances, '') = 'Over 90 Days')))
			)

			DELETE AGING 
			FROM tblARCustomerAgingStagingTable AGING
			LEFT JOIN #CUSTOMERWITHBALANCES BAL ON AGING.intEntityCustomerId = BAL.intEntityCustomerId
			WHERE intEntityUserId = @intEntityUserId 
			  AND strAgingType = 'Summary'
			  AND ISNULL(BAL.intEntityCustomerId, 0) = 0
			  AND strReportLogId = @strReportLogId

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
				  AND strReportLogId = @strReportLogId
			) AGING
			WHERE intEntityUserId = @intEntityUserId 
		END

	DELETE FROM tblARCustomerAgingStagingTable WHERE dbo.fnRoundBanker(dblTotalAR, 2) = 0.00 
												 AND dbo.fnRoundBanker(dblCredits, 2) = 0.00 
												 AND dbo.fnRoundBanker(dblPrepayments, 2) = 0.00
												 AND intEntityUserId = @intEntityUserId
												 AND strAgingType = 'Summary'
												 AND strReportLogId = @strReportLogId

	IF ISNULL(@ysnPrintOnlyOverCreditLimit, 0) = 1
		BEGIN
			DELETE FROM tblARCustomerAgingStagingTable WHERE (ISNULL(dblCreditLimit, 0) > ISNULL(dblTotalAR, 0)
											OR (ISNULL(dblCreditLimit, 0) = 0 AND ISNULL(dblTotalAR, 0) = 0)
											OR ISNULL(dblCreditLimit, 0) = 0)
											AND intEntityUserId = @intEntityUserId
											AND strAgingType = 'Summary'
		END

	IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerAgingStagingTable WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Summary' AND strReportLogId = @strReportLogId)
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

	IF EXISTS (SELECT TOP 1 NULL FROM tblARCustomerAgingStagingTable WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Summary' AND strReportLogId = @strReportLogId)
		BEGIN
			UPDATE AGING
			SET  dblTotalCustomerAR = ISNULL(dbl0Days, 0) + ISNULL(dbl10Days, 0) + ISNULL(dbl30Days, 0) + ISNULL(dbl60Days, 0) + ISNULL(dbl90Days, 0) + ISNULL(dbl91Days, 0) + ISNULL(dblCredits, 0) + ISNULL(dblPrepayments, 0)
			FROM tblARCustomerAgingStagingTable AGING
			WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Summary' AND strReportLogId = @strReportLogId
		END
END

SELECT * 
FROM tblARCustomerAgingStagingTable 
WHERE intEntityUserId = @intEntityUserId 
AND strAgingType = 'Summary' 
AND strReportLogId = @strReportLogId