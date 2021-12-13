CREATE PROCEDURE [dbo].[uspARStatementofAccountReport]
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

		SELECT * FROM tblARCustomerStatementStagingTable
	END

-- Declare the variables.
DECLARE  @dtmDateTo						AS DATETIME
		,@dtmDateFrom					AS DATETIME
		,@strDateTo						AS NVARCHAR(50)
		,@strDateFrom					AS NVARCHAR(50)
		,@strCustomerName				AS NVARCHAR(MAX)
		,@strCustomerIds				AS NVARCHAR(MAX)
		,@strCustomerNumber				AS NVARCHAR(MAX)
		,@strStatementFormat			AS NVARCHAR(50)
		,@strAccountStatusCode			AS NVARCHAR(5)
		,@strLocationName				AS NVARCHAR(50)
		,@ysnPrintZeroBalance			AS BIT
		,@ysnPrintCreditBalance			AS BIT
		,@ysnIncludeBudget				AS BIT
		,@ysnPrintOnlyPastDue			AS BIT
		,@ysnEmailOnly					AS BIT
		,@ysnActiveCustomers			AS BIT
		,@ysnIncludeWriteOffPayment		AS BIT
		,@xmlDocumentId					AS INT
		,@intEntityUserId				AS INT
		,@query							AS NVARCHAR(MAX)
		,@filter						AS NVARCHAR(MAX) = ''
		,@fieldname						AS NVARCHAR(50)
		,@condition						AS NVARCHAR(20)
		,@id							AS INT 
		,@from							AS NVARCHAR(MAX)
		,@to							AS NVARCHAR(MAX)
		,@join							AS NVARCHAR(10)
		,@begingroup					AS NVARCHAR(50)
		,@endgroup						AS NVARCHAR(50)
		,@datatype						AS NVARCHAR(50)
		,@intPerformanceLogId			AS INT = NULL
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

IF NOT  EXISTS (SELECT TOP 1 1 FROM  @temp_xml_table WHERE fieldname ='strStatementFormat')
BEGIN
	INSERT INTO  @temp_xml_table ([fieldname],[condition],[from],[to],[join],[begingroup],[endgroup],[datatype]) 
	SELECT  'strStatementFormat', 'Equal To' , 'Open Item' , NULL, 'AND', '' , '' , 'string'
END

-- Gather the variables values from the xml table.
SELECT  @dtmDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
       ,@condition	 = [condition]
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmAsOfDate'

SELECT @strCustomerName = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strCustomerName'

SELECT @strCustomerNumber = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strCustomerNumber'

SELECT @strCustomerIds = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strCustomerIds'

SELECT @strAccountStatusCode = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strAccountStatusCode'

SELECT @strLocationName = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strLocationName'

SELECT @ysnPrintZeroBalance = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'ysnPrintZeroBalance'

SELECT @ysnPrintCreditBalance = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'ysnPrintCreditBalance'

SELECT @ysnIncludeBudget = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'ysnIncludeBudget'

SELECT @ysnPrintOnlyPastDue = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'ysnPrintOnlyPastDue'

SELECT @ysnEmailOnly = [from] 
FROM @temp_xml_table
WHERE [fieldname] = 'ysnHasEmailSetup'

SELECT @ysnActiveCustomers = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'ysnActiveCustomers'

SELECT @strStatementFormat = CASE WHEN ISNULL([from], '') = '' THEN 'Open Item' ELSE [from] END
FROM @temp_xml_table
WHERE [fieldname] = 'strStatementFormat'

SELECT @ysnIncludeWriteOffPayment = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'ysnIncludeWriteOffPayment'

SELECT @intEntityUserId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intSrCurrentUserId'

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
	
	SET @strDateTo = ''''+ CONVERT(NVARCHAR(50),@dtmDateTo, 110) + ''''
	SET @strDateFrom = ''''+ CONVERT(NVARCHAR(50),@dtmDateFrom, 110) + ''''
	SET @intEntityUserId = NULLIF(@intEntityUserId, 0)

	IF CHARINDEX('''', @strCustomerName) > 0 
		SET @strCustomerName = REPLACE(@strCustomerName, '''''', '''')

	EXEC dbo.uspARLogPerformanceRuntime @strStatementFormat, 'uspARCustomerStatementReport', 1, @intEntityUserId, NULL, @intPerformanceLogId OUT
	
	IF @strStatementFormat = 'Balance Forward'
		BEGIN
			EXEC dbo.uspARCustomerStatementBalanceForwardReport 
				  @dtmDateTo					= @dtmDateTo
				, @dtmDateFrom					= @dtmDateFrom
				, @ysnPrintZeroBalance			= @ysnPrintZeroBalance
				, @ysnPrintCreditBalance		= @ysnPrintCreditBalance
				, @ysnIncludeBudget				= @ysnIncludeBudget
				, @ysnPrintOnlyPastDue			= @ysnPrintOnlyPastDue
				, @ysnActiveCustomers			= @ysnActiveCustomers
				, @ysnPrintFromCF				= 0
				, @strCustomerNumber			= @strCustomerNumber
				, @strAccountStatusCode			= @strAccountStatusCode
				, @strLocationName				= @strLocationName
				, @strCustomerName				= @strCustomerName
				, @strCustomerIds				= @strCustomerIds
				, @ysnEmailOnly					= @ysnEmailOnly
				, @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffPayment
				, @intEntityUserId				= @intEntityUserId
		END
	ELSE IF @strStatementFormat IN ('Open Item', 'Running Balance', 'Open Statement - Lazer')
		BEGIN
			EXEC dbo.uspARCustomerStatementReport
				  @dtmDateTo					= @dtmDateTo
				, @dtmDateFrom					= @dtmDateFrom
				, @ysnPrintZeroBalance			= @ysnPrintZeroBalance
				, @ysnPrintCreditBalance		= @ysnPrintCreditBalance
				, @ysnIncludeBudget				= @ysnIncludeBudget
				, @ysnPrintOnlyPastDue			= @ysnPrintOnlyPastDue
				, @ysnActiveCustomers			= @ysnActiveCustomers
				, @strCustomerNumber			= @strCustomerNumber
				, @strAccountStatusCode			= @strAccountStatusCode
				, @strLocationName				= @strLocationName
				, @strStatementFormat			= @strStatementFormat
				, @strCustomerName				= @strCustomerName
				, @strCustomerIds				= @strCustomerIds
				, @ysnEmailOnly					= @ysnEmailOnly
				, @ysnIncludeWriteOffPayment 	= @ysnIncludeWriteOffPayment
				, @intEntityUserId				= @intEntityUserId
		END
	ELSE IF @strStatementFormat = 'Payment Activity'
		BEGIN
			EXEC dbo.uspARCustomerStatementPaymentActivityReport
				  @dtmDateTo					= @dtmDateTo
				, @dtmDateFrom					= @dtmDateFrom
				, @ysnPrintZeroBalance			= @ysnPrintZeroBalance
				, @ysnPrintCreditBalance		= @ysnPrintCreditBalance
				, @ysnIncludeBudget				= @ysnIncludeBudget
				, @ysnPrintOnlyPastDue			= @ysnPrintOnlyPastDue
				, @ysnActiveCustomers			= @ysnActiveCustomers
				, @strCustomerNumber			= @strCustomerNumber
				, @strAccountStatusCode			= @strAccountStatusCode
				, @strLocationName				= @strLocationName
				, @strCustomerName				= @strCustomerName
				, @strCustomerIds				= @strCustomerIds
				, @ysnEmailOnly					= @ysnEmailOnly
				, @ysnIncludeWriteOffPayment 	= @ysnIncludeWriteOffPayment
				, @intEntityUserId				= @intEntityUserId
		END
	ELSE IF @strStatementFormat = 'Full Details - No Card Lock'
		BEGIN
			EXEC dbo.uspARCustomerStatementFullDetailReport
				  @dtmDateTo					= @dtmDateTo
				, @dtmDateFrom					= @dtmDateFrom
				, @ysnPrintZeroBalance			= @ysnPrintZeroBalance
				, @ysnPrintCreditBalance		= @ysnPrintCreditBalance
				, @ysnIncludeBudget				= @ysnIncludeBudget
				, @ysnPrintOnlyPastDue			= @ysnPrintOnlyPastDue
				, @ysnActiveCustomers			= @ysnActiveCustomers
				, @strCustomerNumber			= @strCustomerNumber
				, @strAccountStatusCode			= @strAccountStatusCode
				, @strLocationName				= @strLocationName
				, @strCustomerName				= @strCustomerName
				, @strCustomerIds				= @strCustomerIds
				, @ysnEmailOnly					= @ysnEmailOnly
				, @ysnIncludeWriteOffPayment    = @ysnIncludeWriteOffPayment
				, @intEntityUserId				= @intEntityUserId
		END
	ELSE IF @strStatementFormat = 'Budget Reminder'
		BEGIN
			EXEC dbo.uspARCustomerStatementBudgetReminderReport
				  @dtmDateTo					= @dtmDateTo
				, @dtmDateFrom					= @dtmDateFrom
				, @ysnPrintZeroBalance			= @ysnPrintZeroBalance
				, @ysnPrintCreditBalance		= @ysnPrintCreditBalance
				, @ysnIncludeBudget				= @ysnIncludeBudget
				, @ysnPrintOnlyPastDue			= @ysnPrintOnlyPastDue
				, @ysnActiveCustomers			= @ysnActiveCustomers
				, @strCustomerNumber			= @strCustomerNumber
				, @strAccountStatusCode			= @strAccountStatusCode
				, @strLocationName				= @strLocationName
				, @strCustomerName				= @strCustomerName
				, @strCustomerIds				= @strCustomerIds
				, @ysnEmailOnly					= @ysnEmailOnly
				, @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffPayment
				, @intEntityUserId				= @intEntityUserId
		END
	ELSE IF @strStatementFormat = 'Budget Reminder Alternate 2'
		BEGIN
			EXEC dbo.uspARCustomerStatementBudgetReminderAlternate2Report
				  @dtmDateTo					= @dtmDateTo
				, @dtmDateFrom					= @dtmDateFrom
				, @ysnPrintZeroBalance			= @ysnPrintZeroBalance
				, @ysnPrintCreditBalance		= @ysnPrintCreditBalance
				, @ysnIncludeBudget				= @ysnIncludeBudget
				, @ysnPrintOnlyPastDue			= @ysnPrintOnlyPastDue
				, @ysnActiveCustomers			= @ysnActiveCustomers
				, @strCustomerNumber			= @strCustomerNumber
				, @strAccountStatusCode			= @strAccountStatusCode
				, @strLocationName				= @strLocationName
				, @strCustomerName				= @strCustomerName
				, @strCustomerIds				= @strCustomerIds
				, @ysnEmailOnly					= @ysnEmailOnly
				, @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffPayment
				, @intEntityUserId				= @intEntityUserId
		END
	ELSE IF @strStatementFormat = 'Honstein Oil'
		BEGIN
			EXEC dbo.uspARCustomerStatementHonsteinReport
				  @dtmDateTo					= @dtmDateTo
				, @dtmDateFrom					= @dtmDateFrom
				, @ysnPrintZeroBalance			= @ysnPrintZeroBalance
				, @ysnPrintCreditBalance		= @ysnPrintCreditBalance
				, @ysnIncludeBudget				= @ysnIncludeBudget
				, @ysnPrintOnlyPastDue			= @ysnPrintOnlyPastDue
				, @ysnActiveCustomers			= @ysnActiveCustomers
				, @strCustomerNumber			= @strCustomerNumber
				, @strAccountStatusCode			= @strAccountStatusCode
				, @strLocationName				= @strLocationName
				, @strCustomerName				= @strCustomerName
				, @strCustomerIds				= @strCustomerIds
				, @ysnEmailOnly					= @ysnEmailOnly
				, @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffPayment
				, @intEntityUserId				= @intEntityUserId
		END

	DELETE FROM tblARCustomerStatementOfAccountStagingTable
	WHERE intEntityUserId = @intEntityUserId
	AND strReportLogId <> @strReportLogId

	INSERT INTO tblARCustomerStatementOfAccountStagingTable
	SELECT @strCustomerName
		 , @strAccountStatusCode
		 , @strLocationName
		 , ISNULL(@ysnPrintZeroBalance, 0)
		 , ISNULL(@ysnPrintCreditBalance, 1)
		 , ISNULL(@ysnIncludeBudget, 0)
		 , ISNULL(@ysnPrintOnlyPastDue, 0)
		 , @strStatementFormat
		 , @dtmDateFrom
	 	 , @dtmDateTo
		 , @intEntityUserId
		 , @strReportLogId
END

SELECT * 
FROM tblARCustomerStatementOfAccountStagingTable
WHERE strReportLogId = @strReportLogId

EXEC dbo.uspARLogPerformanceRuntime @strStatementFormat, 'uspARCustomerStatementReport', 0, @intEntityUserId, @intPerformanceLogId, NULL