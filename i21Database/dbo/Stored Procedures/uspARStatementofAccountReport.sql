﻿CREATE PROCEDURE [dbo].[uspARStatementofAccountReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
	SET @xmlParam = NULL 

-- Declare the variables.
DECLARE  @dtmDateTo					AS DATETIME
		,@dtmDateFrom				AS DATETIME
		,@strDateTo					AS NVARCHAR(50)
		,@strDateFrom				AS NVARCHAR(50)
		,@strCustomerName           AS NVARCHAR(MAX)
		,@strCustomerNumber			AS NVARCHAR(MAX)
		,@strStatementFormat        AS NVARCHAR(50)
		,@strAccountStatusCode		AS NVARCHAR(5)
		,@strLocationName			AS NVARCHAR(50)
		,@ysnPrintZeroBalance		AS BIT
		,@ysnPrintCreditBalance		AS BIT
		,@ysnIncludeBudget			AS BIT
		,@ysnPrintOnlyPastDue		AS BIT
		,@xmlDocumentId				AS INT
		,@query						AS NVARCHAR(MAX)
		,@filter					AS NVARCHAR(MAX) = ''
		,@fieldname					AS NVARCHAR(50)
		,@condition					AS NVARCHAR(20)
		,@id						AS INT 
		,@from						AS NVARCHAR(MAX)
		,@to						AS NVARCHAR(MAX)
		,@join						AS NVARCHAR(10)
		,@begingroup				AS NVARCHAR(50)
		,@endgroup					AS NVARCHAR(50)
		,@datatype					AS NVARCHAR(50)
		
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

-- Gather the variables values from the xml table.
SELECT  @dtmDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
       ,@condition	 = [condition]
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmAsOfDate'

SELECT @strCustomerName = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strCustomerName'

SELECT @strAccountStatusCode = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strAccountStatusCode'

SELECT @strLocationName = [from]
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

SELECT @strStatementFormat = CASE WHEN ISNULL([from], '') = '' THEN 'Open Item' ELSE [from] END
FROM @temp_xml_table
WHERE [fieldname] = 'strStatementFormat'

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

IF CHARINDEX('''', @strCustomerName) > 0 
	SET @strCustomerName = REPLACE(@strCustomerName, '''''', '''')

IF ISNULL(@strCustomerName, '') <> ''
	SELECT TOP 1 @strCustomerNumber = strCustomerNumber FROM vyuARCustomerSearch WHERE strName = @strCustomerName

IF @strStatementFormat = 'Balance Forward'
	BEGIN
		EXEC dbo.uspARCustomerStatementBalanceForwardReport 
			  @dtmDateTo				= @dtmDateTo
			, @dtmDateFrom				= @dtmDateFrom
			, @ysnPrintZeroBalance		= @ysnPrintZeroBalance
			, @ysnPrintCreditBalance	= @ysnPrintCreditBalance
			, @ysnIncludeBudget			= @ysnIncludeBudget
			, @ysnPrintOnlyPastDue		= @ysnPrintOnlyPastDue
			, @ysnPrintFromCF			= 0
			, @strCustomerNumber		= @strCustomerNumber
			, @strAccountStatusCode		= @strAccountStatusCode
			, @strLocationName			= @strLocationName
			, @strCustomerName			= @strCustomerName
	END
ELSE IF ISNULL(@strStatementFormat, 'Open Item') IN ('Open Item', 'Running Balance')
	BEGIN
		EXEC dbo.uspARCustomerStatementReport
		      @dtmDateTo				= @dtmDateTo
		    , @dtmDateFrom				= @dtmDateFrom
		    , @ysnPrintZeroBalance		= @ysnPrintZeroBalance
		    , @ysnPrintCreditBalance	= @ysnPrintCreditBalance
		    , @ysnIncludeBudget			= @ysnIncludeBudget
		    , @ysnPrintOnlyPastDue		= @ysnPrintOnlyPastDue
		    , @strCustomerNumber		= @strCustomerNumber
		    , @strAccountStatusCode		= @strAccountStatusCode
		    , @strLocationName			= @strLocationName
		    , @strStatementFormat		= @strStatementFormat
			, @strCustomerName			= @strCustomerName
	END
ELSE IF @strStatementFormat = 'Payment Activity'
	BEGIN
		EXEC dbo.uspARCustomerStatementPaymentActivityReport
			  @dtmDateTo				= @dtmDateTo
		    , @dtmDateFrom				= @dtmDateFrom
		    , @ysnPrintZeroBalance		= @ysnPrintZeroBalance
		    , @ysnPrintCreditBalance	= @ysnPrintCreditBalance
		    , @ysnIncludeBudget			= @ysnIncludeBudget
		    , @ysnPrintOnlyPastDue		= @ysnPrintOnlyPastDue
		    , @strCustomerNumber		= @strCustomerNumber
		    , @strAccountStatusCode		= @strAccountStatusCode
		    , @strLocationName			= @strLocationName
			, @strCustomerName			= @strCustomerName
	END

INSERT INTO @temp_SOA_table
SELECT @strCustomerName
     , @strAccountStatusCode
	 , @strLocationName
	 , ISNULL(@ysnPrintZeroBalance, 0)
	 , ISNULL(@ysnPrintCreditBalance, 1)
	 , ISNULL(@ysnIncludeBudget, 0)
	 , ISNULL(@ysnPrintOnlyPastDue, 0)
	 , ISNULL(@strStatementFormat, 'Open Item')
	 , @dtmDateFrom
	 , @dtmDateTo

SELECT * FROM @temp_SOA_table