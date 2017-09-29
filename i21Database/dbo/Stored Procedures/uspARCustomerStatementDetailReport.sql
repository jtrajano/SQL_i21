CREATE PROCEDURE [dbo].[uspARCustomerStatementDetailReport]
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
		,@innerQuery				AS NVARCHAR(MAX) = ''
		,@joinQuery                 AS NVARCHAR(MAX) = ''
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
		,@strCustomerName			AS NVARCHAR(MAX)
		
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

DECLARE @temp_statement_table TABLE(
	 [strReferenceNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strTransactionType]			NVARCHAR(100)
	,[intEntityCustomerId]			INT
	,[dtmDueDate]					DATETIME
	,[dtmDate]						DATETIME
	,[intDaysDue]					INT
	,[dblTotalAmount]				NUMERIC(18,6)
	,[dblAmountPaid]				NUMERIC(18,6)
	,[dblAmountDue]					NUMERIC(18,6)
	,[dblPastDue]					NUMERIC(18,6)
	,[dblMonthlyBudget]				NUMERIC(18,6)
	,[strDescription]				NVARCHAR(100)
	,[strItemNo]					NVARCHAR(100)
	,[dblQtyOrdered]				NUMERIC(18,6)
	,[dblQtyShipped]				NUMERIC(18,6)
	,[dblTotal]						NUMERIC(18,6)
	,[dblPrice]						NUMERIC(18,6)
	,[intInvoiceId]					INT
	,[strCustomerNumber]			NVARCHAR(100)
	,[strName]						NVARCHAR(100)
	,[strBOLNumber]					NVARCHAR(100)
	,[dblCreditLimit]				NUMERIC(18,6)
	,[strFullAddress]				NVARCHAR(MAX)
	,[strStatementFooterComment]	NVARCHAR(MAX)	
	,[strCompanyName]				NVARCHAR(MAX)
	,[strCompanyAddress]			NVARCHAR(MAX)
	,[ysnStatementCreditLimit]		BIT
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
WHERE	[fieldname] = 'dtmDate'

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

IF UPPER(@condition) = UPPER('As Of')
	BEGIN		
		SET @innerQuery = 'AND I.dtmPostDate <= '+ @strDateTo +''
	END
ELSE
	BEGIN
		SET @innerQuery = 'AND I.dtmPostDate BETWEEN '+ @strDateFrom +' AND '+ @strDateTo+''
	END

TRUNCATE TABLE tblARCustomerAgingStagingTable
INSERT INTO tblARCustomerAgingStagingTable (
	   strCustomerName
	 , strCustomerNumber
	 , intEntityCustomerId
	 , dblCreditLimit
	 , dblTotalAR
	 , dblFuture
	 , dbl0Days
	 , dbl10Days
	 , dbl30Days
	 , dbl60Days
	 , dbl90Days
	 , dbl91Days
	 , dblTotalDue
	 , dblAmountPaid
	 , dblCredits
	 , dblPrepayments
	 , dblPrepaids
	 , dtmAsOfDate
	 , strSalespersonName
	 , strSourceTransaction
	 , strCompanyName
	 , strCompanyAddress
)
EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateFrom, @dtmDateTo

DELETE FROM @temp_xml_table WHERE [fieldname] IN ('dtmDate')

SELECT @condition = '', @from = '', @to = '', @join = '', @datatype = ''

WHILE EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT @id = id, @fieldname = [fieldname], @condition = [condition], @from = [from], @to = [to], @join = [join], @datatype = [datatype] FROM @temp_xml_table
	SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@fieldname, @condition, @from, @to, @join, null, null, @datatype)
	
		IF (@fieldname = 'strName' OR @fieldname = 'strCustomerName' )
			SET @filter = REPLACE (@filter, '|^|', ''',''')
			SET @filter = REPLACE (@filter, ''',''''', '''')
			SET @filter = REPLACE (@filter, '=', 'IN (')
			SET @filter = @filter + ')'
			SET @filter = REPLACE (@filter, '))', ')')

	DELETE FROM @temp_xml_table WHERE id = @id

	IF EXISTS(SELECT 1 FROM @temp_xml_table)
	BEGIN
		SET @filter = @filter + ' AND '
	END
END
 
SET @query = CAST('' AS NVARCHAR(MAX)) + 
'SELECT * FROM
(SELECT strReferenceNumber		= I.strInvoiceNumber
	  , strTransactionType		= CASE WHEN I.strType = ''Service Charge'' THEN ''Service Charge'' ELSE I.strTransactionType END
	  , intEntityCustomerId		= I.intEntityCustomerId
	  , dtmDueDate				= CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Credit Memo'', ''Debit Memo'') THEN NULL ELSE I.dtmDueDate END
	  , dtmPostDate				= I.dtmPostDate
	  , intDaysDue				= DATEDIFF(DAY, I.dtmDueDate, '+ @strDateTo +')
	  , dblTotalAmount			= CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
	  , dblAmountPaid			= CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN ISNULL(I.dblPayment, 0) * -1 ELSE ISNULL(I.dblPayment, 0) END
	  , dblAmountDue			= CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN ISNULL(I.dblAmountDue, 0) * -1 ELSE ISNULL(I.dblAmountDue, 0) END
	  , dblPastDue				= CASE WHEN '+ @strDateTo +' > I.dtmDueDate AND I.strTransactionType IN (''Invoice'', ''Debit Memo'') THEN ISNULL(I.dblAmountDue, 0) ELSE 0 END
	  , dblMonthlyBudget		= ISNULL(dbo.fnARGetCustomerBudget(I.intEntityCustomerId, I.dtmDate), 0)
	  , strDescription			= CASE WHEN I.strType = ''Service Charge'' THEN ISNULL(ID.strSCInvoiceNumber, ID.strSCBudgetDescription) ELSE ID.strDescription END
	  , strItemNo				= ID.strItemNo
	  , dblQtyOrdered			= ID.dblQtyOrdered
	  , dblQtyShipped			= ID.dblQtyShipped
	  , dblTotal				= ID.dblTotal
	  , dblPrice				= ID.dblPrice
	  , intInvoiceId			= I.intInvoiceId
	  , strCustomerNumber		= C.strCustomerNumber
	  , strName					= C.strName
	  , strBOLNumber			= I.strBOLNumber
	  , dblCreditLimit			= C.dblCreditLimit
	  , strFullAddress			= C.strFullAddress
	  , strStatementFooterComment	= dbo.fnARGetDefaultComment(NULL, I.intEntityCustomerId, ''Statement Report'', NULL, ''Footer'', NULL)
	  , strCompanyName			= COMPANY.strCompanyName
	  , strCompanyAddress		= COMPANY.strCompanyAddress
	  , ysnStatementCreditLimit = C.ysnStatementCreditLimit
FROM tblARInvoice I WITH (NOLOCK)
INNER JOIN (
	SELECT intInvoiceId
		 , IC.*
		 , strSCInvoiceNumber
		 , strSCBudgetDescription
		 , dblQtyOrdered
		 , dblQtyShipped
		 , dblTotal
		 , dblPrice
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK) 
	LEFT JOIN (SELECT intItemId
					, strItemNo
					, strDescription
			   FROM dbo.tblICItem WITH (NOLOCK)
	) IC ON ID.intItemId = IC.intItemId
) ID ON I.intInvoiceId = ID.intInvoiceId	
INNER JOIN (
	SELECT intEntityId
		 , strName
		 , strCustomerNumber
		 , strFullAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, strBillToLocationName, strBillToAddress, strBillToCity, strBillToState, strBillToZipCode, strBillToCountry, NULL, 0)
		 , dblCreditLimit
		 , ysnStatementCreditLimit
	FROM vyuARCustomerSearch WITH (NOLOCK)
) C ON I.intEntityCustomerId = C.intEntityId
LEFT JOIN (
	SELECT intTermID
			, strTerm
	FROM dbo.tblSMTerm WITH (NOLOCK)
) T ON I.intTermId = T.intTermID
OUTER APPLY (
	SELECT TOP 1 strCompanyName
				, strCompanyAddress = dbo.[fnARFormatCustomerAddress](strPhone, '''', '''', strAddress, strCity, strState, strZip, strCountry, '''', NULL) 
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
WHERE I.ysnPosted = 1
    AND I.ysnCancelled = 0
	AND I.ysnPaid = 0
	AND ((I.strType = ''Service Charge'' AND I.ysnForgiven = 0) OR ((I.strType <> ''Service Charge'' AND I.ysnForgiven = 1) OR (I.strType <> ''Service Charge'' AND I.ysnForgiven = 0)))
	'+ @innerQuery +'
) MainQuery'

IF (ISNULL(@filter,'') != '')  
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

INSERT INTO @temp_statement_table
EXEC sp_executesql @query

DELETE FROM @temp_statement_table
WHERE strReferenceNumber IN (SELECT strInvoiceNumber FROM dbo.tblARInvoice WITH (NOLOCK) WHERE strType = 'CF Tran' AND strTransactionType NOT IN ('Debit Memo'))

SELECT strReferenceNumber			= STATEMENTREPORT.strReferenceNumber
	 , strTransactionType			= STATEMENTREPORT.strTransactionType
	 , intEntityCustomerId			= STATEMENTREPORT.intEntityCustomerId
	 , dtmDueDate					= STATEMENTREPORT.dtmDueDate
	 , dtmDate						= STATEMENTREPORT.dtmDate
	 , intDaysDue					= STATEMENTREPORT.intDaysDue
	 , dblTotalAmount				= STATEMENTREPORT.dblTotalAmount
	 , dblAmountPaid				= STATEMENTREPORT.dblAmountPaid
	 , dblAmountDue					= STATEMENTREPORT.dblAmountDue
	 , dblPastDue					= STATEMENTREPORT.dblPastDue
	 , dblMonthlyBudget				= STATEMENTREPORT.dblMonthlyBudget
	 , strDescription				= STATEMENTREPORT.strDescription
	 , strItemNo					= STATEMENTREPORT.strItemNo
	 , dblQtyOrdered				= STATEMENTREPORT.dblQtyOrdered
	 , dblQtyShipped				= STATEMENTREPORT.dblQtyShipped
	 , dblTotal						= STATEMENTREPORT.dblTotal
	 , dblPrice						= STATEMENTREPORT.dblPrice
	 , intInvoiceId					= STATEMENTREPORT.intInvoiceId
	 , strCustomerNumber			= STATEMENTREPORT.strCustomerNumber
	 , strName						= STATEMENTREPORT.strName
	 , strBOLNumber					= STATEMENTREPORT.strBOLNumber
	 , dblCreditLimit				= STATEMENTREPORT.dblCreditLimit
	 , dblCreditAvailable			= STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)
	 , dblFuture					= ISNULL(AGINGREPORT.dblFuture, 0)
	 , dbl0Days						= ISNULL(AGINGREPORT.dbl0Days, 0)
	 , dbl10Days					= ISNULL(AGINGREPORT.dbl10Days, 0)
	 , dbl30Days					= ISNULL(AGINGREPORT.dbl30Days, 0)
	 , dbl60Days					= ISNULL(AGINGREPORT.dbl60Days, 0)
	 , dbl90Days					= ISNULL(AGINGREPORT.dbl90Days, 0)
	 , dbl91Days					= ISNULL(AGINGREPORT.dbl91Days, 0)
	 , dblCredits					= ISNULL(AGINGREPORT.dblCredits, 0)
	 , dblPrepayments				= ISNULL(AGINGREPORT.dblPrepayments, 0)
	 , strFullAddress				= STATEMENTREPORT.strFullAddress
	 , strStatementFooterComment	= STATEMENTREPORT.strStatementFooterComment	  
	 , strCompanyName				= STATEMENTREPORT.strCompanyName
	 , strCompanyAddress			= STATEMENTREPORT.strCompanyAddress
	 , dtmAsOfDate					= @dtmDateTo
FROM @temp_statement_table AS STATEMENTREPORT
INNER JOIN tblARCustomerAgingStagingTable AS AGINGREPORT 
ON STATEMENTREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId