﻿CREATE PROCEDURE [dbo].[uspARCustomerStatementPaymentActivityReport]
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
		,@intMaxInvoiceId			AS INT 
		
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
     [strCustomerName]          NVARCHAR(100)
    ,[strEntityNo]              NVARCHAR(100)
    ,[intEntityCustomerId]      INT
    ,[dblCreditLimit]			NUMERIC(18,6)
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

DECLARE @temp_statement_table TABLE(
	 [strReferenceNumber]		NVARCHAR(100) COLLATE Latin1_General_CI_AS
    ,[intEntityCustomerId]		INT
    ,[strCustomerNumber]		NVARCHAR(100) COLLATE Latin1_General_CI_AS
    ,[strCustomerName]			NVARCHAR(100)
    ,[dblCreditLimit]			NUMERIC(18,6)
    ,[intInvoiceId]				INT
    ,[strInvoiceNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
    ,[strBOLNumber]				NVARCHAR(100)
    ,[dtmDate]					DATETIME
    ,[dtmDueDate]				DATETIME
    ,[dtmShipDate]				DATETIME
    ,[dblInvoiceTotal]			NUMERIC(18,6)
    ,[intPaymentId]				INT
    ,[strRecordNumber]			NVARCHAR(100)
    ,[strPaymentInfo]			NVARCHAR(100)
    ,[dtmDatePaid]				DATETIME
    ,[dblPayment]				NUMERIC(18,6)
    ,[dblBalance]				NUMERIC(18,6)
    ,[strSalespersonName]		NVARCHAR(100)    
    ,[strFullAddress]			NVARCHAR(MAX)
    ,[strCompanyName]			NVARCHAR(MAX)
    ,[strCompanyAddress]		NVARCHAR(MAX)
)

DECLARE @temp_cf_table TABLE(
	 [intInvoiceId]				INT
	,[strInvoiceNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strInvoiceReportNumber]	NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[dtmInvoiceDate]			DATETIME
)


DECLARE @temp_cfinvoices_statement TABLE(
	 [strReferenceNumber]		NVARCHAR(100) COLLATE Latin1_General_CI_AS
    ,[intEntityCustomerId]		INT
    ,[strCustomerNumber]		NVARCHAR(100) COLLATE Latin1_General_CI_AS
    ,[strCustomerName]			NVARCHAR(100)
    ,[dblCreditLimit]			NUMERIC(18,6)
    ,[intInvoiceId]				INT
    ,[strInvoiceNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
    ,[strBOLNumber]				NVARCHAR(100)
    ,[dtmDate]					DATETIME
    ,[dtmDueDate]				DATETIME
    ,[dtmShipDate]				DATETIME
    ,[dblInvoiceTotal]			NUMERIC(18,6)
    ,[intPaymentId]				INT
    ,[strRecordNumber]			NVARCHAR(100)
    ,[strPaymentInfo]			NVARCHAR(100)
    ,[dtmDatePaid]				DATETIME
    ,[dblPayment]				NUMERIC(18,6)
    ,[dblBalance]				NUMERIC(18,6)
    ,[strSalespersonName]		NVARCHAR(100)    
    ,[strFullAddress]			NVARCHAR(MAX)
    ,[strCompanyName]			NVARCHAR(MAX)
    ,[strCompanyAddress]		NVARCHAR(MAX)
    ,[dblCreditAvailable] 		NUMERIC(18,6)
    ,[dbl0Days]					NUMERIC(18,6)
    ,[dbl10Days]				NUMERIC(18,6)
    ,[dbl30Days]				NUMERIC(18,6)
    ,[dbl60Days]				NUMERIC(18,6)
    ,[dbl90Days]				NUMERIC(18,6)
    ,[dbl91Days]				NUMERIC(18,6)
    ,[dblCredits]				NUMERIC(18,6)
	,[dblPrepayments]			NUMERIC(18,6)
    ,[dtmAsOfDate]				DATETIME
    ,[blbLogo]					VARBINARY (MAX)
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

SET @strDateTo = ''''+ CONVERT(NVARCHAR(50),@dtmDateTo, 110) + ''''
SET @strDateFrom = ''''+ CONVERT(NVARCHAR(50),@dtmDateFrom, 110) + ''''

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST(-53690 AS DATETIME)
	
DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmAsOfDate'

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

INSERT INTO @temp_aging_table
EXEC dbo.[uspARCustomerAgingAsOfDateReport] NULL, @dtmDateTo

SET @query = 'SELECT * FROM
(SELECT strReferenceNumber	= I.strInvoiceNumber
	  , intEntityCustomerId	= C.intEntityCustomerId
	  , C.strCustomerNumber
	  , strCustomerName		= C.strName
	  , C.dblCreditLimit
	  , I.intInvoiceId
	  , I.strInvoiceNumber
	  , strBOLNumber		= ''BOL# '' + I.strBOLNumber
      , I.dtmDate
      , I.dtmDueDate
	  , I.dtmShipDate
	  , dblInvoiceTotal		= CASE WHEN I.strTransactionType IN (''Credit Memo'', ''Overpayment'', ''Customer Prepayment'') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END
	  , intPaymentId		= ISNULL(P.intPaymentId, PCREDITS.intPaymentId)
	  , strRecordNumber		= ISNULL(P.strRecordNumber, PCREDITS.strRecordNumber)
	  , strPaymentInfo	    = ''PAYMENT REF: '' + P.strPaymentInfo
	  , dtmDatePaid			= ISNULL(P.dtmDatePaid, PCREDITS.dtmDatePaid)
	  , dblPayment			= ISNULL(PD.dblPayment, 0) + ISNULL(PD.dblDiscount, 0) - ISNULL(PD.dblInterest, 0)
	  , dblBalance			= CASE WHEN I.strTransactionType IN (''Credit Memo'', ''Overpayment'', ''Customer Prepayment'') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END - ISNULL(TOTALPAYMENT.dblPayment, 0)
	  , strSalespersonName  = ESP.strName
	  , strFullAddress		= [dbo].fnARFormatCustomerAddress('''', '''', C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, NULL)
	  , strCompanyName		= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
	  , strCompanyAddress	= (SELECT TOP 1 dbo.[fnARFormatCustomerAddress]('''', '''', '''', strAddress, strCity, strState, strZip, strCountry, '''', NULL) FROM tblSMCompanySetup)
FROM vyuARCustomer C
	LEFT JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1
	LEFT JOIN tblARInvoice I ON I.intEntityCustomerId = C.intEntityCustomerId
		AND I.ysnPosted  = 1		
		AND ((I.strType = ''Service Charge'' AND I.ysnForgiven = 0) OR ((I.strType <> ''Service Charge'' AND I.ysnForgiven = 1) OR (I.strType <> ''Service Charge'' AND I.ysnForgiven = 0)))		
		AND (CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= '+ @strDateTo +' 
			AND ((I.ysnPaid = 0 OR I.intInvoiceId IN (SELECT intInvoiceId FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'))
			 OR (I.ysnPaid = 1 AND I.intInvoiceId IN (SELECT intInvoiceId FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) > '+ @strDateTo +'))))
		AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN (''AR Account'', ''Customer Prepayments''))			
	LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND P.ysnInvoicePrepayment = 0 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= '+ @strDateTo +') ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN tblARPayment PCREDITS ON I.intPaymentId = PCREDITS.intPaymentId AND PCREDITS.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), PCREDITS.dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND P.ysnInvoicePrepayment = 0 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= '+ @strDateTo +'
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	LEFT JOIN tblSMTerm T ON T.intTermID = I.intTermId	
	LEFT JOIN tblEMEntity ESP ON C.intSalespersonId = ESP.intEntityId	
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
) MainQuery'

IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE dblBalance IS NOT NULL AND ' + @filter
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
		WHERE 
			ISNULL(strInvoiceReportNumber,'') <> '') CFT ON ARI.intInvoiceId = CFT.intInvoiceId
	) cfTable ON statementTable.strReferenceNumber = cfTable.strInvoiceNumber

MERGE INTO tblARStatementOfAccount AS Target
USING (SELECT strCustomerNumber, @dtmDateTo, SUM(ISNULL(dblBalance, 0))
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
SELECT 
	 [STATEMENTREPORT].[strReferenceNumber]		
    ,[STATEMENTREPORT].[intEntityCustomerId]		
    ,[STATEMENTREPORT].[strCustomerNumber]		
    ,[STATEMENTREPORT].[strCustomerName]			
    ,[STATEMENTREPORT].[dblCreditLimit]			
    ,[STATEMENTREPORT].[intInvoiceId]				
    ,[STATEMENTREPORT].[strInvoiceNumber]			
    ,[STATEMENTREPORT].[strBOLNumber]				
    ,[STATEMENTREPORT].[dtmDate]					
    ,[STATEMENTREPORT].[dtmDueDate]				
    ,[STATEMENTREPORT].[dtmShipDate]				
    ,[STATEMENTREPORT].[dblInvoiceTotal]			
    ,[STATEMENTREPORT].[intPaymentId]				
    ,[STATEMENTREPORT].[strRecordNumber]			
    ,[STATEMENTREPORT].[strPaymentInfo]			
    ,[STATEMENTREPORT].[dtmDatePaid]				
    ,[STATEMENTREPORT].[dblPayment]				
    ,[STATEMENTREPORT].[dblBalance]				
    ,[STATEMENTREPORT].[strSalespersonName]		    
    ,[STATEMENTREPORT].[strFullAddress]			
    ,[STATEMENTREPORT].[strCompanyName]			
    ,[STATEMENTREPORT].[strCompanyAddress]			
    ,dblCreditAvailable							= STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)
    ,dbl0Days									= ISNULL(AGINGREPORT.dbl0Days, 0)
    ,dbl10Days									= ISNULL(AGINGREPORT.dbl10Days, 0)
    ,dbl30Days									= ISNULL(AGINGREPORT.dbl30Days, 0)
    ,dbl60Days									= ISNULL(AGINGREPORT.dbl60Days, 0)
    ,dbl90Days									= ISNULL(AGINGREPORT.dbl90Days, 0)
    ,dbl91Days									= ISNULL(AGINGREPORT.dbl91Days, 0)
    ,dblCredits									= ISNULL(AGINGREPORT.dblCredits, 0)
	,dblPrepayments								= ISNULL(AGINGREPORT.dblPrepayments, 0)
    ,dtmAsOfDate								= @dtmDateTo
    ,blbLogo									= dbo.fnSMGetCompanyLogo('Header')
FROM 
	@temp_statement_table AS STATEMENTREPORT
INNER JOIN (SELECT intEntityCustomerId
					,dblTotalAR
					,dbl0Days
					,dbl10Days
					,dbl30Days
					,dbl60Days
					,dbl90Days
					,dbl91Days
					,dblCredits
					,dblPrepayments
			FROM 
				@temp_aging_table) AS AGINGREPORT ON STATEMENTREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
INNER JOIN (SELECT intEntityCustomerId			
			FROM 
				tblARCustomer
			WHERE 
				strStatementFormat = 'Payment Activity') CUSTOMER ON STATEMENTREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId
WHERE 
	AGINGREPORT.dblTotalAR <> 0
	AND strReferenceNumber NOT IN (SELECT strInvoiceNumber FROM @temp_cf_table)

UNION ALL

--- With CF Report
SELECT 	 
	 [strReferenceNumber]							= CFReportTable.strInvoiceReportNumber
	,[STATEMENTREPORT].[intEntityCustomerId]		
	,[STATEMENTREPORT].[strCustomerNumber]		
	,[STATEMENTREPORT].[strCustomerName]			
	,[STATEMENTREPORT].[dblCreditLimit]				
	,[intInvoiceId]									= RIGHT(CFReportTable.strInvoiceReportNumber, (CHARINDEX('-',REVERSE(CFReportTable.strInvoiceReportNumber),0))-1)  
	,[strInvoiceNumber]								= CFReportTable.strInvoiceReportNumber
	,[STATEMENTREPORT].[strBOLNumber]				
	,[dtmDate]										= CFReportTable.dtmInvoiceDate				
	,[dtmDueDate]									= CFReportTable.dtmInvoiceDate
	,[dtmShipDate]									= CFReportTable.dtmInvoiceDate
	,[dblInvoiceTotal]								= SUM(ISNULL([STATEMENTREPORT].[dblInvoiceTotal], 0))
	,[intPaymentId]									= 0	
	,[strRecordNumber]								= NULL
	,[strPaymentInfo]								= NULL	
	,[dtmDatePaid]									= NULL	
	,[dblPayment]									= 0
	,[dblBalance]									= SUM(ISNULL([STATEMENTREPORT].[dblBalance], 0))
	,[STATEMENTREPORT].[strSalespersonName]		
	,[STATEMENTREPORT].[strFullAddress]			
	,[STATEMENTREPORT].[strCompanyName]			
	,[STATEMENTREPORT].[strCompanyAddress]		
    ,dblCreditAvailable								= STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)
    ,dbl0Days										= SUM(ISNULL(AGINGREPORT.dbl0Days, 0))
    ,dbl10Days										= SUM(ISNULL(AGINGREPORT.dbl10Days, 0))
    ,dbl30Days										= SUM(ISNULL(AGINGREPORT.dbl30Days, 0))
    ,dbl60Days										= SUM(ISNULL(AGINGREPORT.dbl60Days, 0))
    ,dbl90Days										= SUM(ISNULL(AGINGREPORT.dbl90Days, 0))
    ,dbl91Days										= SUM(ISNULL(AGINGREPORT.dbl91Days, 0))
    ,dblCredits										= SUM(ISNULL(AGINGREPORT.dblCredits, 0))
	,dblPrepayments									= SUM(ISNULL(AGINGREPORT.dblPrepayments, 0))
    ,dtmAsOfDate									= @dtmDateTo
    ,blbLogo										= dbo.fnSMGetCompanyLogo('Header')
FROM 
	@temp_statement_table AS STATEMENTREPORT
INNER JOIN (SELECT intEntityCustomerId
					,dblTotalAR
					,dbl0Days
					,dbl10Days
					,dbl30Days
					,dbl60Days
					,dbl90Days
					,dbl91Days
					,dblCredits
					,dblPrepayments
			FROM 
				@temp_aging_table) AS AGINGREPORT ON STATEMENTREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
INNER JOIN (SELECT 
				intEntityCustomerId
			FROM 
				tblARCustomer
			WHERE 
				strStatementFormat = 'Payment Activity') CUSTOMER ON STATEMENTREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId
INNER JOIN (SELECT 
				intInvoiceId
				, strInvoiceNumber
				, strInvoiceReportNumber
				, dtmInvoiceDate 				 			
			FROM 
				@temp_cf_table) CFReportTable ON STATEMENTREPORT.strReferenceNumber = CFReportTable.strInvoiceNumber
WHERE 
	AGINGREPORT.dblTotalAR <> 0
	AND strReferenceNumber IN (SELECT strInvoiceNumber FROM @temp_cf_table)
GROUP BY CFReportTable.strInvoiceReportNumber		
		,STATEMENTREPORT.intEntityCustomerId
		,STATEMENTREPORT.strCustomerNumber
		,STATEMENTREPORT.strCustomerName
		,STATEMENTREPORT.dblCreditLimit 
		,STATEMENTREPORT.strBOLNumber	
		,CFReportTable.dtmInvoiceDate				
		,STATEMENTREPORT.strSalespersonName
		,STATEMENTREPORT.strFullAddress
		,STATEMENTREPORT.strCompanyName
		,STATEMENTREPORT.strCompanyAddress
		,AGINGREPORT.dblTotalAR  