﻿CREATE PROCEDURE [dbo].[uspARCustomerAgingDetailReport]
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

		DECLARE @temp_aging_table TABLE(
			 [strInvoiceNumber]			NVARCHAR(100)
			,[strRecordNumber]			NVARCHAR(100)
			,[intInvoiceId]				INT
			,[strCustomerName]			NVARCHAR(100)
			,[strBOLNumber]				NVARCHAR(100)
			,[intEntityCustomerId]		INT
			,[strCustomerNumber]		NVARCHAR(100)			
			,[dblCreditLimit]			NUMERIC(18,6)
			,[dblTotalAR]				NUMERIC(18,6)
			,[dblFuture]				NUMERIC(18,6)
			,[dbl0Days]					NUMERIC(18,6)
			,[dbl10Days]				NUMERIC(18,6)
			,[dbl30Days]				NUMERIC(18,6)
			,[dbl60Days]				NUMERIC(18,6)
			,[dbl90Days]				NUMERIC(18,6)
			,[dbl91Days]				NUMERIC(18,6)
			,[dblTotalDue]				NUMERIC(18,6)
			,[dblAmountPaid]			NUMERIC(18,6)
			,[dblInvoiceTotal]			NUMERIC(18,6)
			,[dblCredits]				NUMERIC(18,6)
			,[dblPrepayments]			NUMERIC(18,6)
			,[dblPrepaids]				NUMERIC(18,6)
			,[dtmDate]					DATETIME
			,[dtmDueDate]				DATETIME
			,[dtmAsOfDate]				DATETIME
			,[strSalespersonName]		NVARCHAR(100)
			,[intCompanyLocationId]		INT
			,[strCompanyName]		    NVARCHAR(MAX)
			,[strCompanyAddress]	    NVARCHAR(MAX)
		)

		SELECT * FROM @temp_aging_table
	END

-- Declare the variables.
DECLARE  @strAsOfDateTo					AS NVARCHAR(50)
		,@strAsOfDateFrom				AS NVARCHAR(50)
		,@strSalesperson				AS NVARCHAR(100)
		,@strCustomerName				AS NVARCHAR(100)
		,@xmlDocumentId					AS INT
		,@query							AS NVARCHAR(MAX)
		,@filter						AS NVARCHAR(MAX) = ''
		,@fieldname						AS NVARCHAR(50)
		,@condition						AS NVARCHAR(20)
		,@id							AS INT 
		,@from							AS NVARCHAR(100)
		,@to							AS NVARCHAR(100)
		,@join							AS NVARCHAR(10)
		,@begingroup					AS NVARCHAR(50)
		,@endgroup						AS NVARCHAR(50)
		,@datatype						AS NVARCHAR(50)
		,@strSourceTransaction			AS NVARCHAR(50)
		,@strAgedBalances				AS NVARCHAR(100)
		,@ysnPrintOnlyOverCreditLimit	AS BIT
		
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

-- Gather the variables values from the xml table.
SELECT  @strCustomerName = ISNULL([from], '')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strCustomerName'

SELECT  @strSalesperson = ISNULL([from], '')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strSalespersonName'

SELECT	@strAsOfDateFrom = ISNULL([from], '')
       ,@strAsOfDateTo   = ISNULL([to], '')
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

SET @strAsOfDateFrom = CASE WHEN @strAsOfDateFrom IS NULL THEN '''''' ELSE ''''+@strAsOfDateFrom+'''' END
SET @strAsOfDateTo   = CASE WHEN @strAsOfDateTo IS NULL THEN '''''' ELSE ''''+@strAsOfDateTo+'''' END
SET @strCustomerName = CASE WHEN @strCustomerName IS NULL THEN '''''' ELSE ''''+@strCustomerName+'''' END
SET @strSalesperson  = CASE WHEN @strSalesperson IS NULL THEN '''''' ELSE ''''+@strSalesperson+'''' END
SET @strSourceTransaction  = CASE WHEN @strSourceTransaction IS NULL THEN '''''' ELSE ''''+@strSourceTransaction+'''' END
SET @strAgedBalances = CASE WHEN @strAgedBalances IS NULL THEN '''All''' ELSE ''''+@strAgedBalances+'''' END
SET @ysnPrintOnlyOverCreditLimit = CASE WHEN @ysnPrintOnlyOverCreditLimit IS NULL THEN 0 ELSE @ysnPrintOnlyOverCreditLimit END
	
DELETE FROM @temp_xml_table WHERE [fieldname] IN ('dtmAsOfDate', 'strSalespersonName', 'strSourceTransaction', 'strAgedBalances', 'ysnPrintOnlyOverCreditLimit')

WHILE EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT @id = id, @fieldname = [fieldname], @condition = [condition], @from = [from], @to = [to], @join = [join], @datatype = [datatype] FROM @temp_xml_table
	SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@fieldname, @condition, @from, @to, @join, null, null, @datatype)
	
	DELETE FROM @temp_xml_table WHERE id = @id

	IF EXISTS(SELECT 1 FROM @temp_xml_table)
	BEGIN
		SET @filter = @filter + ' AND '
	END
END

SET @query = CAST('' AS NVARCHAR(MAX)) + 'DECLARE @temp_aging_table TABLE(
     [strCustomerName]			NVARCHAR(100)
	,[strCustomerNumber]		NVARCHAR(100)
	,[strInvoiceNumber]			NVARCHAR(100)
	,[strRecordNumber]			NVARCHAR(100)
	,[intInvoiceId]				INT	
	,[strBOLNumber]				NVARCHAR(100)
	,[intEntityCustomerId]		INT	
	,[dblCreditLimit]			NUMERIC(18,6)
	,[dblTotalAR]				NUMERIC(18,6)
	,[dblFuture]				NUMERIC(18,6)
	,[dbl0Days]					NUMERIC(18,6)
	,[dbl10Days]				NUMERIC(18,6)
	,[dbl30Days]				NUMERIC(18,6)
	,[dbl60Days]				NUMERIC(18,6)
	,[dbl90Days]				NUMERIC(18,6)
	,[dbl91Days]				NUMERIC(18,6)
	,[dblTotalDue]				NUMERIC(18,6)
	,[dblAmountPaid]			NUMERIC(18,6)
	,[dblInvoiceTotal]			NUMERIC(18,6)
	,[dblCredits]				NUMERIC(18,6)
	,[dblPrepayments]			NUMERIC(18,6)
	,[dblPrepaids]				NUMERIC(18,6)
	,[dtmDate]					DATETIME
	,[dtmDueDate]				DATETIME
	,[dtmAsOfDate]				DATETIME
	,[strSalespersonName]		NVARCHAR(100)
	,[intCompanyLocationId]		INT
	,[strSourceTransaction]		NVARCHAR(100)
)

DECLARE @dtmDateTo				DATETIME
       ,@dtmDateFrom			DATETIME
	   ,@strCustomerName		NVARCHAR(100)
	   ,@strSalesperson			NVARCHAR(100)
	   ,@strSourceTransaction	NVARCHAR(100)
	   ,@strAgedBalances        NVARCHAR(100)
	   ,@ysnPrintOnlyOverCreditLimit BIT
	   ,@intEntityCustomerId	INT	= NULL

SET @dtmDateTo   = CAST(CASE WHEN '+@strAsOfDateTo+' <> '''' THEN '+@strAsOfDateTo+' ELSE GETDATE() END AS DATETIME)
SET @dtmDateFrom = CAST(CASE WHEN '+@strAsOfDateFrom+' <> '''' THEN '+@strAsOfDateFrom+' ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
SET @strCustomerName = ISNULL('+@strCustomerName+', NULL)
SET @strSalesperson = ISNULL('+@strSalesperson+', NULL)
SET @strSourceTransaction = ISNULL('+@strSourceTransaction+', NULL)
SET @strAgedBalances = ISNULL('+@strAgedBalances+', ''All'')
SET @ysnPrintOnlyOverCreditLimit = CAST(ISNULL('+ CAST(@ysnPrintOnlyOverCreditLimit AS NVARCHAR(5)) +', 0) AS BIT)

IF ISNULL(@strCustomerName, '''''''') <> ''''
	SELECT TOP 1 @intEntityCustomerId = intEntityId FROM vyuARCustomerSearch WITH (NOLOCK) WHERE strName = @strCustomerName

IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)
ELSE 			  
	SET @dtmDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST(-53690 AS DATETIME)
	
INSERT INTO @temp_aging_table
EXEC [uspARCustomerAgingDetailAsOfDateReport] @dtmDateFrom, @dtmDateTo, @strSalesperson, @strSourceTransaction, @intEntityCustomerId

DELETE FROM @temp_aging_table WHERE intEntityCustomerId IN (SELECT intEntityCustomerId FROM @temp_aging_table GROUP BY intEntityCustomerId HAVING SUM(ISNULL(dblTotalAR, 0)) = 0)

IF @strAgedBalances = ''Current''
	BEGIN DELETE FROM @temp_aging_table WHERE intEntityCustomerId IN (SELECT intEntityCustomerId FROM @temp_aging_table GROUP BY intEntityCustomerId HAVING SUM(ISNULL(dbl0Days, 0)) = 0)
END
ELSE IF @strAgedBalances = ''1-10 Days''
	BEGIN DELETE FROM @temp_aging_table WHERE intEntityCustomerId IN (SELECT intEntityCustomerId FROM @temp_aging_table GROUP BY intEntityCustomerId HAVING SUM(ISNULL(dbl10Days, 0)) = 0)
END
ELSE IF @strAgedBalances = ''11-30 Days''
	BEGIN DELETE FROM @temp_aging_table WHERE intEntityCustomerId IN (SELECT intEntityCustomerId FROM @temp_aging_table GROUP BY intEntityCustomerId HAVING SUM(ISNULL(dbl30Days, 0)) = 0)
END
ELSE IF @strAgedBalances = ''31-60 Days''
	BEGIN DELETE FROM @temp_aging_table WHERE intEntityCustomerId IN (SELECT intEntityCustomerId FROM @temp_aging_table GROUP BY intEntityCustomerId HAVING SUM(ISNULL(dbl60Days, 0)) = 0)
END
ELSE IF @strAgedBalances = ''61-90 Days''
	BEGIN DELETE FROM @temp_aging_table WHERE intEntityCustomerId IN (SELECT intEntityCustomerId FROM @temp_aging_table GROUP BY intEntityCustomerId HAVING SUM(ISNULL(dbl90Days, 0)) = 0)
END
ELSE IF @strAgedBalances = ''Over 90 Days''
	BEGIN DELETE FROM @temp_aging_table WHERE intEntityCustomerId IN (SELECT intEntityCustomerId FROM @temp_aging_table GROUP BY intEntityCustomerId HAVING SUM(ISNULL(dbl91Days, 0)) = 0)
END

IF ISNULL(@ysnPrintOnlyOverCreditLimit, 0) = 1
	BEGIN
		DELETE FROM @temp_aging_table 
		WHERE intEntityCustomerId IN (SELECT intEntityCustomerId 
									  FROM @temp_aging_table 
									  GROUP BY intEntityCustomerId 
									  HAVING AVG(ISNULL(dblCreditLimit, 0)) > SUM(ISNULL(dblTotalAR, 0))
										 OR (AVG(ISNULL(dblCreditLimit, 0)) = 0 AND SUM(ISNULL(dblTotalAR, 0)) = 0))
	END
ELSE
	BEGIN
		DELETE FROM @temp_aging_table 
		WHERE intEntityCustomerId IN (SELECT intEntityCustomerId 
									  FROM @temp_aging_table 
									  GROUP BY intEntityCustomerId 
									  HAVING AVG(ISNULL(dblCreditLimit, 0)) < SUM(ISNULL(dblTotalAR, 0))
										 OR (AVG(ISNULL(dblCreditLimit, 0)) = 0 AND SUM(ISNULL(dblTotalAR, 0)) = 0))
	END

DECLARE @temp_open_invoices TABLE (intInvoiceId INT)
INSERT INTO @temp_open_invoices
SELECT DISTINCT intInvoiceId FROM @temp_aging_table GROUP BY intInvoiceId HAVING SUM(ISNULL(dblTotalAR, 0)) <> 0

SELECT COMPANY.strCompanyName
     , COMPANY.strCompanyAddress
     , *
FROM @temp_aging_table AGING
INNER JOIN @temp_open_invoices UNPAID ON AGING.intInvoiceId = UNPAID.intInvoiceId
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY'

IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

EXEC sp_executesql @query