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
DECLARE  @strAsOfDateTo				AS NVARCHAR(50)
		,@strAsOfDateFrom	        AS NVARCHAR(50)
		,@strSalesperson			AS NVARCHAR(100)
		,@xmlDocumentId				AS INT
		,@query						AS NVARCHAR(MAX)
		,@filter					AS NVARCHAR(MAX) = ''
		,@fieldname					AS NVARCHAR(50)
		,@condition					AS NVARCHAR(20)
		,@id						AS INT 
		,@from						AS NVARCHAR(100)
		,@to						AS NVARCHAR(100)
		,@join						AS NVARCHAR(10)
		,@begingroup				AS NVARCHAR(50)
		,@endgroup					AS NVARCHAR(50)
		,@datatype					AS NVARCHAR(50)
		,@strSourceTransaction	    AS NVARCHAR(50)
		
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

SET @strAsOfDateFrom = CASE WHEN @strAsOfDateFrom IS NULL THEN '''''' ELSE ''''+@strAsOfDateFrom+'''' END
SET @strAsOfDateTo   = CASE WHEN @strAsOfDateTo IS NULL THEN '''''' ELSE ''''+@strAsOfDateTo+'''' END
SET @strSalesperson  = CASE WHEN @strSalesperson IS NULL THEN '''''' ELSE ''''+@strSalesperson+'''' END
SET @strSourceTransaction  = CASE WHEN @strSourceTransaction IS NULL THEN '''''' ELSE ''''+@strSourceTransaction+'''' END
	
DELETE FROM @temp_xml_table WHERE [fieldname] IN ('dtmAsOfDate', 'strSalespersonName', 'strSourceTransaction')

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

SET @query = 'DECLARE @temp_aging_table TABLE(
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
	   ,@strSalesperson			NVARCHAR(100)
	   ,@strSourceTransaction	NVARCHAR(100)

SET @dtmDateTo   = CAST(CASE WHEN '+@strAsOfDateTo+' <> '''' THEN '+@strAsOfDateTo+' ELSE GETDATE() END AS DATETIME)
SET @dtmDateFrom = CAST(CASE WHEN '+@strAsOfDateFrom+' <> '''' THEN '+@strAsOfDateFrom+' ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
SET @strSalesperson = ISNULL('+@strSalesperson+', NULL)
SET @strSourceTransaction = ISNULL('+@strSourceTransaction+', NULL)

IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)
ELSE 			  
	SET @dtmDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST(-53690 AS DATETIME)
	
INSERT INTO @temp_aging_table
EXEC [uspARCustomerAgingDetailAsOfDateReport] @dtmDateFrom, @dtmDateTo, @strSalesperson, @strSourceTransaction

SELECT strCompanyName		= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
     , strCompanyAddress	= (SELECT TOP 1 dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) FROM tblSMCompanySetup)
     , * 
FROM @temp_aging_table'

IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

EXEC sp_executesql @query