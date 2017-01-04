CREATE PROCEDURE [dbo].[uspARCustomerStatementReport]
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

DECLARE @temp_aging_table TABLE(	
	 [strCustomerName]			NVARCHAR(100)
	,[strEntityNo]				NVARCHAR(100)
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
	,[dblCredits]				NUMERIC(18,6)
	,[dblPrepayments]			NUMERIC(18,6)
	,[dblPrepaids]				NUMERIC(18,6)
	,[dtmAsOfDate]				DATETIME
	,[strSalespersonName]		NVARCHAR(100)
)

DECLARE @temp_statement_table TABLE(
	 [strReferenceNumber]	 NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strTransactionType]	 NVARCHAR(100)
	,[intEntityCustomerId]	 INT
	,[dtmDueDate]			 DATETIME
	,[dtmDate]				 DATETIME
	,[intDaysDue]			 INT
	,[dblTotalAmount]		 NUMERIC(18,6)
	,[dblAmountPaid]		 NUMERIC(18,6)
	,[dblAmountDue]			 NUMERIC(18,6)
	,[dblPastDue]			 NUMERIC(18,6)
	,[dblMonthlyBudget]		 NUMERIC(18,6)
	,[strCustomerNumber]	 NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strName]				 NVARCHAR(100)
	,[strBOLNumber]			 NVARCHAR(100)
	,[dblCreditLimit]		 NUMERIC(18,6)
	,[strFullAddress]		 NVARCHAR(MAX)
	,[strStatementFooterComment] NVARCHAR(MAX)	
	,[strCompanyName]		 NVARCHAR(MAX)
	,[strCompanyAddress]	 NVARCHAR(MAX)
)

DECLARE @temp_cf_table TABLE(
	 [intInvoiceId]				INT
	,[strInvoiceNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strInvoiceReportNumber]	NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[dtmInvoiceDate]			DATETIME
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

INSERT INTO @temp_aging_table
EXEC dbo.[uspARCustomerAgingAsOfDateReport] NULL, @dtmDateTo


DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmDate'

SELECT @condition = '', @from = '', @to = '', @join = '', @datatype = ''

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

SET @query = 'SELECT * FROM
(SELECT I.strInvoiceNumber AS strReferenceNumber
	 , strTransactionType = CASE WHEN I.strType = ''Service Charge'' THEN ''Service Charge'' ELSE I.strTransactionType END
	 , C.intEntityCustomerId
	 , dtmDueDate = CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Credit Memo'', ''Debit Memo'') THEN NULL ELSE I.dtmDueDate END
	 , I.dtmPostDate
	 , intDaysDue = DATEDIFF(DAY, I.[dtmDueDate], '+ @strDateTo +')
	 , dblTotalAmount = CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
	 , dblAmountPaid = CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN ISNULL(TOTALPAYMENT.dblPayment, 0) * -1 ELSE ISNULL(TOTALPAYMENT.dblPayment, 0) END
	 , dblAmountDue = CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END - ISNULL(TOTALPAYMENT.dblPayment, 0)
	 , dblPastDue = CASE WHEN '+ @strDateTo +' > I.[dtmDueDate] AND I.strTransactionType IN (''Invoice'', ''Debit Memo'')
						THEN I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0)
						ELSE 0
					END
	 , dblMonthlyBudget = ISNULL([dbo].[fnARGetCustomerBudget](C.intEntityCustomerId, I.dtmDate), 0)
	 , C.strCustomerNumber
	 , C.strName
	 , I.strBOLNumber
	 , C.dblCreditLimit
	 , strFullAddress = [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, NULL)
	 , strStatementFooterComment = [dbo].fnARGetFooterComment(I.intCompanyLocationId, I.intEntityCustomerId, ''Statement Footer'')	 
	 , strCompanyName = (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
	 , strCompanyAddress = (SELECT TOP 1 dbo.[fnARFormatCustomerAddress]('''', '''', '''', strAddress, strCity, strState, strZip, strCountry, '''', NULL) FROM tblSMCompanySetup)
FROM vyuARCustomer C
	LEFT JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1
	LEFT JOIN tblARInvoice I ON I.intEntityCustomerId = C.intEntityCustomerId
		AND I.ysnPosted  = 1		
		AND ((I.strType = ''Service Charge'' AND I.ysnForgiven = 0) OR ((I.strType <> ''Service Charge'' AND I.ysnForgiven = 1) OR (I.strType <> ''Service Charge'' AND I.ysnForgiven = 0)))		
		AND (CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= '+ @strDateTo +' 
		AND (I.ysnPaid = 0
			 OR (I.ysnPaid = 1 AND I.intInvoiceId IN (SELECT intInvoiceId FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) > '+ @strDateTo +'))))
		AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN (''AR Account'', ''Customer Prepayments''))	
	LEFT JOIN tblARPayment PCREDITS ON I.intPaymentId = PCREDITS.intPaymentId AND PCREDITS.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), PCREDITS.dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
				, intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND P.ysnInvoicePrepayment = 0 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= '+ @strDateTo +'
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	LEFT JOIN tblSMTerm T ON I.intTermId = T.intTermID	
) MainQuery'

IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

INSERT INTO @temp_statement_table
EXEC sp_executesql @query

INSERT INTO @temp_cf_table
(
	intInvoiceId
	, strInvoiceNumber
	, strInvoiceReportNumber
	, dtmInvoiceDate
)
SELECT 
	  cfTable.intInvoiceId
	, cfTable.strInvoiceNumber
	, cfTable.strInvoiceReportNumber
	, cfTable.dtmInvoiceDate
FROM 
	@temp_statement_table statementTable
INNER JOIN
	(SELECT 
		 ARI.intInvoiceId 
		,ARI.strInvoiceNumber
		,CFT.strInvoiceReportNumber
		,CFT.dtmInvoiceDate
	FROM 
		tblARInvoice ARI
	INNER JOIN
		(SELECT 
			intInvoiceId
			, strInvoiceReportNumber
			, dtmInvoiceDate 
		FROM 
			tblCFTransaction
		WHERE ISNULL(strInvoiceReportNumber,'') <> '') CFT ON ARI.intInvoiceId = CFT.intInvoiceId
	) cfTable ON statementTable.strReferenceNumber = cfTable.strInvoiceNumber

MERGE INTO tblARStatementOfAccount AS Target
USING (SELECT strCustomerNumber, @dtmDateTo, SUM(ISNULL(dblAmountDue, 0))
FROM @temp_statement_table GROUP BY strCustomerNumber
)
AS Source (strCustomerNumber, dtmLastStatementDate, dblLastStatement)
ON Target.strEntityNo = Source.strCustomerNumber

WHEN MATCHED THEN
UPDATE SET dtmLastStatementDate = Source.dtmLastStatementDate, dblLastStatement = Source.dblLastStatement

WHEN NOT MATCHED BY TARGET THEN
INSERT (strEntityNo, dtmLastStatementDate, dblLastStatement)
VALUES (strCustomerNumber, dtmLastStatementDate, dblLastStatement);

--- Without CF Report
SELECT STATEMENTREPORT.strReferenceNumber
      ,STATEMENTREPORT.strTransactionType
	  ,STATEMENTREPORT.dtmDueDate
	  ,STATEMENTREPORT.dtmDate
	  ,STATEMENTREPORT.intDaysDue
	  ,STATEMENTREPORT.dblTotalAmount
	  ,STATEMENTREPORT.dblAmountPaid
	  ,STATEMENTREPORT.dblAmountDue
	  ,STATEMENTREPORT.dblPastDue
	  ,STATEMENTREPORT.dblMonthlyBudget
	  ,STATEMENTREPORT.strCustomerNumber
	  ,STATEMENTREPORT.strName
	  ,STATEMENTREPORT.strBOLNumber
	  ,STATEMENTREPORT.dblCreditLimit
	  ,dblCreditAvailable							= STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)
	  ,dbl0Days										= ISNULL(AGINGREPORT.dbl0Days, 0)
	  ,dbl10Days									= ISNULL(AGINGREPORT.dbl10Days, 0)
	  ,dbl30Days									= ISNULL(AGINGREPORT.dbl30Days, 0)
	  ,dbl60Days									= ISNULL(AGINGREPORT.dbl60Days, 0)
	  ,dbl90Days									= ISNULL(AGINGREPORT.dbl90Days, 0)
	  ,dbl91Days									= ISNULL(AGINGREPORT.dbl91Days, 0)
	  ,dblCredits									= ISNULL(AGINGREPORT.dblCredits, 0)
	  ,dblPrepayments								= ISNULL(AGINGREPORT.dblPrepayments, 0)
	  ,STATEMENTREPORT.strFullAddress
	  ,STATEMENTREPORT.strStatementFooterComment	  
	  ,STATEMENTREPORT.strCompanyName
	  ,STATEMENTREPORT.strCompanyAddress	  
	  ,dtmAsOfDate									= @dtmDateTo
	  ,blbLogo										= dbo.fnSMGetCompanyLogo('Header')
FROM @temp_statement_table AS STATEMENTREPORT
INNER JOIN @temp_aging_table AS AGINGREPORT
	ON STATEMENTREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
INNER JOIN tblARCustomer CUSTOMER 
	ON STATEMENTREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId
WHERE AGINGREPORT.dblTotalAR <> 0
AND (ISNULL(CUSTOMER.strStatementFormat, '') = '' OR CUSTOMER.strStatementFormat = 'Open Item')
AND strReferenceNumber NOT IN (SELECT strInvoiceNumber FROM @temp_cf_table)

UNION ALL

--- With CF Report
SELECT strReferenceNumber							= CFReportTable.strInvoiceReportNumber
      ,STATEMENTREPORT.strTransactionType
	  ,dtmDueDate									= CFReportTable.dtmInvoiceDate
	  ,dtmDate										= CFReportTable.dtmInvoiceDate
	  ,intDaysDue									= (SELECT TOP 1 intDaysDue FROM @temp_statement_table ORDER BY intDaysDue DESC)
	  ,dblTotalAmount								= SUM(STATEMENTREPORT.dblTotalAmount)
	  ,dblAmountPaid								= SUM(STATEMENTREPORT.dblAmountPaid)
	  ,dblAmountDue									= SUM(STATEMENTREPORT.dblAmountDue)
	  ,dblPastDue									= SUM(STATEMENTREPORT.dblPastDue)
	  ,dblMonthlyBudget								= SUM(STATEMENTREPORT.dblMonthlyBudget)
	  ,STATEMENTREPORT.strCustomerNumber
	  ,STATEMENTREPORT.strName
	  ,STATEMENTREPORT.strBOLNumber
	  ,STATEMENTREPORT.dblCreditLimit
	  ,dblCreditAvailable							= STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)
	  ,dbl0Days										= SUM(ISNULL(AGINGREPORT.dbl0Days, 0))
	  ,dbl10Days									= SUM(ISNULL(AGINGREPORT.dbl10Days, 0))
	  ,dbl30Days									= SUM(ISNULL(AGINGREPORT.dbl30Days, 0))
	  ,dbl60Days									= SUM(ISNULL(AGINGREPORT.dbl60Days, 0))
	  ,dbl90Days									= SUM(ISNULL(AGINGREPORT.dbl90Days, 0))
	  ,dbl91Days									= SUM(ISNULL(AGINGREPORT.dbl91Days, 0))
	  ,dblCredits									= SUM(ISNULL(AGINGREPORT.dblCredits, 0))
	  ,dblPrepayments								= SUM(ISNULL(AGINGREPORT.dblPrepayments, 0))
	  ,STATEMENTREPORT.strFullAddress
	  ,STATEMENTREPORT.strStatementFooterComment	  
	  ,STATEMENTREPORT.strCompanyName
	  ,STATEMENTREPORT.strCompanyAddress	  
	  ,dtmAsOfDate									= @dtmDateTo
	  ,blbLogo										= dbo.fnSMGetCompanyLogo('Header')
FROM @temp_statement_table AS STATEMENTREPORT
INNER JOIN @temp_aging_table AS AGINGREPORT
	ON STATEMENTREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
INNER JOIN tblARCustomer CUSTOMER 
	ON STATEMENTREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId
INNER JOIN (SELECT 
				intInvoiceId
				, strInvoiceNumber
				, strInvoiceReportNumber
				, dtmInvoiceDate 
			FROM 
				@temp_cf_table) CFReportTable ON STATEMENTREPORT.strReferenceNumber = CFReportTable.strInvoiceNumber
WHERE AGINGREPORT.dblTotalAR <> 0
AND (ISNULL(CUSTOMER.strStatementFormat, '') = '' OR CUSTOMER.strStatementFormat = 'Open Item')
AND strReferenceNumber IN (SELECT strInvoiceNumber FROM @temp_cf_table)
GROUP BY CFReportTable.strInvoiceReportNumber
      ,STATEMENTREPORT.strTransactionType
	  ,CFReportTable.dtmInvoiceDate
	  ,STATEMENTREPORT.strCustomerNumber
	  ,STATEMENTREPORT.strName
	  ,STATEMENTREPORT.strBOLNumber
	  ,STATEMENTREPORT.dblCreditLimit
	  ,AGINGREPORT.dblTotalAR
	  ,STATEMENTREPORT.strFullAddress
	  ,STATEMENTREPORT.strStatementFooterComment	  
	  ,STATEMENTREPORT.strCompanyName
	  ,STATEMENTREPORT.strCompanyAddress