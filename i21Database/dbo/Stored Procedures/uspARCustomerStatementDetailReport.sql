﻿CREATE PROCEDURE [dbo].[uspARCustomerStatementDetailReport]
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
DECLARE  @dtmDateTo					AS DATETIME
		,@dtmDateFrom				AS DATETIME
		,@strDateTo					AS NVARCHAR(50)
		,@strDateFrom				AS NVARCHAR(50)
		,@xmlDocumentId				AS INT
		,@intEntityUserId			AS INT
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
		,@strCustomerIds			AS NVARCHAR(MAX)
		,@ysnEmailOnly				AS BIT
		
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

IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL)
BEGIN
    DROP TABLE #CUSTOMERS
END

SELECT intEntityCustomerId	= intEntityId
	 , strCustomerNumber	= CAST(strCustomerNumber COLLATE Latin1_General_CI_AS AS NVARCHAR(200))
	 , strCustomerName		= CAST('' COLLATE Latin1_General_CI_AS AS NVARCHAR(200))
	 , dblCreditLimit
	 , dblARBalance
INTO #CUSTOMERS
FROM tblARCustomer
WHERE 1 = 0

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
WHERE	[fieldname] = 'dtmDate'

SELECT @strCustomerName = [from]
FROM @temp_xml_table
WHERE [fieldname] IN ('strName', 'strCustomerName')

SELECT @strCustomerIds = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strCustomerIds'

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

IF UPPER(@condition) = UPPER('As Of')
	BEGIN		
		SET @innerQuery = 'AND I.dtmPostDate <= '+ @strDateTo +''
	END
ELSE
	BEGIN
		SET @innerQuery = 'AND I.dtmPostDate BETWEEN '+ @strDateFrom +' AND '+ @strDateTo+''
	END

IF ISNULL(@strCustomerName, '') <> ''
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT TOP 1 intEntityCustomerId	= C.intEntityId 
				   , strCustomerNumber		= C.strCustomerNumber
				   , strCustomerName		= EC.strName
				   , dblCreditLimit         = C.dblCreditLimit
				   , dblARBalance           = C.dblARBalance        
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
					, strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE strName = @strCustomerName
		) EC ON C.intEntityId = EC.intEntityId
		WHERE C.ysnActive = 1
	END
ELSE IF ISNULL(@strCustomerIds, '') <> ''
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT intEntityCustomerId	= C.intEntityId 
			 , strCustomerNumber	= C.strCustomerNumber
			 , strCustomerName		= EC.strName
			 , dblCreditLimit		= C.dblCreditLimit
			 , dblARBalance			= C.dblARBalance
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intID
			FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIds)
		) CUSTOMERS ON C.intEntityId = CUSTOMERS.intID
		INNER JOIN (
			SELECT intEntityId
				 , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
		) EC ON C.intEntityId = EC.intEntityId
		WHERE C.ysnActive = 1
	END
ELSE
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT intEntityCustomerId	= C.intEntityId 
			 , strCustomerNumber	= C.strCustomerNumber
			 , strCustomerName		= EC.strName
			 , dblCreditLimit		= C.dblCreditLimit
			 , dblARBalance			= C.dblARBalance
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
				 , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
		) EC ON C.intEntityId = EC.intEntityId
		WHERE C.ysnActive = 1
	END

SELECT @ysnEmailOnly = [from] 
FROM @temp_xml_table
WHERE [fieldname] = 'ysnHasEmailSetup'

IF @ysnEmailOnly IS NOT NULL
	BEGIN
		DELETE C
		FROM #CUSTOMERS C
		OUTER APPLY (
			SELECT intEmailSetupCount = COUNT(*) 
			FROM dbo.vyuARCustomerContacts CC WITH (NOLOCK)
			WHERE CC.intCustomerEntityId = C.intEntityCustomerId 
				AND ISNULL(CC.strEmail, '') <> '' 
				AND CC.strEmailDistributionOption LIKE '%Statements%'
		) EMAILSETUP
		WHERE CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END <> @ysnEmailOnly
	END

DELETE FROM tblARCustomerAgingStagingTable WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Summary'
INSERT INTO tblARCustomerAgingStagingTable (
	   strCustomerName
	 , strCustomerNumber
	 , strCustomerInfo
	 , intEntityCustomerId
	 , intEntityUserId
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
	 , strAgingType
)
EXEC dbo.[uspARCustomerAgingAsOfDateReport] @strCustomerName = @strCustomerName, @intEntityUserId = @intEntityUserId
 
SET @query = 'SELECT * FROM
(SELECT I.strInvoiceNumber AS strReferenceNumber
		, strTransactionType = CASE WHEN I.strType = ''Service Charge'' THEN ''Service Charge'' ELSE I.strTransactionType END
		, I.intEntityCustomerId
		, dtmDueDate = CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Credit Memo'', ''Debit Memo'') THEN NULL ELSE I.dtmDueDate END
		, I.dtmPostDate
		, intDaysDue = DATEDIFF(DAY, I.[dtmDueDate], '+ @strDateTo +')
		, dblTotalAmount = CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
		, dblAmountPaid = CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN ISNULL(I.dblPayment, 0) * -1 ELSE ISNULL(I.dblPayment, 0) END
		, dblAmountDue = CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN ISNULL(I.dblAmountDue, 0) * -1 ELSE ISNULL(I.dblAmountDue, 0) END
		, dblPastDue = CASE WHEN '+ @strDateTo +' > I.[dtmDueDate] AND I.strTransactionType IN (''Invoice'', ''Debit Memo'')
						THEN ISNULL(I.dblAmountDue, 0)
						ELSE 0
					END
		, dblMonthlyBudget = ISNULL([dbo].[fnARGetCustomerBudget](I.intEntityCustomerId, I.dtmDate), 0)
		, strDescription = CASE WHEN I.strType = ''Service Charge'' THEN ISNULL(ID.strSCInvoiceNumber, ID.strSCBudgetDescription) ELSE IC.strDescription END
		, IC.strItemNo
		, ID.dblQtyOrdered
		, ID.dblQtyShipped
		, ID.dblTotal
		, ID.dblPrice
		, I.intInvoiceId
		, C.strCustomerNumber
		, C.strName
		, I.strBOLNumber
		, C.dblCreditLimit
		, strFullAddress = [dbo].fnARFormatCustomerAddress(NULL, NULL, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, 0)
		, strStatementFooterComment = dbo.fnARGetDefaultComment(I.intCompanyLocationId, I.intEntityCustomerId, ''Statement Report'', NULL, ''Footer'', NULL, 1)
		, strCompanyName = (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
		, strCompanyAddress = (SELECT TOP 1 dbo.[fnARFormatCustomerAddress]('''', '''', '''', strAddress, strCity, strState, strZip, strCountry, '''', 0) FROM tblSMCompanySetup)
		, C.ysnStatementCreditLimit
FROM tblARInvoice I
	INNER JOIN (tblARInvoiceDetail ID 
		LEFT JOIN tblICItem IC ON ID.intItemId = IC.intItemId) ON I.intInvoiceId = ID.intInvoiceId	
	INNER JOIN (vyuARCustomerSearch C INNER JOIN #CUSTOMERS CC ON C.intEntityCustomerId = CC.intEntityCustomerId) ON I.intEntityCustomerId = C.intEntityCustomerId
	LEFT JOIN tblSMTerm T ON I.intTermId = T.intTermID	
WHERE I.ysnPosted = 1
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
	 , ysnStatementCreditLimit		= STATEMENTREPORT.ysnStatementCreditLimit
FROM @temp_statement_table AS STATEMENTREPORT
INNER JOIN tblARCustomerAgingStagingTable AS AGINGREPORT 
ON STATEMENTREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
 AND AGINGREPORT.intEntityUserId = @intEntityUserId
 AND AGINGREPORT.strAgingType = 'Summary'
