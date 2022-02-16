CREATE PROCEDURE [dbo].[uspARStatementofAccountReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

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
		,@strStatementSP 				AS NVARCHAR(50)
		,@strRequestId					AS NVARCHAR(200)
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
		,@blbLogo						AS VARBINARY(MAX)
		
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

SELECT @strRequestId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strRequestId'

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

	SET @strStatementSP = CASE WHEN @strStatementFormat = 'Balance Forward' THEN 'uspARCustomerStatementBalanceForwardReport'
							   WHEN @strStatementFormat IN ('Open Item', 'Running Balance', 'Open Statement - Lazer') THEN 'uspARCustomerStatementReport'
							   WHEN @strStatementFormat = 'Payment Activity' THEN 'uspARCustomerStatementPaymentActivityReport'
							   WHEN @strStatementFormat IN ('Full Details - No Card Lock', 'AR Detail Statement') THEN 'uspARCustomerStatementFullDetailReport'
							   WHEN @strStatementFormat = 'Budget Reminder' THEN 'uspARCustomerStatementBudgetReminderReport'
							   WHEN @strStatementFormat = 'Budget Reminder Alternate 2' THEN 'uspARCustomerStatementBudgetReminderAlternate2Report'
							   WHEN @strStatementFormat = 'Honstein Oil' THEN 'uspARCustomerStatementHonsteinReport'
						  END

	EXEC dbo.uspARLogPerformanceRuntime @strStatementFormat, @strStatementSP, @strRequestId, 1, @intEntityUserId, NULL, @intPerformanceLogId OUT

	--SETUP LOGO
	SELECT @blbLogo = CASE WHEN CP.ysnStretchLogo = 1 THEN S.blbFile ELSE A.blbFile END
	FROM tblARCompanyPreference CP 	
	OUTER APPLY (
		SELECT TOP 1 U.blbFile
		FROM tblSMUpload U
		INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
		WHERE A.strScreen = 'SystemManager.CompanyPreference' 
		  AND A.strComment = 'Header'
		ORDER BY A.intAttachmentId DESC
	) A 
	OUTER APPLY (
		SELECT TOP 1 U.blbFile
		FROM tblSMUpload U
		INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
		WHERE A.strScreen = 'SystemManager.CompanyPreference' 
		  AND A.strComment = 'Stretch Header'
		ORDER BY A.intAttachmentId DESC
	) S
	
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
	ELSE IF @strStatementFormat IN ('Full Details - No Card Lock', 'AR Detail Statement')
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
				, @strStatementFormat			= @strStatementFormat
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

	--LOGO
	UPDATE tblARCustomerStatementStagingTable
	SET blbLogo = @blbLogo
	WHERE intEntityUserId = @intEntityUserId
	  AND strStatementFormat = @strStatementFormat

	DELETE FROM tblARCustomerStatementOfAccountStagingTable
	WHERE intEntityUserId = @intEntityUserId
	AND strReportLogId <> @strReportLogId

	INSERT INTO tblARCustomerStatementOfAccountStagingTable (
		  strCustomerName
		, strAccountStatusCode
		, strLocationName
		, ysnPrintZeroBalance
		, ysnPrintCreditBalance
		, ysnIncludeBudget
		, ysnPrintOnlyPastDue
		, strStatementFormat
		, dtmDateFrom
		, dtmDateTo
		, intEntityUserId
		, strReportLogId
		, blbLogo
	)
	SELECT strCustomerName			= @strCustomerName
		 , strAccountStatusCode		= @strAccountStatusCode
		 , strLocationName			= @strLocationName
		 , ysnPrintZeroBalance		= ISNULL(@ysnPrintZeroBalance, 0)
		 , ysnPrintCreditBalance	= ISNULL(@ysnPrintCreditBalance, 1)
		 , ysnIncludeBudget			= ISNULL(@ysnIncludeBudget, 0)
		 , ysnPrintOnlyPastDue		= ISNULL(@ysnPrintOnlyPastDue, 0)
		 , strStatementFormat		= @strStatementFormat
		 , dtmDateFrom				= @dtmDateFrom
	 	 , dtmDateTo				= @dtmDateTo
		 , intEntityUserId			= @intEntityUserId
		 , strReportLogId			= @strReportLogId
		 , blbLogo					= @blbLogo
END

SELECT * 
FROM tblARCustomerStatementOfAccountStagingTable
WHERE strReportLogId = @strReportLogId

EXEC dbo.uspARLogPerformanceRuntime @strStatementFormat, @strStatementSP, @strRequestId, 0, @intEntityUserId, @intPerformanceLogId, NULL