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

DECLARE @temp_SOA_table TABLE(
	 [strCustomerName]			NVARCHAR(MAX)
	,[strAccountStatusCode]		NVARCHAR(5)
	,[strLocationName]			NVARCHAR(50)
	,[ysnPrintZeroBalance]		BIT
	,[ysnPrintCreditBalance]	BIT
	,[ysnIncludeBudget]			BIT
	,[ysnPrintOnlyPastDue]		BIT
	,[strStatementFormat]		NVARCHAR(100)	
	,[dtmDateFrom]				DATETIME
	,[dtmDateTo]				DATETIME
	,[intEntityUserId]			INT
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

INSERT INTO @temp_SOA_table
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

SELECT * FROM @temp_SOA_table