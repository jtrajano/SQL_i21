CREATE PROCEDURE [dbo].[uspARCustomerStatementBalanceForwardReport]
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
		,@strLocationName			AS NVARCHAR(100)
		,@ysnPrintZeroBalance		AS BIT
		,@ysnPrintCreditBalance		AS BIT
		,@ysnIncludeBudget			AS BIT
		,@ysnPrintOnlyPastDue		AS BIT
		,@xmlDocumentId				AS INT
		,@query						AS NVARCHAR(MAX)
		,@queryBudget               AS NVARCHAR(MAX)
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
		,@ysnReportDetail			AS BIT				= 0
		
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
    ,[strSalespersonName]		NVARCHAR(100)
	,[strSourceTransaction]		NVARCHAR(100)
)

DECLARE @temp_balanceforward_table TABLE(
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
    ,[strSalespersonName]		NVARCHAR(100)
	,[strSourceTransaction]		NVARCHAR(100)
)

DECLARE @temp_statement_table TABLE(
     [intEntityCustomerId]  INT
    ,[strCustomerNumber]	NVARCHAR(100) COLLATE Latin1_General_CI_AS
    ,[strCustomerName]      NVARCHAR(100)
    ,[dblCreditLimit]       NUMERIC(18,6)
    ,[intInvoiceId]         INT
    ,[strInvoiceNumber]     NVARCHAR(100) COLLATE Latin1_General_CI_AS
    ,[strBOLNumber]         NVARCHAR(100)
    ,[dtmDate]              DATETIME
    ,[dtmDueDate]           DATETIME
    ,[dtmShipDate]          DATETIME
    ,[dblInvoiceTotal]      NUMERIC(18,6)
    ,[intPaymentId]         INT
    ,[strRecordNumber]      NVARCHAR(100)
	,[strTransactionType]	NVARCHAR(100)
    ,[strPaymentInfo]       NVARCHAR(100)
    ,[dtmDatePaid]          DATETIME
    ,[dblPayment]           NUMERIC(18,6)
    ,[dblBalance]           NUMERIC(18,6)	
    ,[strSalespersonName]   NVARCHAR(100)
	,[strAccountStatusCode] NVARCHAR(50)	
	,[strLocationName]      NVARCHAR(100)
    ,[strFullAddress]       NVARCHAR(MAX)
    ,[strCompanyName]       NVARCHAR(MAX)
    ,[strCompanyAddress]    NVARCHAR(MAX)
	,[dblARBalance]         NUMERIC(18,6)
)

DECLARE @temp_cf_table TABLE(
	 [intInvoiceId]				INT
	,[strInvoiceNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strInvoiceReportNumber]	NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[dtmInvoiceDate]			DATETIME
)

IF OBJECT_ID('tempdb..#SelectedCustomer') IS NOT NULL DROP TABLE #SelectedCustomer
CREATE TABLE #SelectedCustomer (	
	strCustomerName	VARCHAR(MAX)	COLLATE Latin1_General_CI_AS 
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

SET @strDateTo = ''''+ CONVERT(NVARCHAR(50),@dtmDateTo, 110) + ''''
SET @strDateFrom = ''''+ CONVERT(NVARCHAR(50),@dtmDateFrom, 110) + ''''

SELECT @strCustomerName = [from]
FROM @temp_xml_table
WHERE [fieldname] IN ('strName', 'strCustomerName')

SELECT @ysnReportDetail = [from]
FROM @temp_xml_table
WHERE [fieldname] IN ('ysnReportDetail')

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST(-53690 AS DATETIME)
	
DELETE FROM @temp_xml_table WHERE [fieldname] IN ('dtmAsOfDate', 'dtmDate', 'strStatementFormat', 'ysnPrintZeroBalance', 'ysnPrintCreditBalance', 'ysnIncludeBudget', 'ysnPrintOnlyPastDue', 'ysnReportDetail')

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

INSERT INTO @temp_aging_table
EXEC dbo.[uspARCustomerAgingAsOfDateReport] NULL, @dtmDateTo, NULL, NULL, @strLocationName, @ysnIncludeBudget, @ysnPrintCreditBalance

INSERT INTO @temp_balanceforward_table
EXEC dbo.[uspARCustomerAgingAsOfDateReport] NULL, @dtmDateFrom, NULL, NULL, @strLocationName, @ysnIncludeBudget, @ysnPrintCreditBalance

SET @query = CAST('' AS NVARCHAR(MAX)) + 'SELECT * FROM
(SELECT intEntityCustomerId	= C.intEntityCustomerId
	  , C.strCustomerNumber
	  , strCustomerName		= C.strName
	  , C.dblCreditLimit
	  , I.intInvoiceId
	  , I.strInvoiceNumber
	  , strBOLNumber		= CASE WHEN I.strTransactionType = ''Customer Prepayment'' THEN ''Prepayment: '' + ISNULL(PCREDITS.strPaymentInfo, '''') ELSE ''BOL# '' + I.strBOLNumber END
      , I.dtmDate
      , I.dtmDueDate
	  , I.dtmShipDate
	  , dblInvoiceTotal		= CASE WHEN I.strTransactionType IN (''Credit Memo'', ''Overpayment'', ''Customer Prepayment'') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END
	  , intPaymentId		= ISNULL(P.intPaymentId, PCREDITS.intPaymentId)
	  , strRecordNumber		= ISNULL(P.strRecordNumber, PCREDITS.strRecordNumber)
	  , strTransactionType  = I.strTransactionType
	  , strPaymentInfo	    = ''PAYMENT REF: '' + P.strPaymentInfo
	  , dtmDatePaid			= ISNULL(ISNULL(P.dtmDatePaid, PCREDITS.dtmDatePaid), ''01/02/1900'')
	  , dblPayment			= ISNULL(PD.dblPayment, 0) + ISNULL(PD.dblDiscount, 0) - ISNULL(PD.dblInterest, 0)
	  , dblBalance			= CASE WHEN I.strTransactionType IN (''Credit Memo'', ''Overpayment'', ''Customer Prepayment'') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END - ISNULL(TOTALPAYMENT.dblPayment, 0)
	  , strSalespersonName  = ESP.strName
	  , strAccountStatusCode = dbo.fnARGetCustomerAccountStatusCodes(C.intEntityCustomerId)
	  , strLocationName		= CL.strLocationName
	  , strFullAddress		= [dbo].fnARFormatCustomerAddress('''', '''', C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, NULL)
	  , strCompanyName		= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
	  , strCompanyAddress	= (SELECT TOP 1 dbo.[fnARFormatCustomerAddress]('''', '''', '''', strAddress, strCity, strState, strZip, strCountry, '''', NULL) FROM tblSMCompanySetup)
	  , dblARBalance		= CUST.dblARBalance
FROM vyuARCustomer C
	INNER JOIN tblARCustomer CUST ON C.intEntityCustomerId = CUST.intEntityCustomerId
	LEFT JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1
	LEFT JOIN tblARInvoice I ON I.intEntityCustomerId = C.intEntityCustomerId
		AND I.ysnPosted  = 1		
		AND ((I.strType = ''Service Charge'' AND I.ysnForgiven = 0) OR ((I.strType <> ''Service Charge'' AND I.ysnForgiven = 1) OR (I.strType <> ''Service Charge'' AND I.ysnForgiven = 0)))		
		AND (CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
			AND ((I.ysnPaid = 0 OR I.intInvoiceId IN (SELECT intInvoiceId FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'))
			 OR (I.ysnPaid = 1 AND I.intInvoiceId IN (SELECT intInvoiceId FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) > '+ @strDateTo +'))))
		AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN (''AR Account'', ''Customer Prepayments''))			
	LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND P.ysnInvoicePrepayment = 0 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +') ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN tblARPayment PCREDITS ON I.intPaymentId = PCREDITS.intPaymentId AND PCREDITS.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), PCREDITS.dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND P.ysnInvoicePrepayment = 0 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	LEFT JOIN tblSMTerm T ON T.intTermID = I.intTermId	
	LEFT JOIN tblEMEntity ESP ON C.intSalespersonId = ESP.intEntityId	
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId	
	LEFT JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
) MainQuery'

IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

INSERT INTO @temp_statement_table
EXEC sp_executesql @query

IF @ysnIncludeBudget = 1
    BEGIN
        SET @queryBudget = CAST('' AS NVARCHAR(MAX)) + 
            'SELECT intEntityCustomerId         = C.intEntityCustomerId 
			      , strCustomerNumber           = C.strCustomerNumber
				  , strCustomerName             = C.strName
				  , dblCreditLimit              = C.dblCreditLimit
				  , intInvoiceId				= CB.intCustomerBudgetId
			      , strInvoiceNumber			= ''Budget for: '' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101) 
				  , strBOLNumber                = NULL
				  , dtmDate						= dtmBudgetDate
				  , dtmDueDate					= DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate))
				  , dtmShipDate					= NULL
				  , dblInvoiceTotal				= dblBudgetAmount
				  , intPaymentId				= CB.intCustomerBudgetId
				  , strRecordNumber				= ''Budget for: '' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101)
				  , strTransactionType			= ''Customer Budget''
				  , strPaymentInfo				= NULL
				  , dtmDatePaid					= NULL
				  , dblPayment					= dblAmountPaid
				  , dblBalance					= dblBudgetAmount - dblAmountPaid
				  , strSalespersonName			= NULL
				  , strAccountStatusCode		= dbo.fnARGetCustomerAccountStatusCodes(C.intEntityCustomerId)
				  , strLocationName				= NULL
				  , strFullAddress				= NULL
				  , strCompanyName				= NULL
				  , strCompanyAddress			= NULL
				  , dblARBalance				= CUST.dblARBalance
            FROM tblARCustomerBudget CB
                INNER JOIN vyuARCustomer C ON CB.intEntityCustomerId = C.intEntityCustomerId
                INNER JOIN tblARCustomer CUST ON C.intEntityCustomerId = CUST.intEntityCustomerId    
            WHERE CB.dtmBudgetDate BETWEEN @dtmDateFrom AND @dtmDateTo
              AND CB.dblAmountPaid < CB.dblBudgetAmount'

        SET @filter = ''

        DELETE FROM @temp_xml_table WHERE [fieldname] = 'strLocationName'

        WHILE EXISTS(SELECT 1 FROM @temp_xml_table)
            BEGIN
                SELECT @id = id, @fieldname = [fieldname], @condition = [condition], @from = [from], @to = [to], @join = [join], @datatype = [datatype] FROM @temp_xml_table
                SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@fieldname, @condition, @from, @to, @join, null, null, @datatype)
    
				IF (@fieldname = 'strName' OR @fieldname = 'strCustomerName' )
					SET @filter = REPLACE (@filter, '|^|', ''',''')
					SET @filter = REPLACE (@filter, ''',''''', '''')

                DELETE FROM @temp_xml_table WHERE id = @id

                IF EXISTS(SELECT 1 FROM @temp_xml_table)
                BEGIN
                    SET @filter = @filter + ' AND '
                END
            END
        
        IF ISNULL(@filter,'') != ''
        BEGIN
            SET @queryBudget = @queryBudget + ' WHERE ' + @filter
        END    

        INSERT INTO @temp_statement_table
        EXEC sp_executesql @queryBudget
    END

INSERT INTO @temp_statement_table(
	  intEntityCustomerId
	, strCustomerName
	, strCustomerNumber
	, strTransactionType
	, dblCreditLimit
	, dtmDate
	, dtmDatePaid
	, intInvoiceId
	, dblBalance
	, dblPayment
)
SELECT
	  B.intEntityCustomerId
	, B.strCustomerName
	, B.strEntityNo
	, 'Balance Forward'
	, B.dblCreditLimit
	, @dtmDateFrom
	, '01/01/1900'
	, 1
	, B.dblTotalAR
	, 0
FROM @temp_balanceforward_table B
	WHERE B.intEntityCustomerId IN (SELECT DISTINCT intEntityCustomerId FROM @temp_statement_table)

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

IF @ysnPrintOnlyPastDue = 1
    BEGIN
        DELETE FROM @temp_statement_table WHERE dtmDueDate <= @dtmDateTo
        UPDATE @temp_aging_table SET dblTotalAR = dblTotalAR - dbl0Days , dbl0Days = 0
    END

IF @ysnPrintZeroBalance = 0
    BEGIN
        DELETE FROM @temp_statement_table WHERE dblARBalance = 0
        DELETE FROM @temp_aging_table WHERE dblTotalAR = 0
    END

IF @ysnPrintCreditBalance = 0
    DELETE FROM @temp_statement_table WHERE strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment')        

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
		(SELECT 
			intInvoiceId
			, strInvoiceNumber
		FROM 
			tblARInvoice
		WHERE strType NOT IN ('CF Tran')) ARI
	INNER JOIN
		(SELECT 
			intInvoiceId
			, strInvoiceReportNumber
			, dtmInvoiceDate 
		FROM 
			tblCFTransaction
		WHERE ISNULL(strInvoiceReportNumber,'') <> '') CFT ON ARI.intInvoiceId = CFT.intInvoiceId
	) cfTable ON statementTable.intInvoiceId = cfTable.intInvoiceId

DELETE 
FROM 
	@temp_statement_table
WHERE 
	intInvoiceId IN (SELECT 
						intInvoiceId 
					FROM 
						tblARInvoice 
					WHERE 
						strType = 'CF Tran' AND strTransactionType NOT IN ('Debit Memo') )

IF @ysnReportDetail = 1
BEGIN 
	--- Get only valid customers
	TRUNCATE TABLE tblARSearchStatementCustomer
	INSERT INTO tblARSearchStatementCustomer (intEntityCustomerId, strCustomerNumber, strCustomerName, dblARBalance, strTransactionId, strTransactionDate, dblTotalAmount, intConcurrencyId)
	SELECT DISTINCT ABC.intEntityCustomerId, ABC.strCustomerNumber, ABC.strCustomerName, CONVERT(char(10), GETDATE(),126), '', ARC.dblARBalance, 0, 0 	 
	FROM
	(--- Without CF Report
	SELECT
	  STATEMENTREPORT.[intEntityCustomerId]    
		,STATEMENTREPORT.[strCustomerNumber]	 
		,STATEMENTREPORT.[strCustomerName] 
		,STATEMENTREPORT.[dblCreditLimit]     
		,[intInvoiceId]							= 1   
		,[strInvoiceNumber]   
		,[strBOLNumber]       
		,[dtmDate]           
		,[dtmDueDate]   
		,[dtmShipDate]    
		,[dblInvoiceTotal]  
		,[intPaymentId]        
		,[strRecordNumber]      
		,[strTransactionType]	  
		,[strPaymentInfo]      
		,[dtmDatePaid]     
		,[dblPayment]           
		,[dblBalance]       	
		,STATEMENTREPORT.[strSalespersonName]  
		,[strAccountStatusCode] 	 
		,[strLocationName]       
		,[strFullAddress]         
		,[strCompanyName]       
		,[strCompanyAddress]    
		  ,dblTotalAR							= ISNULL(AGINGREPORT.dblTotalAR, 0)
		  ,dblCreditAvailable					= STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)
		  ,dbl0Days								= ISNULL(AGINGREPORT.dbl0Days, 0)
		  ,dbl10Days							= ISNULL(AGINGREPORT.dbl10Days, 0)
		  ,dbl30Days							= ISNULL(AGINGREPORT.dbl30Days, 0)
		  ,dbl60Days							= ISNULL(AGINGREPORT.dbl60Days, 0)
		  ,dbl90Days							= ISNULL(AGINGREPORT.dbl90Days, 0)
		  ,dbl91Days							= ISNULL(AGINGREPORT.dbl91Days, 0)
		  ,dblCredits							= ISNULL(AGINGREPORT.dblCredits, 0)
		  ,dblPrepayments						= ISNULL(AGINGREPORT.dblPrepayments, 0)
		  ,dtmAsOfDate							= @dtmDateTo
		  ,blbLogo								= dbo.fnSMGetCompanyLogo('Header')
	FROM @temp_statement_table AS STATEMENTREPORT
	INNER JOIN @temp_aging_table AS AGINGREPORT
		ON STATEMENTREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
	INNER JOIN tblARCustomer CUSTOMER 
		ON STATEMENTREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId
	WHERE CUSTOMER.strStatementFormat = 'Balance Forward'
	AND STATEMENTREPORT.intInvoiceId NOT IN (SELECT intInvoiceId FROM @temp_cf_table)

	UNION ALL

	--- With CF Report
	SELECT
		 STATEMENTREPORT.[intEntityCustomerId]    
		,STATEMENTREPORT.[strCustomerNumber]	 
		,STATEMENTREPORT.[strCustomerName] 
		,STATEMENTREPORT.[dblCreditLimit]     
		,[intInvoiceId]							= CFReportTable.intInvoiceId	 
		,[strInvoiceNumber]						= CFReportTable.strInvoiceReportNumber
		,[strBOLNumber]       
		,[dtmDate]								= CFReportTable.dtmInvoiceDate     
		,[dtmDueDate]							= CFReportTable.dtmInvoiceDate  
		,[dtmShipDate]    
		,[dblInvoiceTotal]  
		,[intPaymentId]        
		,[strRecordNumber]      
		,[strTransactionType]	  
		,[strPaymentInfo]      
		,[dtmDatePaid]     
		,[dblPayment]           
		,[dblBalance]       	
		,STATEMENTREPORT.[strSalespersonName]  
		,[strAccountStatusCode] 	 
		,[strLocationName]       
		,[strFullAddress]         
		,[strCompanyName]       
		,[strCompanyAddress]    
		  ,dblTotalAR							= ISNULL(AGINGREPORT.dblTotalAR, 0)
		  ,dblCreditAvailable					= STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)
		  ,dbl0Days								= ISNULL(AGINGREPORT.dbl0Days, 0)
		  ,dbl10Days							= ISNULL(AGINGREPORT.dbl10Days, 0)
		  ,dbl30Days							= ISNULL(AGINGREPORT.dbl30Days, 0)
		  ,dbl60Days							= ISNULL(AGINGREPORT.dbl60Days, 0)
		  ,dbl90Days							= ISNULL(AGINGREPORT.dbl90Days, 0)
		  ,dbl91Days							= ISNULL(AGINGREPORT.dbl91Days, 0)
		  ,dblCredits							= ISNULL(AGINGREPORT.dblCredits, 0)
		  ,dblPrepayments						= ISNULL(AGINGREPORT.dblPrepayments, 0)
		  ,dtmAsOfDate							= @dtmDateTo
		  ,blbLogo								= dbo.fnSMGetCompanyLogo('Header')
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
					@temp_cf_table) CFReportTable ON STATEMENTREPORT.intInvoiceId = CFReportTable.intInvoiceId
	WHERE CUSTOMER.strStatementFormat = 'Balance Forward'
	AND STATEMENTREPORT.intInvoiceId IN (SELECT intInvoiceId FROM @temp_cf_table)) ABC 
	INNER JOIN 
		(SELECT intEntityCustomerId, dblARBalance FROM tblARCustomer ) ARC ON ABC.intEntityCustomerId = ARC.intEntityCustomerId
END

ELSE 
BEGIN
	--- Without CF Report
	SELECT
	  STATEMENTREPORT.[intEntityCustomerId]    
		,STATEMENTREPORT.[strCustomerNumber]	 
		,STATEMENTREPORT.[strCustomerName] 
		,STATEMENTREPORT.[dblCreditLimit]     
		,[intInvoiceId]							= 1   
		,[strInvoiceNumber]   
		,[strBOLNumber]       
		,[dtmDate]           
		,[dtmDueDate]   
		,[dtmShipDate]    
		,[dblInvoiceTotal]  
		,[intPaymentId]        
		,[strRecordNumber]      
		,[strTransactionType]	  
		,[strPaymentInfo]      
		,[dtmDatePaid]     
		,[dblPayment]           
		,[dblBalance]       	
		,STATEMENTREPORT.[strSalespersonName]  
		,[strAccountStatusCode] 	 
		,[strLocationName]       
		,[strFullAddress]         
		,[strCompanyName]       
		,[strCompanyAddress]    
		  ,dblTotalAR							= ISNULL(AGINGREPORT.dblTotalAR, 0)
		  ,dblCreditAvailable					= STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)
		  ,dbl0Days								= ISNULL(AGINGREPORT.dbl0Days, 0)
		  ,dbl10Days							= ISNULL(AGINGREPORT.dbl10Days, 0)
		  ,dbl30Days							= ISNULL(AGINGREPORT.dbl30Days, 0)
		  ,dbl60Days							= ISNULL(AGINGREPORT.dbl60Days, 0)
		  ,dbl90Days							= ISNULL(AGINGREPORT.dbl90Days, 0)
		  ,dbl91Days							= ISNULL(AGINGREPORT.dbl91Days, 0)
		  ,dblCredits							= ISNULL(AGINGREPORT.dblCredits, 0)
		  ,dblPrepayments						= ISNULL(AGINGREPORT.dblPrepayments, 0)
		  ,dtmAsOfDate							= @dtmDateTo
		  ,blbLogo								= dbo.fnSMGetCompanyLogo('Header')
	FROM @temp_statement_table AS STATEMENTREPORT
	INNER JOIN @temp_aging_table AS AGINGREPORT
		ON STATEMENTREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
	INNER JOIN tblARCustomer CUSTOMER 
		ON STATEMENTREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId
	WHERE CUSTOMER.strStatementFormat = 'Balance Forward'
	AND STATEMENTREPORT.intInvoiceId NOT IN (SELECT intInvoiceId FROM @temp_cf_table)

	UNION ALL

	--- With CF Report
	SELECT
		 STATEMENTREPORT.[intEntityCustomerId]    
		,STATEMENTREPORT.[strCustomerNumber]	 
		,STATEMENTREPORT.[strCustomerName] 
		,STATEMENTREPORT.[dblCreditLimit]     
		,[intInvoiceId]							= CFReportTable.intInvoiceId	 
		,[strInvoiceNumber]						= CFReportTable.strInvoiceReportNumber
		,[strBOLNumber]       
		,[dtmDate]								= CFReportTable.dtmInvoiceDate     
		,[dtmDueDate]							= CFReportTable.dtmInvoiceDate  
		,[dtmShipDate]    
		,[dblInvoiceTotal]  
		,[intPaymentId]        
		,[strRecordNumber]      
		,[strTransactionType]	  
		,[strPaymentInfo]      
		,[dtmDatePaid]     
		,[dblPayment]           
		,[dblBalance]       	
		,STATEMENTREPORT.[strSalespersonName]  
		,[strAccountStatusCode] 	 
		,[strLocationName]       
		,[strFullAddress]         
		,[strCompanyName]       
		,[strCompanyAddress]    
		  ,dblTotalAR							= ISNULL(AGINGREPORT.dblTotalAR, 0)
		  ,dblCreditAvailable					= STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)
		  ,dbl0Days								= ISNULL(AGINGREPORT.dbl0Days, 0)
		  ,dbl10Days							= ISNULL(AGINGREPORT.dbl10Days, 0)
		  ,dbl30Days							= ISNULL(AGINGREPORT.dbl30Days, 0)
		  ,dbl60Days							= ISNULL(AGINGREPORT.dbl60Days, 0)
		  ,dbl90Days							= ISNULL(AGINGREPORT.dbl90Days, 0)
		  ,dbl91Days							= ISNULL(AGINGREPORT.dbl91Days, 0)
		  ,dblCredits							= ISNULL(AGINGREPORT.dblCredits, 0)
		  ,dblPrepayments						= ISNULL(AGINGREPORT.dblPrepayments, 0)
		  ,dtmAsOfDate							= @dtmDateTo
		  ,blbLogo								= dbo.fnSMGetCompanyLogo('Header')
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
					@temp_cf_table) CFReportTable ON STATEMENTREPORT.intInvoiceId = CFReportTable.intInvoiceId
	WHERE CUSTOMER.strStatementFormat = 'Balance Forward'
	AND STATEMENTREPORT.intInvoiceId IN (SELECT intInvoiceId FROM @temp_cf_table)
END