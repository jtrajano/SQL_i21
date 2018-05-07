CREATE PROCEDURE [dbo].[uspARCustomerStatementPaymentActivityReport]
	  @dtmDateTo						AS DATETIME			= NULL
	, @dtmDateFrom						AS DATETIME			= NULL
	, @ysnPrintZeroBalance				AS BIT				= 0
	, @ysnPrintCreditBalance			AS BIT				= 1
	, @ysnIncludeBudget					AS BIT				= 0
	, @ysnPrintOnlyPastDue				AS BIT				= 0
	, @ysnActiveCustomers		        AS BIT				= 0
	, @strCustomerNumber				AS NVARCHAR(MAX)	= NULL
	, @strAccountStatusCode				AS NVARCHAR(MAX)	= NULL
	, @strLocationName					AS NVARCHAR(MAX)	= NULL
	, @strCustomerName					AS NVARCHAR(MAX)	= NULL
	, @strCustomerIds					AS NVARCHAR(MAX)	= NULL
	, @ysnEmailOnly						AS BIT				= NULL
	, @ysnIncludeWriteOffPayment    	AS BIT 				= 1
	, @intEntityUserId					AS INT				= NULL
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
	  , @ysnActiveCustomersLocal			AS BIT				= 0
	  , @ysnIncludeWriteOffPaymentLocal		AS BIT				= 1
	  , @strCustomerNumberLocal				AS NVARCHAR(MAX)	= NULL
	  , @strLocationNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strAccountStatusCodeLocal			AS NVARCHAR(MAX)	= NULL
	  , @strCustomerNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCustomerIdsLocal				AS NVARCHAR(MAX)	= NULL
	  , @strDateTo							AS NVARCHAR(50)
	  , @strDateFrom						AS NVARCHAR(50)
	  , @query								AS NVARCHAR(MAX)
	  , @queryBudget						AS NVARCHAR(MAX)
	  , @filter								AS NVARCHAR(MAX)	= ''
	  , @intWriteOffPaymentMethodId			AS INT				= NULL
	  , @intEntityUserIdLocal				AS INT				= NULL

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
     [intEntityCustomerId]			INT
    ,[strCustomerNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
    ,[strCustomerName]				NVARCHAR(100)
    ,[dblCreditLimit]				NUMERIC(18,6)
    ,[intInvoiceId]					INT
    ,[strInvoiceNumber]				NVARCHAR(100) COLLATE Latin1_General_CI_AS
    ,[strBOLNumber]					NVARCHAR(100)
    ,[dtmDate]						DATETIME
    ,[dtmDueDate]					DATETIME
    ,[dtmShipDate]					DATETIME
    ,[dblInvoiceTotal]				NUMERIC(18,6)
    ,[intPaymentId]					INT
    ,[strRecordNumber]				NVARCHAR(100)
	,[strTransactionType]			NVARCHAR(100)
    ,[strPaymentInfo]				NVARCHAR(100)
    ,[dtmDatePaid]					DATETIME
    ,[dblPayment]					NUMERIC(18,6)
    ,[dblBalance]					NUMERIC(18,6)
    ,[strSalespersonName]			NVARCHAR(100)
	,[strAccountStatusCode]			NVARCHAR(50)
	,[strTicketNumbers]				NVARCHAR(MAX)	
	,[strLocationName]				NVARCHAR(100)    
    ,[strFullAddress]				NVARCHAR(MAX)
	,[strStatementFooterComment]	NVARCHAR(MAX)
    ,[strCompanyName]				NVARCHAR(MAX)
    ,[strCompanyAddress]			NVARCHAR(MAX)
	,[dblARBalance]					NUMERIC(18,6)
	,[ysnStatementCreditLimit]		BIT
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

SELECT intEntityCustomerId  = intEntityId
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
SET @ysnActiveCustomersLocal			= ISNULL(@ysnActiveCustomers, 0)
SET @ysnIncludeWriteOffPaymentLocal		= ISNULL(@ysnIncludeWriteOffPayment, 0)
SET @strCustomerNumberLocal				= NULLIF(@strCustomerNumber, '')
SET @strAccountStatusCodeLocal			= NULLIF(@strAccountStatusCode, '')
SET @strLocationNameLocal				= NULLIF(@strLocationName, '')
SET @strCustomerNameLocal				= NULLIF(@strCustomerName, '')
SET @strCustomerIdsLocal				= NULLIF(@strCustomerIds, '')
SET @strDateTo							= ''''+ CONVERT(NVARCHAR(50),@dtmDateToLocal, 110) + ''''
SET @strDateFrom						= ''''+ CONVERT(NVARCHAR(50),@dtmDateFromLocal, 110) + ''''
SET @intEntityUserIdLocal				= NULLIF(@intEntityUserId, 0)

IF @strCustomerNumberLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT TOP 1 intEntityCustomerId    = C.intEntityId 
				   , strCustomerNumber      = C.strCustomerNumber
				   , strCustomerName        = EC.strName
				   , strStatementFormat	= C.strStatementFormat
				   , dblCreditLimit         = C.dblCreditLimit
				   , dblARBalance           = C.dblARBalance        
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
					, strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE strEntityNo = @strCustomerNumberLocal
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
			AND C.strStatementFormat = 'Payment Activity'
	END
ELSE IF @strCustomerIdsLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT intEntityCustomerId  = C.intEntityId 
		     , strCustomerNumber    = C.strCustomerNumber
		     , strCustomerName      = EC.strName
		     , strStatementFormat	= C.strStatementFormat
		     , dblCreditLimit       = C.dblCreditLimit
		     , dblARBalance         = C.dblARBalance        
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intID
			FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIdsLocal)
		) CUSTOMERS ON C.intEntityId = CUSTOMERS.intID
		INNER JOIN (
			SELECT intEntityId
				 , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)			
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
			AND C.strStatementFormat = 'Payment Activity'
	END
ELSE
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT intEntityCustomerId  = C.intEntityId 
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
			WHERE (@strCustomerNameLocal IS NULL OR strName = @strCustomerNameLocal)
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
			AND C.strStatementFormat = 'Payment Activity'
END

IF @strAccountStatusCodeLocal IS NOT NULL
	SET @filter = CASE WHEN ISNULL(@filter, '') <> '' THEN @filter + ' AND ' ELSE @filter + '' END + 'strAccountStatusCode LIKE (%''' + @strAccountStatusCodeLocal + '''%)'

IF @strLocationNameLocal IS NOT NULL
	SET @filter = CASE WHEN ISNULL(@filter, '') <> '' THEN @filter + ' AND ' ELSE @filter + '' END + 'strLocationName = ''' + @strLocationNameLocal + ''''

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

IF @ysnIncludeWriteOffPaymentLocal = 1
	BEGIN
		SELECT TOP 1 @intWriteOffPaymentMethodId = intPaymentMethodID 
		FROM dbo.tblSMPaymentMethod WITH (NOLOCK) 
		WHERE UPPER(strPaymentMethod) = 'WRITE OFF'
	END

EXEC dbo.[uspARCustomerAgingAsOfDateReport] @strCompanyLocation = @strLocationNameLocal
										  , @strCustomerName = @strCustomerNameLocal
										  , @ysnIncludeWriteOffPayment = @ysnIncludeWriteOffPaymentLocal
										  , @intEntityUserId = @intEntityUserIdLocal

SET @query = CAST('' AS NVARCHAR(MAX)) + 
'SELECT * 
FROM (
SELECT intEntityCustomerId	= C.intEntityId
	  , strCustomerNumber	= C.strCustomerNumber
	  , strCustomerName		= C.strName
	  , dblCreditLimit		= C.dblCreditLimit
	  , intInvoiceId		= I.intInvoiceId
	  , strInvoiceNumber    = CASE WHEN ISNULL(I.ysnImportedFromOrigin, 0) = 0 THEN I.strInvoiceNumber ELSE ISNULL(I.strInvoiceOriginId, I.strInvoiceNumber) END
	  , strBOLNumber		= CASE WHEN I.strTransactionType = ''Customer Prepayment'' THEN ''Prepayment: '' + ISNULL(PCREDITS.strPaymentInfo, '''') ELSE ''BOL# '' + I.strBOLNumber END
      , dtmDate				= I.dtmDate
      , dtmDueDate			= I.dtmDueDate
	  , dtmShipDate			= I.dtmShipDate
	  , dblInvoiceTotal		= CASE WHEN I.strTransactionType IN (''Credit Memo'', ''Overpayment'', ''Customer Prepayment'') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END
	  , intPaymentId		= ISNULL(PD.intPaymentId, PCREDITS.intPaymentId)
	  , strRecordNumber		= ISNULL(PD.strRecordNumber, PCREDITS.strRecordNumber)
	  , strTransactionType  = I.strTransactionType
	  , strPaymentInfo	    = ''PAYMENT REF: '' + PD.strPaymentInfo
	  , dtmDatePaid			= ISNULL(PD.dtmDatePaid, PCREDITS.dtmDatePaid)
	  , dblPayment			= ISNULL(PD.dblPayment, 0) + ISNULL(PD.dblDiscount, 0) - ISNULL(PD.dblInterest, 0)
	  , dblBalance			= CASE WHEN I.strTransactionType IN (''Credit Memo'', ''Overpayment'', ''Customer Prepayment'') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END - ISNULL(TOTALPAYMENT.dblPayment, 0)
	  , strSalespersonName  = C.strSalesPersonName
	  , strAccountStatusCode = STATUSCODES.strAccountStatusCode
	  , strTicketNumbers	= I.strTicketNumbers
	  , strLocationName		= CL.strLocationName
	  , strFullAddress		= dbo.fnARFormatCustomerAddress('''', '''', C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, NULL)
	  , strStatementFooterComment	= dbo.fnARGetDefaultComment(NULL, I.intEntityCustomerId, ''Statement Report'', NULL, ''Footer'', NULL, 1)
	  , strCompanyName		= COMPANY.strCompanyName
	  , strCompanyAddress	= COMPANY.strCompanyAddress
	  , dblARBalance		= C.dblARBalance
	  , ysnStatementCreditLimit	= ysnStatementCreditLimit
FROM vyuARCustomerSearch C
	INNER JOIN #CUSTOMERS CUST ON C.intEntityCustomerId = CUST.intEntityCustomerId
	LEFT JOIN (
		SELECT intInvoiceId
			 , intEntityCustomerId
			 , intPaymentId
			 , intCompanyLocationId
			 , intTermId
			 , strInvoiceNumber
			 , strInvoiceOriginId
			 , strBOLNumber
			 , strTransactionType
			 , dblInvoiceTotal
			 , dtmDate
			 , dtmDueDate
			 , dtmShipDate
			 , ysnImportedFromOrigin
			 , strTicketNumbers = SCALETICKETS.strTicketNumbers
		FROM dbo.tblARInvoice I WITH (NOLOCK)
		OUTER APPLY (
			SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1)
			FROM (
				SELECT CAST(T.strTicketNumber AS VARCHAR(200))  + '', ''
				FROM dbo.tblARInvoiceDetail ID WITH(NOLOCK)		
				INNER JOIN (
					SELECT intTicketId
						 , strTicketNumber 
					FROM dbo.tblSCTicket WITH(NOLOCK)
				) T ON ID.intTicketId = T.intTicketId
				WHERE ID.intInvoiceId = I.intInvoiceId
				GROUP BY ID.intInvoiceId, ID.intTicketId, T.strTicketNumber
				FOR XML PATH ('''')
			) INV (strTicketNumber)
		) SCALETICKETS
		WHERE ysnPosted = 1
		AND ysnCancelled = 0
		AND I.strType <> ''CF Tran''
		AND ((strType = ''Service Charge'' AND ysnForgiven = 0) OR ((strType <> ''Service Charge'' AND ysnForgiven = 1) OR (strType <> ''Service Charge'' AND ysnForgiven = 0)))		
		AND (CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
				AND ((I.ysnPaid = 0 OR I.intInvoiceId IN (SELECT intInvoiceId 
														  FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) 
														  INNER JOIN (
																SELECT intPaymentId
																FROM dbo.tblARPayment WITH (NOLOCK)
																WHERE ysnPosted = 1
																  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
														  ) P ON PD.intPaymentId = P.intPaymentId))
				OR (I.ysnPaid = 1 AND I.intInvoiceId IN (SELECT intInvoiceId 
														 FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
														 INNER JOIN (
																SELECT intPaymentId
																FROM dbo.tblARPayment WITH (NOLOCK)
																WHERE ysnPosted = 1
																  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) > '+ @strDateTo +'
														 ) P ON PD.intPaymentId = P.intPaymentId))))
		AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN (''AR Account'', ''Customer Prepayments''))			
	) I ON I.intEntityCustomerId = C.intEntityId
	LEFT JOIN (
		SELECT intInvoiceId
			 , dblPayment
			 , dblDiscount
			 , dblInterest
		     , P.*
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) 
		INNER JOIN (SELECT intPaymentId
						 , strRecordNumber
						 , strPaymentInfo
						 , dtmDatePaid
					FROM dbo.tblARPayment WITH (NOLOCK)
					WHERE ysnPosted = 1
					  AND ysnInvoicePrepayment = 0
					  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= '+ @strDateTo +'
					  ' + CASE WHEN @ysnIncludeWriteOffPaymentLocal = 1 THEN 'AND intPaymentMethodId <> ' + CAST(@intWriteOffPaymentMethodId AS NVARCHAR(10)) + '' ELSE ' ' END + '
		) P ON PD.intPaymentId = P.intPaymentId
	) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (
		SELECT intPaymentId
			 , strPaymentInfo
			 , strRecordNumber
			 , dtmDatePaid
		FROM dbo.tblARPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
	) PCREDITS ON I.intPaymentId = PCREDITS.intPaymentId
	LEFT JOIN (
		SELECT dblPayment = SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest)
			 , intInvoiceId 
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
		INNER JOIN (SELECT intPaymentId
					FROM dbo.tblARPayment WITH (NOLOCK)
					WHERE ysnPosted = 1
					  AND ysnInvoicePrepayment = 0 
					  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= '+ @strDateTo +'
					  ' + CASE WHEN @ysnIncludeWriteOffPaymentLocal = 1 THEN 'AND intPaymentMethodId <> ' + CAST(@intWriteOffPaymentMethodId AS NVARCHAR(10)) + '' ELSE ' ' END + '
		) P ON PD.intPaymentId = P.intPaymentId
		GROUP BY intInvoiceId
	) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	LEFT JOIN (
		SELECT intTermID
			 , strTerm
		FROM dbo.tblSMTerm WITH (NOLOCK)
	) T ON I.intTermId = T.intTermID	
	LEFT JOIN (
		SELECT intCompanyLocationId
			 , strLocationName
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK) 
	) CL ON I.intCompanyLocationId = CL.intCompanyLocationId
	OUTER APPLY (
		SELECT TOP 1 strCompanyName
				   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](strPhone, '''', '''', strAddress, strCity, strState, strZip, strCountry, '''', NULL) 
		FROM dbo.tblSMCompanySetup WITH (NOLOCK)
	) COMPANY
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
			WHERE CAS.intEntityCustomerId = C.intEntityId
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
            'SELECT intEntityCustomerId         = C.intEntityCustomerId 
			      , strCustomerNumber           = C.strCustomerNumber
				  , strCustomerName             = C.strCustomerName
				  , dblCreditLimit              = C.dblCreditLimit
				  , intInvoiceId				= CB.intCustomerBudgetId
			      , strInvoiceNumber			= ''Budget for: '' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101) 
				  , strBOLNumber                = NULL
				  , dtmDate						= dtmBudgetDate
				  , dtmDueDate					= DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate))
				  , dtmShipDate					= NULL
				  , dblInvoiceTotal				= dblBudgetAmount
				  , intPaymentId				= NULL
				  , strRecordNumber				= ''Budget for: '' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101)
				  , strTransactionType			= ''Customer Budget''
				  , strPaymentInfo				= NULL
				  , dtmDatePaid					= NULL
				  , dblPayment					= dblAmountPaid
				  , dblBalance					= dblBudgetAmount - dblAmountPaid
				  , strSalespersonName			= NULL
				  , strAccountStatusCode		= STATUSCODES.strAccountStatusCode
				  , strTicketNumbers			= NULL
				  , strLocationName				= NULL
				  , strFullAddress				= NULL
				  , strStatementFooterComment	= NULL
				  , strCompanyName				= NULL
				  , strCompanyAddress			= NULL
				  , dblARBalance				= C.dblARBalance
				  , ysnStatementCreditLimit		= CUST.ysnStatementCreditLimit
            FROM tblARCustomerBudget CB
            INNER JOIN #CUSTOMERS C ON CB.intEntityCustomerId = C.intEntityCustomerId
			INNER JOIN (
				SELECT intEntityId
						, ysnStatementCreditLimit
				FROM dbo.tblARCustomer WITH (NOLOCK)
			) CUST ON CB.intEntityCustomerId = CUST.intEntityId
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

		IF EXISTS(SELECT TOP 1 NULL FROM @temp_statement_table WHERE strTransactionType = 'Customer Budget')
			BEGIN
				UPDATE STATEMENTS
				SET strCompanyAddress			= COMPLETESTATEMENTS.strCompanyAddress
				  , strCompanyName				= COMPLETESTATEMENTS.strCompanyName
				  , strStatementFooterComment	= COMPLETESTATEMENTS.strStatementFooterComment
				  , strLocationName				= COMPLETESTATEMENTS.strLocationName
				  , strFullAddress				= COMPLETESTATEMENTS.strFullAddress
				FROM @temp_statement_table STATEMENTS
				OUTER APPLY (
					SELECT TOP 1 strCompanyAddress
							   , strCompanyName
							   , strStatementFooterComment
							   , strLocationName
							   , strFullAddress
					FROM @temp_statement_table
					WHERE intEntityCustomerId = STATEMENTS.intEntityCustomerId
					  AND strCompanyAddress IS NOT NULL AND strCompanyName IS NOT NULL
				) COMPLETESTATEMENTS
				WHERE strTransactionType = 'Customer Budget'
			END
    END

IF @ysnPrintOnlyPastDueLocal = 1
    BEGIN        
		DELETE FROM @temp_statement_table WHERE DATEDIFF(DAYOFYEAR, dtmDueDate, @dtmDateToLocal) > 0        
    END

IF @ysnPrintZeroBalanceLocal = 0
    BEGIN
        DELETE FROM @temp_statement_table WHERE (((ABS(dblBalance) * 10000) - CONVERT(FLOAT, (ABS(dblBalance) * 10000))) <> 0) OR ISNULL(dblBalance, 0) = 0
		DELETE FROM tblARCustomerAgingStagingTable WHERE ((((ABS(dblTotalAR) * 10000) - CONVERT(FLOAT, (ABS(dblTotalAR) * 10000))) <> 0) OR ISNULL(dblTotalAR, 0) = 0) AND intEntityUserId = @intEntityUserIdLocal AND strAgingType = 'Summary'
    END

IF @ysnPrintCreditBalanceLocal = 0
	BEGIN
		DELETE FROM @temp_statement_table WHERE strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment')		 
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
) cfTable ON statementTable.intInvoiceId = cfTable.intInvoiceId

DELETE FROM @temp_statement_table
WHERE intInvoiceId IN (SELECT intInvoiceId FROM dbo.tblARInvoice WITH (NOLOCK) WHERE strType = 'CF Tran' AND strTransactionType NOT IN ('Debit Memo'))

MERGE INTO tblARStatementOfAccount AS Target
USING (SELECT strCustomerNumber, @dtmDateToLocal, SUM(ISNULL(dblBalance, 0))
FROM @temp_statement_table GROUP BY strCustomerNumber
)
AS Source (strCustomerNumber, dtmLastStatementDate, dblLastStatement)
ON Target.strEntityNo = Source.strCustomerNumber

WHEN MATCHED THEN
UPDATE SET dtmLastStatementDate = Source.dtmLastStatementDate, dblLastStatement = Source.dblLastStatement

WHEN NOT MATCHED BY TARGET THEN
INSERT (strEntityNo, dtmLastStatementDate, dblLastStatement)
VALUES (strCustomerNumber, dtmLastStatementDate, dblLastStatement);

DELETE FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserIdLocal AND strStatementFormat = 'Payment Activity'
INSERT INTO tblARCustomerStatementStagingTable (
	  intEntityCustomerId
	, strCustomerNumber
	, strCustomerName
	, dblCreditLimit
	, intInvoiceId
	, strInvoiceNumber
	, strBOLNumber
	, dtmDate
	, dtmDueDate
	, dtmShipDate
	, dblInvoiceTotal
	, intPaymentId
	, strRecordNumber
	, strPaymentInfo
	, dtmDatePaid
	, dblPayment
	, dblBalance
	, strSalespersonName
	, strAccountStatusCode
	, strLocationName
	, strFullAddress
	, strStatementFooterComment
	, strCompanyName
	, strCompanyAddress
	, ysnStatementCreditLimit
	, strTicketNumbers
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
	, blbLogo
	, intEntityUserId
	, strStatementFormat
)
SELECT MAINREPORT.*
	 , dblCreditAvailable			= MAINREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)
	 , dblFuture					= ISNULL(AGINGREPORT.dblFuture, 0)
	 , dbl0Days						= ISNULL(AGINGREPORT.dbl0Days, 0)
	 , dbl10Days					= ISNULL(AGINGREPORT.dbl10Days, 0)
	 , dbl30Days					= ISNULL(AGINGREPORT.dbl30Days, 0)
	 , dbl60Days					= ISNULL(AGINGREPORT.dbl60Days, 0)
	 , dbl90Days					= ISNULL(AGINGREPORT.dbl90Days, 0)
	 , dbl91Days					= ISNULL(AGINGREPORT.dbl91Days, 0)
	 , dblCredits					= ISNULL(AGINGREPORT.dblCredits, 0)
	 , dblPrepayments				= ISNULL(AGINGREPORT.dblPrepayments, 0)
	 , dtmAsOfDate					= @dtmDateToLocal
	 , blbLogo						= dbo.fnSMGetCompanyLogo('Header')
	 , intEntityUserId				= @intEntityUserIdLocal
	 , strStatementFormat			= 'Payment Activity'
FROM (
	--- Without CF Report
	SELECT intEntityCustomerId			= STATEMENTREPORT.intEntityCustomerId
		 , strCustomerNumber			= STATEMENTREPORT.strCustomerNumber
		 , strCustomerName				= STATEMENTREPORT.strCustomerName
		 , dblCreditLimit				= STATEMENTREPORT.dblCreditLimit
		 , intInvoiceId								 
		 , strInvoiceNumber
		 , strBOLNumber
		 , dtmDate
		 , dtmDueDate
		 , dtmShipDate
		 , dblInvoiceTotal
		 , intPaymentId
		 , strRecordNumber
		 , strPaymentInfo
		 , dtmDatePaid
		 , dblPayment
		 , dblBalance
		 , strSalespersonName			= STATEMENTREPORT.strSalespersonName
		 , strAccountStatusCode		
		 , strLocationName
		 , strFullAddress
		 , strStatementFooterComment	= STATEMENTREPORT.strStatementFooterComment
		 , strCompanyName
		 , strCompanyAddress
		 , ysnStatementCreditLimit		= STATEMENTREPORT.ysnStatementCreditLimit
		 , strTicketNumbers				= STATEMENTREPORT.strTicketNumbers
	FROM @temp_statement_table AS STATEMENTREPORT
	WHERE STATEMENTREPORT.intInvoiceId NOT IN (SELECT intInvoiceId FROM @temp_cf_table)

	UNION ALL

	--- With CF Report
	SELECT intEntityCustomerId			= STATEMENTREPORT.intEntityCustomerId
		 , strCustomerNumber			= STATEMENTREPORT.strCustomerNumber
		 , strCustomerName				= STATEMENTREPORT.strCustomerName
		 , dblCreditLimit				= STATEMENTREPORT.dblCreditLimit			
		 , intInvoiceId					= CFReportTable.intInvoiceId
		 , strInvoiceNumber				= CFReportTable.strInvoiceReportNumber
		 , strBOLNumber
		 , dtmDate						= CFReportTable.dtmInvoiceDate				
		 , dtmDueDate					= CFReportTable.dtmInvoiceDate
		 , dtmShipDate
		 , dblInvoiceTotal
		 , intPaymentId
		 , strRecordNumber
		 , strPaymentInfo
		 , dtmDatePaid
		 , dblPayment
		 , dblBalance
		 , strSalespersonName			= STATEMENTREPORT.strSalespersonName
		 , strAccountStatusCode
		 , strLocationName
		 , strFullAddress
		 , strStatementFooterComment	= STATEMENTREPORT.strStatementFooterComment			
		 , strCompanyName
		 , strCompanyAddress
		 , ysnStatementCreditLimit		= STATEMENTREPORT.ysnStatementCreditLimit
		 , strTicketNumbers				= STATEMENTREPORT.strTicketNumbers
	FROM @temp_statement_table AS STATEMENTREPORT
	INNER JOIN (
		SELECT intInvoiceId
			 , strInvoiceNumber
			 , strInvoiceReportNumber
			 , dtmInvoiceDate 
		FROM @temp_cf_table
	) CFReportTable ON STATEMENTREPORT.intInvoiceId = CFReportTable.intInvoiceId
) MAINREPORT
LEFT JOIN tblARCustomerAgingStagingTable AS AGINGREPORT 
	ON MAINREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
	AND AGINGREPORT.intEntityUserId = @intEntityUserIdLocal
	AND AGINGREPORT.strAgingType = 'Summary'
INNER JOIN #CUSTOMERS CUSTOMER ON MAINREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId


UPDATE tblARCustomerStatementStagingTable
SET strComment = dbo.fnEMEntityMessage(intEntityCustomerId, 'Statement')
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strStatementFormat = 'Payment Activity'