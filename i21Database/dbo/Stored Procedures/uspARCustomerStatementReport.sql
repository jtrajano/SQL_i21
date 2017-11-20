CREATE PROCEDURE [dbo].[uspARCustomerStatementReport]
	  @dtmDateTo					AS DATETIME			= NULL
	, @dtmDateFrom					AS DATETIME			= NULL
	, @ysnPrintZeroBalance			AS BIT				= 0
	, @ysnPrintCreditBalance		AS BIT				= 1
	, @ysnIncludeBudget				AS BIT				= 0
	, @ysnPrintOnlyPastDue			AS BIT				= 0
	, @ysnExcludeInactiveCustomers	AS BIT				= 0
	, @strCustomerNumber			AS NVARCHAR(MAX)	= NULL
	, @strAccountStatusCode			AS NVARCHAR(MAX)	= NULL
	, @strLocationName				AS NVARCHAR(MAX)	= NULL
	, @strStatementFormat			AS NVARCHAR(MAX)	= 'Open Item'
	, @strCustomerName				AS NVARCHAR(MAX)	= NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dtmDateToLocal						AS DATETIME			= NULL
	  , @dtmDateFromLocal					AS DATETIME			= NULL
	  , @ysnPrintZeroBalanceLocal			AS BIT				= 0
	  , @ysnPrintCreditBalanceLocal			AS BIT				= 1
	  , @ysnIncludeBudgetLocal				AS BIT				= 0
	  , @ysnPrintOnlyPastDueLocal			AS BIT				= 0
	  , @ysnExcludeInactiveCustomersLocal	AS BIT				= 0
	  , @strCustomerNumberLocal				AS NVARCHAR(MAX)	= NULL
	  , @strLocationNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strAccountStatusCodeLocal			AS NVARCHAR(MAX)	= NULL
	  , @strStatementFormatLocal			AS NVARCHAR(MAX)	= 'Open Item'
	  , @strCustomerNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strDateTo							AS NVARCHAR(50)
	  , @strDateFrom						AS NVARCHAR(50)
	  , @query								AS NVARCHAR(MAX)
	  , @queryBudget						AS NVARCHAR(MAX)
	  , @filter								AS NVARCHAR(MAX)	= ''

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
	,[dblRunningBalance]			NUMERIC(18,6)
	,[strCustomerNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strDisplayName]				NVARCHAR(100)
	,[strName]						NVARCHAR(100)
	,[strBOLNumber]					NVARCHAR(100)
	,[dblCreditLimit]				NUMERIC(18,6)
	,[strAccountStatusCode]			NVARCHAR(50)	
	,[strLocationName]				NVARCHAR(100)
	,[strFullAddress]				NVARCHAR(MAX)
	,[strStatementFooterComment]	NVARCHAR(MAX)	
	,[strCompanyName]				NVARCHAR(MAX)
	,[strCompanyAddress]			NVARCHAR(MAX)
	,[dblARBalance]					NUMERIC(18,6)
)

DECLARE @temp_cf_table TABLE(
	 [intInvoiceId]				INT
	,[strInvoiceNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strInvoiceReportNumber]	NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[dtmInvoiceDate]			DATETIME
)

IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL)
BEGIN
    DROP TABLE #CUSTOMERS
END

SELECT intEntityCustomerId
	 , strCustomerNumber	= CAST(strCustomerNumber COLLATE Latin1_General_CI_AS AS NVARCHAR(200))
	 , strCustomerName		= CAST('' COLLATE Latin1_General_CI_AS AS NVARCHAR(200))
	 , strStatementFormat	= CAST(strStatementFormat COLLATE Latin1_General_CI_AS AS NVARCHAR(100))
	 , dblCreditLimit
	 , dblARBalance
INTO #CUSTOMERS
FROM tblARCustomer
WHERE 1 = 0

SET @dtmDateToLocal						= ISNULL(@dtmDateTo, GETDATE())
SET	@dtmDateFromLocal					= ISNULL(@dtmDateFrom, CAST(-53690 AS DATETIME))
SET @ysnPrintZeroBalanceLocal			= ISNULL(@ysnPrintZeroBalance, 0)
SET @ysnPrintCreditBalanceLocal			= ISNULL(@ysnPrintCreditBalance, 1)
SET @ysnIncludeBudgetLocal				= ISNULL(@ysnIncludeBudget, 0)
SET @ysnPrintOnlyPastDueLocal			= ISNULL(@ysnPrintOnlyPastDue, 0)
SET @ysnExcludeInactiveCustomersLocal	= ISNULL(@ysnExcludeInactiveCustomers, 0)
SET @strCustomerNumberLocal				= NULLIF(@strCustomerNumber, '')
SET @strAccountStatusCodeLocal			= NULLIF(@strAccountStatusCode, '')
SET @strLocationNameLocal				= NULLIF(@strLocationName, '')
SET @strStatementFormatLocal			= ISNULL(@strStatementFormat, 'Open Item')
SET @strCustomerNameLocal				= NULLIF(@strCustomerName, '')
SET @strDateTo							= ''''+ CONVERT(NVARCHAR(50),@dtmDateToLocal, 110) + ''''
SET @strDateFrom						= ''''+ CONVERT(NVARCHAR(50),@dtmDateFromLocal, 110) + ''''

IF @strCustomerNumberLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT TOP 1 intEntityCustomerId    = intEntityCustomerId 
					, strCustomerNumber      = C.strCustomerNumber
					, strCustomerName        = EC.strName
					, strStatementFormat		= C.strStatementFormat
					, dblCreditLimit         = C.dblCreditLimit
					, dblARBalance           = C.dblARBalance        
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
					, strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE strEntityNo = @strCustomerNumberLocal
		) EC ON C.intEntityCustomerId = EC.intEntityId
		WHERE ((@ysnExcludeInactiveCustomersLocal = 1 AND C.ysnActive = 1) OR @ysnExcludeInactiveCustomersLocal = 0)
			AND C.strStatementFormat = @strStatementFormatLocal
	END
ELSE
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT intEntityCustomerId  = intEntityCustomerId 
				, strCustomerNumber	= C.strCustomerNumber
				, strCustomerName      = EC.strName
				, strStatementFormat	= C.strStatementFormat
				, dblCreditLimit       = C.dblCreditLimit
				, dblARBalance         = C.dblARBalance
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
					, strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE (@strCustomerNameLocal IS NULL OR strName LIKE '%'+ @strCustomerNameLocal +'%')
		) EC ON C.intEntityCustomerId = EC.intEntityId
		WHERE ((@ysnExcludeInactiveCustomersLocal = 1 AND C.ysnActive = 1) OR @ysnExcludeInactiveCustomersLocal = 0)
			AND C.strStatementFormat = @strStatementFormatLocal
END

IF @strAccountStatusCodeLocal IS NOT NULL
	SET @filter = CASE WHEN ISNULL(@filter, '') <> '' THEN @filter + ' AND ' ELSE @filter + '' END + 'strAccountStatusCode LIKE (%''' + @strAccountStatusCodeLocal + '''%)'

IF @strLocationNameLocal IS NOT NULL
	SET @filter = CASE WHEN ISNULL(@filter, '') <> '' THEN @filter + ' AND ' ELSE @filter + '' END + 'strLocationName = ''' + @strLocationNameLocal + ''''

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
EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateTo = @dtmDateToLocal
										  , @strCompanyLocation = @strLocationNameLocal
										  , @ysnIncludeBudget = @ysnIncludeBudgetLocal
										  , @ysnIncludeCredits = @ysnPrintCreditBalanceLocal
										  , @strCustomerName = @strCustomerNameLocal
 
SET @query = CAST('' AS NVARCHAR(MAX)) + 'SELECT * FROM
(SELECT I.strInvoiceNumber AS strReferenceNumber
	 , strTransactionType = CASE WHEN I.strType = ''Service Charge'' THEN ''Service Charge'' ELSE I.strTransactionType END
	 , C.intEntityCustomerId
	 , dtmDueDate = CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Credit Memo'', ''Debit Memo'') THEN NULL ELSE I.dtmDueDate END
	 , I.dtmDate
	 , intDaysDue = DATEDIFF(DAY, I.[dtmDueDate], '+ @strDateTo +')
	 , dblTotalAmount = CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
	 , dblAmountPaid = CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN ISNULL(TOTALPAYMENT.dblPayment, 0) * -1 ELSE ISNULL(TOTALPAYMENT.dblPayment, 0) END
	 , dblAmountDue = CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END - ISNULL(TOTALPAYMENT.dblPayment, 0)
	 , dblPastDue = CASE WHEN '+ @strDateTo +' > I.[dtmDueDate] AND I.strTransactionType IN (''Invoice'', ''Debit Memo'')
						THEN I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0)
						ELSE 0
					END
	 , dblMonthlyBudget = ISNULL([dbo].[fnARGetCustomerBudget](C.intEntityCustomerId, I.dtmDate), 0)
	 , dblRunningBalance = SUM(CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN I.dblInvoiceTotal * -1 ELSE (CASE WHEN I.strType = ''CF Tran'' THEN 0 ELSE I.dblInvoiceTotal END) END - ISNULL(TOTALPAYMENT.dblPayment, 0)) OVER (PARTITION BY I.intEntityCustomerId ORDER BY I.dtmPostDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	 , C.strCustomerNumber
	 , strDisplayName = CASE WHEN CUST.strStatementFormat <> ''Running Balance'' THEN CUST.strCustomerName ELSE ISNULL(CC.strCheckPayeeName, CUST.strCustomerName) END
	 , strName = CUST.strCustomerName
	 , I.strBOLNumber
	 , C.dblCreditLimit
	 , strAccountStatusCode = STATUSCODES.strAccountStatusCode
	 , CL.strLocationName
	 , strFullAddress = [dbo].fnARFormatCustomerAddress(NULL, NULL, CASE WHEN CUST.strStatementFormat <> ''Running Balance'' THEN C.strBillToLocationName ELSE NULL END, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, NULL)
	 , strStatementFooterComment = [dbo].fnARGetFooterComment(I.intCompanyLocationId, I.intEntityCustomerId, ''Statement Footer'', 1)	 
	 , strCompanyName = (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
	 , strCompanyAddress = (SELECT TOP 1 dbo.[fnARFormatCustomerAddress](strPhone, '''', '''', strAddress, strCity, strState, strZip, strCountry, '''', NULL) FROM tblSMCompanySetup)
	 , dblARBalance = CUST.dblARBalance
	FROM vyuARCustomer C
	INNER JOIN #CUSTOMERS CUST ON C.intEntityCustomerId = CUST.intEntityCustomerId
	LEFT JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1
	LEFT JOIN tblARInvoice I ON I.intEntityCustomerId = C.intEntityCustomerId
		AND I.ysnPosted  = 1		
		AND ((I.strType = ''Service Charge'' AND I.ysnForgiven = 0) OR ((I.strType <> ''Service Charge'' AND I.ysnForgiven = 1) OR (I.strType <> ''Service Charge'' AND I.ysnForgiven = 0)))		
		AND (CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= '+ @strDateTo +' 
		AND (I.ysnPaid = 0
			 OR (I.ysnPaid = 1 AND I.intInvoiceId IN (SELECT intInvoiceId FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) > '+ @strDateTo +' UNION ALL SELECT intPrepaymentId FROM tblARPrepaidAndCredit WHERE ysnApplied = 1))))
		AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN (''AR Account'', ''Customer Prepayments''))	
	LEFT JOIN tblARPayment PCREDITS ON I.intPaymentId = PCREDITS.intPaymentId AND PCREDITS.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), PCREDITS.dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
				, intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND P.ysnInvoicePrepayment = 0 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= '+ @strDateTo +'
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	LEFT JOIN (
		(SELECT intPrepaymentId
		     , SUM(dblAppliedInvoiceAmount) AS dblAppliedInvoiceAmount
			FROM tblARPrepaidAndCredit WHERE ysnApplied = 1
			GROUP BY intPrepaymentId)
		) PC ON I.intInvoiceId = PC.intPrepaymentId
	LEFT JOIN tblSMTerm T ON I.intTermId = T.intTermID	
	LEFT JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
	OUTER APPLY (
		SELECT strAccountStatusCode = LEFT(strAccountStatusCode, LEN(strAccountStatusCode) - 1)
		FROM (
			SELECT CAST(ARAS.strAccountStatusCode AS VARCHAR(200))  + '', ''
			FROM dbo.tblARCustomerAccountStatus CAS WITH(NOLOCK)
			INNER JOIN (
				SELECT intAccountStatusId
						, strAccountStatusCode
				FROM dbo.tblARAccountStatus WITH (NOLOCK)
			) ARAS ON CAS.intAccountStatusId = ARAS.intAccountStatusId
			WHERE CAS.intEntityCustomerId = C.intEntityCustomerId
			FOR XML PATH ('''')
		) SC (strAccountStatusCode)
	) STATUSCODES
) MainQuery'
 
IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter	
END

INSERT INTO @temp_statement_table
EXEC sp_executesql @query

IF @ysnIncludeBudgetLocal = 1
	BEGIN
		SET @queryBudget = CAST('' AS NVARCHAR(MAX)) + 
			'SELECT strReferenceNumber			= ''Budget for: '' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101) 
				  , strTransactionType			= ''Customer Budget''
				  , intEntityCustomerId			= C.intEntityCustomerId
				  , dtmDueDate					= DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate))
				  , dtmDate						= dtmBudgetDate
				  , intDaysDue					= DATEDIFF(DAY, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), '+ @strDateTo +')
				  , dblTotalAmount				= dblBudgetAmount
				  , dblAmountPaid				= dblAmountPaid
				  , dblAmountDue				= dblBudgetAmount - dblAmountPaid
				  , dblPastDue					= dblBudgetAmount - dblAmountPaid
				  , dblMonthlyBudget			= dblBudgetAmount
				  , dblRunningBalance			= SUM(dblBudgetAmount - dblAmountPaid) OVER (PARTITION BY C.intEntityCustomerId ORDER BY intCustomerBudgetId ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
				  , strCustomerNumber			= C.strCustomerNumber
				  , strDisplayName				= CASE WHEN C.strStatementFormat <> ''Running Balance'' THEN C.strCustomerName ELSE ISNULL(CC.strCheckPayeeName, C.strCustomerName) END
				  , strName						= C.strCustomerName
				  , strBOLNumber				= NULL
				  , dblCreditLimit				= C.dblCreditLimit
				  , strAccountStatusCode		= STATUSCODES.strAccountStatusCode
				  , strLocationName				= NULL
				  , strFullAddress				= NULL
				  , strStatementFooterComment	= NULL
				  , strCompanyName				= NULL
				  , strCompanyAddress			= NULL
				  , dblARBalance				= C.dblARBalance
			FROM tblARCustomerBudget CB
				INNER JOIN #CUSTOMERS C ON CB.intEntityCustomerId = C.intEntityCustomerId
				LEFT JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1
				OUTER APPLY (
					SELECT strAccountStatusCode = LEFT(strAccountStatusCode, LEN(strAccountStatusCode) - 1)
					FROM (
						SELECT CAST(ARAS.strAccountStatusCode AS VARCHAR(200))  + '', ''
						FROM dbo.tblARCustomerAccountStatus CAS WITH(NOLOCK)
						INNER JOIN (
							SELECT intAccountStatusId
								 , strAccountStatusCode
							FROM dbo.tblARAccountStatus WITH (NOLOCK)
						) ARAS ON CAS.intAccountStatusId = ARAS.intAccountStatusId
						WHERE CAS.intEntityCustomerId = CB.intEntityCustomerId
						FOR XML PATH ('''')
					) SC (strAccountStatusCode)
				) STATUSCODES
			WHERE CB.dtmBudgetDate BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
			  AND CB.dblAmountPaid < CB.dblBudgetAmount'

		IF ISNULL(@filter,'') != ''
        BEGIN
            SET @queryBudget = @queryBudget + ' WHERE ' + @filter
        END

		INSERT INTO @temp_statement_table
		EXEC sp_executesql @queryBudget
	END

IF @ysnPrintOnlyPastDueLocal = 1
	BEGIN		
		DELETE FROM @temp_statement_table WHERE DATEDIFF(DAYOFYEAR, dtmDueDate, @dtmDateToLocal) > 0
		UPDATE tblARCustomerAgingStagingTable SET dblTotalAR = dblTotalAR - dbl0Days , dbl0Days = 0
	END

IF @ysnPrintZeroBalanceLocal = 0
	BEGIN
		DELETE FROM @temp_statement_table WHERE ISNULL(dblARBalance, 0) = 0
		DELETE FROM tblARCustomerAgingStagingTable WHERE dblTotalAR = 0
	END

IF @ysnPrintCreditBalanceLocal = 0
	BEGIN
		DELETE FROM @temp_statement_table WHERE strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment')
		DELETE FROM tblARCustomerAgingStagingTable WHERE dblTotalAR < 0
	END

INSERT INTO @temp_cf_table (
	  intInvoiceId
	, strInvoiceNumber
	, strInvoiceReportNumber
	, dtmInvoiceDate
)
SELECT cfTable.intInvoiceId
	 , cfTable.strInvoiceNumber
	 , cfTable.strInvoiceReportNumber
	 , cfTable.dtmInvoiceDate
FROM @temp_statement_table statementTable
INNER JOIN (
	SELECT ARI.intInvoiceId 
		 , ARI.strInvoiceNumber
		 , CFT.strInvoiceReportNumber
		 , CFT.dtmInvoiceDate
	FROM (
		SELECT intInvoiceId
			 , strInvoiceNumber
		FROM dbo.tblARInvoice WITH (NOLOCK)
		WHERE strType NOT IN ('CF Tran')
	) ARI
	INNER JOIN (
		SELECT intInvoiceId
			 , strInvoiceReportNumber
			 , dtmInvoiceDate 
		FROM dbo.tblCFTransaction WITH (NOLOCK)
		WHERE ISNULL(strInvoiceReportNumber,'') <> ''
	) CFT ON ARI.intInvoiceId = CFT.intInvoiceId
) cfTable ON statementTable.strReferenceNumber = cfTable.strInvoiceNumber

DELETE FROM @temp_statement_table
WHERE strReferenceNumber IN (SELECT strInvoiceNumber FROM dbo.tblARInvoice WITH (NOLOCK) WHERE strType = 'CF Tran' AND strTransactionType NOT IN ('Debit Memo'))

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

TRUNCATE TABLE tblARCustomerStatementStagingTable
INSERT INTO tblARCustomerStatementStagingTable (
	  strReferenceNumber
	, intEntityCustomerId
	, strTransactionType
	, dtmDueDate
	, dtmDate
	, intDaysDue
	, dblTotalAmount
	, dblAmountPaid
	, dblAmountDue
	, dblPastDue
	, dblMonthlyBudget
	, dblRunningBalance
	, strCustomerNumber
	, strDisplayName
	, strCustomerName
	, strBOLNumber
	, dblCreditLimit
	, strFullAddress
	, strStatementFooterComment
	, strCompanyName
	, strCompanyAddress
	, dblCreditAvailable
	, dblFuture
	, dbl0Days
	, dbl10Days
	, dbl30Days
	, dbl60Days
	, dbl90Days
	, dbl91Days
	, dblCredits
	, dblPrepayments
	, dtmAsOfDate
	, blbLogo)
SELECT MAINREPORT.* 
	 , dblCreditAvailable	= MAINREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)
	 , dblFuture			= ISNULL(AGINGREPORT.dblFuture, 0)
	 , dbl0Days				= ISNULL(AGINGREPORT.dbl0Days, 0)
	 , dbl10Days			= ISNULL(AGINGREPORT.dbl10Days, 0)
	 , dbl30Days			= ISNULL(AGINGREPORT.dbl30Days, 0)
	 , dbl60Days			= ISNULL(AGINGREPORT.dbl60Days, 0)
	 , dbl90Days			= ISNULL(AGINGREPORT.dbl90Days, 0)
	 , dbl91Days			= ISNULL(AGINGREPORT.dbl91Days, 0)
	 , dblCredits			= ISNULL(AGINGREPORT.dblCredits, 0)
	 , dblPrepayments		= ISNULL(AGINGREPORT.dblPrepayments, 0)
	 , dtmAsOfDate			= @dtmDateToLocal
	 , blbLogo				= dbo.fnSMGetCompanyLogo('Header')
FROM (
	SELECT STATEMENTREPORT.strReferenceNumber
	     , STATEMENTREPORT.intEntityCustomerId
	     , STATEMENTREPORT.strTransactionType
	     , STATEMENTREPORT.dtmDueDate
	     , STATEMENTREPORT.dtmDate
	     , STATEMENTREPORT.intDaysDue
	     , STATEMENTREPORT.dblTotalAmount
	     , STATEMENTREPORT.dblAmountPaid
	     , STATEMENTREPORT.dblAmountDue
	     , STATEMENTREPORT.dblPastDue
	     , STATEMENTREPORT.dblMonthlyBudget
	     , STATEMENTREPORT.dblRunningBalance
	     , STATEMENTREPORT.strCustomerNumber
	     , STATEMENTREPORT.strDisplayName
	     , STATEMENTREPORT.strName
	     , STATEMENTREPORT.strBOLNumber
	     , STATEMENTREPORT.dblCreditLimit	  
	     , STATEMENTREPORT.strFullAddress
	     , STATEMENTREPORT.strStatementFooterComment	  
	     , STATEMENTREPORT.strCompanyName
	     , STATEMENTREPORT.strCompanyAddress	  	     
	FROM @temp_statement_table AS STATEMENTREPORT
	WHERE strReferenceNumber NOT IN (SELECT strInvoiceNumber FROM @temp_cf_table)

	UNION ALL

	--- With CF Report
	SELECT strReferenceNumber							= CFReportTable.strInvoiceReportNumber
		 , STATEMENTREPORT.intEntityCustomerId
		 , STATEMENTREPORT.strTransactionType
		 , dtmDueDate									= CFReportTable.dtmInvoiceDate
		 , dtmDate										= CFReportTable.dtmInvoiceDate
		 , intDaysDue									= (SELECT TOP 1 intDaysDue FROM @temp_statement_table ORDER BY intDaysDue DESC)
		 , dblTotalAmount								= SUM(STATEMENTREPORT.dblTotalAmount)
		 , dblAmountPaid								= SUM(STATEMENTREPORT.dblAmountPaid)
		 , dblAmountDue									= SUM(STATEMENTREPORT.dblAmountDue)
		 , dblPastDue									= SUM(STATEMENTREPORT.dblPastDue)
		 , dblMonthlyBudget								= SUM(STATEMENTREPORT.dblMonthlyBudget)
		 , dblRunningBalance							= SUM(STATEMENTREPORT.dblRunningBalance)
		 , STATEMENTREPORT.strCustomerNumber
		 , STATEMENTREPORT.strDisplayName
		 , STATEMENTREPORT.strName
		 , STATEMENTREPORT.strBOLNumber
		 , STATEMENTREPORT.dblCreditLimit	  
		 , STATEMENTREPORT.strFullAddress
		 , STATEMENTREPORT.strStatementFooterComment	  
		 , STATEMENTREPORT.strCompanyName
		 , STATEMENTREPORT.strCompanyAddress	  
	FROM @temp_statement_table AS STATEMENTREPORT
	INNER JOIN (
		SELECT intInvoiceId
			 , strInvoiceNumber
			 , strInvoiceReportNumber
			 , dtmInvoiceDate 
		FROM @temp_cf_table
	) CFReportTable ON STATEMENTREPORT.strReferenceNumber = CFReportTable.strInvoiceNumber
	GROUP BY CFReportTable.strInvoiceReportNumber
		   , CFReportTable.dtmInvoiceDate
		   , STATEMENTREPORT.strTransactionType	  
		   , STATEMENTREPORT.strCustomerNumber
		   , STATEMENTREPORT.strDisplayName
		   , STATEMENTREPORT.strName
		   , STATEMENTREPORT.strBOLNumber
		   , STATEMENTREPORT.dblCreditLimit	  
		   , STATEMENTREPORT.strFullAddress
		   , STATEMENTREPORT.strStatementFooterComment	  
		   , STATEMENTREPORT.strCompanyName
		   , STATEMENTREPORT.strCompanyAddress
		   , STATEMENTREPORT.intEntityCustomerId
) MAINREPORT
LEFT JOIN tblARCustomerAgingStagingTable AS AGINGREPORT
	ON MAINREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
INNER JOIN #CUSTOMERS CUSTOMER ON MAINREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId