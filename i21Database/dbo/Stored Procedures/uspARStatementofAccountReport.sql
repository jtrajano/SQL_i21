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
	SET @xmlParam = NULL 

-- Declare the variables.
DECLARE  @dtmDateTo					AS DATETIME
		,@dtmDateFrom				AS DATETIME
		,@strDateTo					AS NVARCHAR(50)
		,@strDateFrom				AS NVARCHAR(50)
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

DECLARE @temp_SOA_table TABLE(
	 [intEntityCustomerId]	 INT
	,[strCustomerNumber]	 NVARCHAR(100)
	,[strCustomerName]		 NVARCHAR(100)
	,[strStatementFormat]	 NVARCHAR(100)	
	,[dtmDateFrom]			 DATETIME
	,[dtmDateTo]			 DATETIME
)

DECLARE @temp_aging_table TABLE(
     [strCustomerName]          NVARCHAR(100)
    ,[strEntityNo]              NVARCHAR(100)
    ,[intEntityCustomerId]      INT
    ,[dblCreditLimit]           NUMERIC(18,6)
    ,[dblTotalAR]               NUMERIC(18,6)
    ,[dblFuture]                NUMERIC(18,6)
    ,[dbl0Days]                 NUMERIC(18,6)
    ,[dbl10Days]                NUMERIC(18,6)
    ,[dbl30Days]                NUMERIC(18,6)
    ,[dbl60Days]                NUMERIC(18,6)
    ,[dbl90Days]                NUMERIC(18,6)
    ,[dbl91Days]                NUMERIC(18,6)
    ,[dblTotalDue]              NUMERIC(18,6)
    ,[dblAmountPaid]            NUMERIC(18,6)
    ,[dblCredits]               NUMERIC(18,6)
	,[dblPrepayments]			NUMERIC(18,6)
    ,[dblPrepaids]              NUMERIC(18,6)
    ,[dtmAsOfDate]              DATETIME
    ,[strSalespersonName]       NVARCHAR(100)
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
SELECT  @dtmDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
       ,@condition	 = [condition]
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmAsOfDate'

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

DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmAsOfDate'

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

INSERT INTO @temp_aging_table
EXEC dbo.[uspARCustomerAgingAsOfDateReport] NULL, @dtmDateTo

SET @query = 'SELECT * FROM
(SELECT C.intEntityCustomerId
      , C.strCustomerNumber
      , strCustomerName		= E.strName
	  , C.strStatementFormat	  
      , dtmDateFrom			= ' + @strDateFrom + '
	  , dtmDateTo			= ' + @strDateTo + '
FROM tblARCustomer C INNER JOIN
       tblEMEntity E ON C.intEntityCustomerId = E.intEntityId
) MainQuery'

IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

INSERT INTO @temp_SOA_table
EXEC sp_executesql @query

SELECT * FROM @temp_SOA_table STATEMENTREPORT
LEFT JOIN @temp_aging_table AGINGREPORT
ON STATEMENTREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
WHERE ISNULL(AGINGREPORT.dblTotalAR, 0) <> 0
