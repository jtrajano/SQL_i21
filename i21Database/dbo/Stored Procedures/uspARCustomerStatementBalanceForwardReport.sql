CREATE PROCEDURE [dbo].[uspARCustomerStatementBalanceForwardReport]
	  @dtmDateTo					AS DATETIME			= NULL
	, @dtmDateFrom					AS DATETIME			= NULL
	, @dtmBalanceForwardDate		AS DATETIME			= NULL
	, @ysnPrintZeroBalance			AS BIT				= 0
	, @ysnPrintCreditBalance		AS BIT				= 1
	, @ysnIncludeBudget				AS BIT				= 0
	, @ysnPrintOnlyPastDue			AS BIT				= 0
	, @ysnActiveCustomers			AS BIT				= 0
	, @ysnPrintFromCF				AS BIT				= 0
	, @strCustomerNumber			AS NVARCHAR(MAX)	= NULL
	, @strAccountStatusCode			AS NVARCHAR(MAX)	= NULL
	, @strLocationName				AS NVARCHAR(MAX)	= NULL
	, @strCustomerName				AS NVARCHAR(MAX)	= NULL
	, @strCustomerIds				AS NVARCHAR(MAX)	= NULL
	, @ysnEmailOnly					AS BIT				= NULL
	, @ysnIncludeWriteOffPayment    AS BIT 				= 1
	, @ysnReprintInvoice			AS BIT				= 1
	, @intEntityUserId				AS INT				= NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dtmDateToLocal						AS DATETIME			= NULL
	  , @dtmDateFromLocal					AS DATETIME			= NULL
	  , @dtmBalanceForwardDateLocal			AS DATETIME			= NULL
	  , @ysnPrintZeroBalanceLocal			AS BIT				= 0
	  , @ysnPrintCreditBalanceLocal			AS BIT				= 1
	  , @ysnIncludeBudgetLocal				AS BIT				= 0
	  , @ysnPrintOnlyPastDueLocal			AS BIT				= 0
	  , @ysnActiveCustomersLocal			AS BIT				= 0
	  , @ysnIncludeWriteOffPaymentLocal		AS BIT				= 1
	  , @ysnPrintFromCFLocal				AS BIT				= 0
	  , @ysnReprintInvoiceLocal				AS BIT				= 1
	  , @strCustomerNumberLocal				AS NVARCHAR(MAX)	= NULL
	  , @strAccountStatusCodeLocal			AS NVARCHAR(MAX)	= NULL
	  , @strLocationNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCustomerNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCustomerIdsLocal				AS NVARCHAR(MAX)	= NULL
	  , @strDateTo							AS NVARCHAR(50)
	  , @strDateFrom						AS NVARCHAR(50)
	  , @query								AS NVARCHAR(MAX)
	  , @queryBudget						AS NVARCHAR(MAX)
	  , @queryForCF							AS NVARCHAR(MAX)
	  , @queryForNonCF						AS NVARCHAR(MAX)
	  , @queryBalanceForward				AS NVARCHAR(MAX)
	  , @filter								AS NVARCHAR(MAX)	= ''
	  , @intWriteOffPaymentMethodId			AS INT				= NULL
	  , @intEntityUserIdLocal				AS INT				= NULL

DECLARE @temp_aging_table TABLE(
     [strCustomerName]          NVARCHAR(100)
    ,[strEntityNo]              NVARCHAR(100)
	,[strCustomerInfo]			NVARCHAR(200)
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
	,[strComment]					NVARCHAR(MAX)
	,[strStatementFooterComment]	NVARCHAR(MAX)
    ,[strCompanyName]				NVARCHAR(MAX)
    ,[strCompanyAddress]			NVARCHAR(MAX)
	,[dblARBalance]					NUMERIC(18,6)
	,[ysnStatementCreditLimit]		BIT
	,[strType]						NVARCHAR(100)
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
SET @dtmBalanceForwardDateLocal			= ISNULL(@dtmBalanceForwardDate, @dtmDateFromLocal)
SET @ysnPrintZeroBalanceLocal			= ISNULL(@ysnPrintZeroBalance, 0)
SET @ysnPrintCreditBalanceLocal			= ISNULL(@ysnPrintCreditBalance, 1)
SET @ysnIncludeBudgetLocal				= ISNULL(@ysnIncludeBudget, 0)
SET @ysnPrintOnlyPastDueLocal			= ISNULL(@ysnPrintOnlyPastDue, 0)
SET @ysnActiveCustomersLocal			= ISNULL(@ysnActiveCustomers, 0)
SET @ysnIncludeWriteOffPaymentLocal		= ISNULL(@ysnIncludeWriteOffPayment, 1)
SET @ysnPrintFromCFLocal				= ISNULL(@ysnPrintFromCF, 0)
SET @ysnReprintInvoiceLocal				= ISNULL(@ysnReprintInvoice, 1)
SET @strCustomerNumberLocal				= NULLIF(@strCustomerNumber, '')
SET @strAccountStatusCodeLocal			= NULLIF(@strAccountStatusCode, '')
SET @strLocationNameLocal				= NULLIF(@strLocationName, '')
SET @strCustomerNameLocal				= NULLIF(@strCustomerName, '')
SET @strCustomerIdsLocal				= NULLIF(@strCustomerIds, '')
SET @dtmDateFromLocal					= DATEADD(DAYOFYEAR, 1, @dtmBalanceForwardDateLocal)
SET @strDateTo							= ''''+ CONVERT(NVARCHAR(50),@dtmDateToLocal, 110) + ''''
SET @strDateFrom						= ''''+ CONVERT(NVARCHAR(50),@dtmDateFromLocal, 110) + ''''
SET @intEntityUserIdLocal				= NULLIF(@intEntityUserId, 0)

IF @strCustomerNumberLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT TOP 1 intEntityCustomerId	= C.intEntityId 
			       , strCustomerNumber		= C.strCustomerNumber
				   , strCustomerName		= EC.strName
				   , strStatementFormat	= C.strStatementFormat
				   , dblCreditLimit			= C.dblCreditLimit
				   , dblARBalance			= C.dblARBalance		
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
			     , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE strEntityNo = @strCustomerNumberLocal
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 )) OR @ysnActiveCustomersLocal = 0)
		  AND C.strStatementFormat = 'Balance Forward'
	END
ELSE IF @strCustomerIdsLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT intEntityCustomerId	= C.intEntityId 
			 , strCustomerNumber	= C.strCustomerNumber
			 , strCustomerName      = EC.strName
			 , strStatementFormat	= C.strStatementFormat
			 , dblCreditLimit       = C.dblCreditLimit
			 , dblARBalance			= C.dblARBalance        
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
			AND C.strStatementFormat = 'Balance Forward'
	END
ELSE
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT intEntityCustomerId	= C.intEntityId 
			 , strCustomerNumber	= C.strCustomerNumber
			 , strCustomerName		= EC.strName
			 , strStatementFormat	= C.strStatementFormat
			 , dblCreditLimit		= C.dblCreditLimit
			 , dblARBalance			= C.dblARBalance
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
				 , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE (@strCustomerNameLocal IS NULL OR strName = @strCustomerNameLocal)
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 )) OR @ysnActiveCustomersLocal = 0)
		  AND C.strStatementFormat = 'Balance Forward'
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
	
EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateTo = @dtmDateToLocal
										  , @strCompanyLocation = @strLocationNameLocal
										  , @strCustomerName = @strCustomerNameLocal
										  , @ysnIncludeWriteOffPayment = @ysnIncludeWriteOffPaymentLocal
										  , @intEntityUserId = @intEntityUserIdLocal

INSERT INTO @temp_aging_table
SELECT strCustomerName
		, strCustomerNumber
		, strCustomerInfo
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
FROM tblARCustomerAgingStagingTable
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strAgingType = 'Summary'

EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateTo = @dtmBalanceForwardDateLocal
										  , @strCompanyLocation = @strLocationNameLocal											
										  , @strCustomerName = @strCustomerNameLocal
										  , @ysnIncludeWriteOffPayment = @ysnIncludeWriteOffPaymentLocal
										  , @intEntityUserId = @intEntityUserIdLocal

INSERT INTO @temp_balanceforward_table
SELECT strCustomerName
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
FROM tblARCustomerAgingStagingTable
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strAgingType = 'Summary'

SET @queryForCF = CAST('' AS NVARCHAR(MAX)) + '
SELECT intInvoiceId			= NULL
	 , intEntityCustomerId	= P.intEntityCustomerId
	 , intPaymentId			= P.intPaymentId
	 , intCompanyLocationId	= P.intLocationId
	 , intTermId			= NULL
	 , strInvoiceNumber		= NULL
	 , strRecordNumber		= P.strRecordNumber
	 , strInvoiceOriginId   = NULL
	 , strBOLNumber			= NULL
	 , strPaymentInfo		= ''PAYMENT REF: '' + ISNULL(P.strPaymentInfo, '''')
	 , strTransactionType	= ''Payment''
	 , dblInvoiceTotal		= 0.00
	 , dblBalance			= 0.00
	 , dblPayment			= P.dblAmountPaid
	 , dtmDate				= P.dtmDatePaid
	 , dtmDueDate			= NULL
	 , dtmShipDate			= NULL
	 , dtmDatePaid			= P.dtmDatePaid
	 , strType				= NULL
	 , strComment			= ISNULL(P.strPaymentInfo, '''') + CASE WHEN ISNULL(P.strNotes, '''') <> '''' THEN '' - '' + P.strNotes ELSE '''' END
	 , strTicketNumbers		= NULL
FROM dbo.tblARPayment P WITH (NOLOCK)
INNER JOIN (
	SELECT intPaymentId
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
	INNER JOIN (
		SELECT intInvoiceId
		FROM dbo.tblARInvoice WITH (NOLOCK)
		WHERE ysnPosted = 1
			AND strType <> ''CF Tran''
	) I ON I.intInvoiceId = PD.intInvoiceId
) PD ON P.intPaymentId = PD.intPaymentId
WHERE ysnInvoicePrepayment = 0
  AND ysnPosted = 1
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'  
GROUP BY P.intPaymentId, intEntityCustomerId, intLocationId, strRecordNumber, strPaymentInfo, dblAmountPaid, dtmDatePaid, strNotes

UNION ALL

SELECT intInvoiceId			= NULL
	 , intEntityCustomerId	= P.intEntityCustomerId
	 , intPaymentId			= P.intPaymentId
	 , intCompanyLocationId	= P.intLocationId
	 , intTermId			= NULL
	 , strInvoiceNumber		= NULL
	 , strRecordNumber		= P.strRecordNumber
	 , strInvoiceOriginId	= NULL
	 , strBOLNumber			= NULL
	 , strPaymentInfo		= ''PAYMENT REF: '' + ISNULL(P.strPaymentInfo, '''')
	 , strTransactionType	= ''Discount Taken''
	 , dblInvoiceTotal		= 0.00
	 , dblBalance			= 0.00
	 , dblPayment			= ISNULL(PD.dblDiscountTaken, 0)
	 , dtmDate				= P.dtmDatePaid
	 , dtmDueDate			= NULL
	 , dtmShipDate			= NULL
	 , dtmDatePaid			= P.dtmDatePaid
	 , strType				= NULL
	 , strComment			= ISNULL(P.strPaymentInfo, '''') + CASE WHEN ISNULL(P.strNotes, '''') <> '''' THEN '' - '' + P.strNotes ELSE '''' END
	 , strTicketNumbers		= NULL
FROM dbo.tblARPayment P WITH (NOLOCK)
INNER JOIN (
	SELECT intPaymentId
		 , dblDiscountTaken = SUM(PD.dblDiscount)
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
	INNER JOIN (
		SELECT intInvoiceId
		FROM dbo.tblARInvoice WITH (NOLOCK)
		WHERE ysnPosted = 1
			AND strType <> ''CF Tran''
	) I ON I.intInvoiceId = PD.intInvoiceId
	WHERE dblDiscount > 0
	GROUP BY intPaymentId
) PD ON P.intPaymentId = PD.intPaymentId
WHERE ysnInvoicePrepayment = 0
  AND ysnPosted = 1
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
GROUP BY P.intPaymentId, intEntityCustomerId, intLocationId, strRecordNumber, strPaymentInfo, dblAmountPaid, dtmDatePaid, PD.dblDiscountTaken, strNotes'

SET @queryForNonCF = CAST('' AS NVARCHAR(MAX)) + '
SELECT intInvoiceId			= NULL
	 , intEntityCustomerId	= P.intEntityCustomerId
	 , intPaymentId			= P.intPaymentId
	 , intCompanyLocationId	= P.intLocationId
	 , intTermId			= NULL
	 , strInvoiceNumber		= NULL
	 , strRecordNumber		= P.strRecordNumber + '' - '' + ISNULL(PD.strInvoiceNumber , '''')
	 , strInvoiceOriginId   = NULL
	 , strBOLNumber			= NULL
	 , strPaymentInfo		= ''PAYMENT REF: '' + ISNULL(P.strPaymentInfo, '''')
	 , strTransactionType	= ''Payment''
	 , dblInvoiceTotal		= 0.00
	 , dblBalance			= 0.00
	 , dblPayment			= SUM(PD.dblPayment)
	 , dtmDate				= P.dtmDatePaid
	 , dtmDueDate			= NULL
	 , dtmShipDate			= NULL
	 , dtmDatePaid			= P.dtmDatePaid
	 , strType				= NULL
	 , strComment			= ISNULL(P.strPaymentInfo, '''') + CASE WHEN ISNULL(P.strNotes, '''') <> '''' THEN '' - '' + P.strNotes ELSE '''' END
	 , strTicketNumbers		= NULL
FROM dbo.tblARPayment P WITH (NOLOCK)
INNER JOIN (
	SELECT PD.intPaymentId
	     , PD.intInvoiceId
		 , I.strInvoiceNumber
	     , dblPayment = SUM(PD.dblPayment) + SUM(PD.dblDiscount) - SUM(PD.dblInterest) 
		 , I.dblInvoiceTotal
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
	INNER JOIN (
		SELECT intInvoiceId
		     , strInvoiceNumber
			 , dblInvoiceTotal	 = CASE WHEN dtmDate BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +' THEN dblInvoiceTotal ELSE 0 END 
		FROM dbo.tblARInvoice WITH (NOLOCK)
		WHERE ysnPosted = 1
			AND ((strType = ''Service Charge'' AND ysnForgiven = 0) OR ((strType <> ''Service Charge'' AND ysnForgiven = 1) OR (strType <> ''Service Charge'' AND ysnForgiven = 0)))
			AND strType <> ''CF Tran''
	) I ON I.intInvoiceId = PD.intInvoiceId	
	GROUP BY intPaymentId, PD.intInvoiceId, I.strInvoiceNumber, I.dblInvoiceTotal	
) PD ON P.intPaymentId = PD.intPaymentId
LEFT JOIN (
	SELECT dblPayment = SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest)
			, intInvoiceId 
	FROM tblARPaymentDetail PD WITH (NOLOCK) 
	INNER JOIN (
		SELECT intPaymentId
		FROM dbo.tblARPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
		  AND ysnInvoicePrepayment = 0 
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= '+ @strDateTo +'
	) P ON PD.intPaymentId = P.intPaymentId
	GROUP BY intInvoiceId
) TOTALPAYMENT ON PD.intInvoiceId = TOTALPAYMENT.intInvoiceId
WHERE ysnInvoicePrepayment = 0
  AND ysnPosted = 1
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
  AND PD.dblInvoiceTotal - ABS(ISNULL(TOTALPAYMENT.dblPayment, 0)) <> 0
  ' + CASE WHEN @ysnIncludeWriteOffPaymentLocal = 1 THEN 'AND P.intPaymentMethodId <> ' + CAST(@intWriteOffPaymentMethodId AS NVARCHAR(10)) + '' ELSE ' ' END + '
GROUP BY P.intPaymentId, intEntityCustomerId, intLocationId, strRecordNumber, strPaymentInfo, dblAmountPaid, dtmDatePaid, PD.intInvoiceId, strInvoiceNumber, strNotes'

SET @query = CAST('' AS NVARCHAR(MAX)) + 'SELECT * FROM
(SELECT intEntityCustomerId	= C.intEntityCustomerId
	  , strCustomerNumber	= C.strCustomerNumber
	  , strCustomerName		= C.strName
	  , dblCreditLimit		= C.dblCreditLimit
	  , intInvoiceId		= TRANSACTIONS.intInvoiceId
	  , strInvoiceNumber	= TRANSACTIONS.strInvoiceNumber
	  , strBOLNumber		= CASE WHEN TRANSACTIONS.strTransactionType = ''Customer Prepayment'' THEN ''Prepayment: '' + ISNULL(TRANSACTIONS.strPaymentInfo, '''') ELSE ''BOL# '' + TRANSACTIONS.strBOLNumber END
      , dtmDate				= TRANSACTIONS.dtmDate
      , dtmDueDate			= TRANSACTIONS.dtmDueDate
	  , dtmShipDate			= TRANSACTIONS.dtmShipDate
	  , dblInvoiceTotal		= TRANSACTIONS.dblInvoiceTotal
	  , intPaymentId		= TRANSACTIONS.intPaymentId
	  , strRecordNumber		= TRANSACTIONS.strRecordNumber
	  , strTransactionType  = TRANSACTIONS.strTransactionType
	  , strPaymentInfo	    = TRANSACTIONS.strPaymentInfo
	  , dtmDatePaid			= ISNULL(TRANSACTIONS.dtmDatePaid, ''01/02/1900'')
	  , dblPayment			= ISNULL(TRANSACTIONS.dblPayment, 0)
	  , dblBalance			= TRANSACTIONS.dblBalance
	  , strSalespersonName  = C.strSalesPersonName
	  , strAccountStatusCode = STATUSCODES.strAccountStatusCode
	  , strTicketNumbers	= TRANSACTIONS.strTicketNumbers
	  , strLocationName		= CL.strLocationName
	  , strFullAddress		= dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, NULL)
	  , strComment			= TRANSACTIONS.strComment
	  , strStatementFooterComment	= dbo.fnARGetDefaultComment(NULL, TRANSACTIONS.intEntityCustomerId, ''Statement Report'', NULL, ''Footer'', NULL, 1)
	  , strCompanyName		= COMPANY.strCompanyName
	  , strCompanyAddress	= COMPANY.strCompanyAddress
	  , dblARBalance		= C.dblARBalance
	  , ysnStatementCreditLimit	= ysnStatementCreditLimit
	  , strType				= TRANSACTIONS.strType
FROM vyuARCustomerSearch C
	INNER JOIN #CUSTOMERS CUST ON C.intEntityCustomerId = CUST.intEntityCustomerId
	LEFT JOIN (
		SELECT intInvoiceId			= I.intInvoiceId
			 , intEntityCustomerId	= I.intEntityCustomerId
			 , intPaymentId			= PCREDITS.intPaymentId
			 , intCompanyLocationId	= I.intCompanyLocationId
			 , intTermId			= I.intTermId
			 , strInvoiceNumber		= CASE WHEN ISNULL(I.ysnImportedFromOrigin, 0) = 0 THEN I.strInvoiceNumber ELSE ISNULL(I.strInvoiceOriginId, I.strInvoiceNumber) END
			 , strRecordNumber		= PCREDITS.strRecordNumber
			 , strInvoiceOriginId   = I.strInvoiceOriginId
			 , strBOLNumber			= I.strBOLNumber
			 , strPaymentInfo		= PCREDITS.strPaymentInfo
			 , strTransactionType	= I.strTransactionType
			 , dblInvoiceTotal		= CASE WHEN strTransactionType IN (''Credit Memo'', ''Overpayment'') THEN I.dblInvoiceTotal * -1
										   WHEN strTransactionType = ''Customer Prepayment'' THEN 0.00 
										   ELSE I.dblInvoiceTotal 
									  END
			 , dblBalance			= CASE WHEN strTransactionType IN (''Credit Memo'', ''Overpayment'') THEN I.dblInvoiceTotal * -1
										   WHEN strTransactionType = ''Customer Prepayment'' THEN 0.00
										   ELSE I.dblInvoiceTotal 
									  END - ISNULL(TOTALPAYMENT.dblPayment, 0)
			 , dblPayment			= CASE WHEN strTransactionType = ''Customer Prepayment'' THEN I.dblInvoiceTotal ELSE ' + CASE WHEN @ysnPrintFromCFLocal = 1 THEN '0.00' ELSE 'CASE WHEN dbo.fnARGetInvoiceAmountMultiplier(strTransactionType) * I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) = 0 THEN ISNULL(TOTALPAYMENT.dblPayment, 0) ELSE 0.00 END' END +' END
			 , dtmDate				= I.dtmDate
			 , dtmDueDate			= I.dtmDueDate
			 , dtmShipDate			= I.dtmShipDate
			 , dtmDatePaid			= PCREDITS.dtmDatePaid
			 , strType				= I.strType
			 , strComment			= I.strComments
			 , strTicketNumbers		= SCALETICKETS.strTicketNumbers
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
		LEFT JOIN (
			SELECT dblPayment = SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest)
				 , intInvoiceId 
			FROM tblARPaymentDetail PD WITH (NOLOCK) 
			INNER JOIN (
				SELECT intPaymentId
				FROM dbo.tblARPayment WITH (NOLOCK)
				WHERE ysnPosted = 1
				  AND ysnInvoicePrepayment = 0 
				  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= '+ @strDateTo +'
				  ' + CASE WHEN @ysnIncludeWriteOffPaymentLocal = 1 THEN 'AND intPaymentMethodId <> ' + CAST(@intWriteOffPaymentMethodId AS NVARCHAR(10)) + '' ELSE ' ' END + '
			) P ON PD.intPaymentId = P.intPaymentId
			GROUP BY intInvoiceId
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
		LEFT JOIN (
			SELECT intPaymentId
				 , strPaymentInfo
				 , strRecordNumber
				 , dtmDatePaid
			FROM dbo.tblARPayment WITH (NOLOCK)
			WHERE ysnPosted = 1
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
		) PCREDITS ON I.intPaymentId = PCREDITS.intPaymentId
		WHERE ysnPosted = 1
			AND ((I.strType = ''Service Charge'' AND I.ysnForgiven = 0) OR ((I.strType <> ''Service Charge'' AND I.ysnForgiven = 1) OR (I.strType <> ''Service Charge'' AND I.ysnForgiven = 0)))		
			AND I.dtmDate BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
			AND I.strType <> ''CF Tran''
			AND (CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= '+ @strDateTo +'
				AND ((I.ysnPaid = 0 OR I.intInvoiceId IN (SELECT intInvoiceId 
															FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) 
															INNER JOIN (
																SELECT intPaymentId
																FROM dbo.tblARPayment WITH (NOLOCK)
																WHERE ysnPosted = 1
																	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= '+ @strDateTo +'																	
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

		UNION ALL ' + CASE WHEN @ysnPrintFromCF = 1 THEN @queryForCF ELSE @queryForNonCF END +

	') TRANSACTIONS ON TRANSACTIONS.intEntityCustomerId = C.intEntityId
	LEFT JOIN (
		SELECT intTermID
			 , strTerm
		FROM dbo.tblSMTerm WITH (NOLOCK)
	) T ON TRANSACTIONS.intTermId = T.intTermID	
	LEFT JOIN (
		SELECT intCompanyLocationId
			 , strLocationName
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK) 
	) CL ON TRANSACTIONS.intCompanyLocationId = CL.intCompanyLocationId
	OUTER APPLY (
		SELECT TOP 1 strCompanyName
				   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](strPhone, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) 
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
			WHERE CAS.intEntityCustomerId = C.intEntityCustomerId
			FOR XML PATH ('''')
		) SC (strAccountStatusCode)
	) STATUSCODES
) MainQuery'

IF ISNULL(@filter, '') != ''
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
				  , intPaymentId				= CB.intCustomerBudgetId
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
				  , strType						= NULL
				  , strComment					= NULL
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

IF @ysnPrintFromCFLocal = 1
	BEGIN
		UPDATE @temp_balanceforward_table SET dblTotalAR = dblTotalAR - dblFuture

		UPDATE AGINGREPORT
		SET AGINGREPORT.dbl0Days = AGINGREPORT.dbl0Days + ISNULL(CF.dblTotalFuture, 0)
		  , AGINGREPORT.dblFuture = AGINGREPORT.dblFuture - ISNULL(CF.dblTotalFuture, 0)
		FROM @temp_aging_table AGINGREPORT
		INNER JOIN (
			SELECT intEntityCustomerId
				 , dblTotalFuture = SUM(dbo.fnARGetInvoiceAmountMultiplier(strTransactionType) * dblAmountDue)
			FROM tblARInvoice WITH (NOLOCK)
			WHERE strType = 'CF Tran'
			AND ysnPaid = 0
			AND ysnPosted = 1
			AND intInvoiceId IN (SELECT intInvoiceId FROM tblCFInvoiceStagingTable)
			GROUP BY intEntityCustomerId
		) CF ON AGINGREPORT.intEntityCustomerId = CF.intEntityCustomerId

		IF @ysnReprintInvoiceLocal = 0
			BEGIN
				UPDATE AGINGREPORT
				SET AGINGREPORT.dbl0Days = AGINGREPORT.dbl0Days + ISNULL(CF.dblTotalFee, 0)
				  , AGINGREPORT.dblTotalAR = AGINGREPORT.dblTotalAR + ISNULL(CF.dblTotalFee, 0)
				FROM @temp_aging_table AGINGREPORT
				INNER JOIN (
					SELECT intCustomerId
						 , dblTotalFee = SUM(dblFeeTotalAmount)
					FROM dbo.tblCFInvoiceFeeStagingTable WITH (NOLOCK)
					GROUP BY intCustomerId
				) CF ON AGINGREPORT.intEntityCustomerId = CF.intCustomerId
			END
		ELSE
			BEGIN
				UPDATE AGINGREPORT
				SET AGINGREPORT.dblFuture = 0.000000
				  , AGINGREPORT.dblTotalAR = AGINGREPORT.dblTotalAR - ISNULL(AGINGREPORT.dblFuture, 0)
				FROM @temp_aging_table AGINGREPORT
				WHERE ISNULL(AGINGREPORT.dblFuture, 0) <> 0
			END
	END
ELSE 
	BEGIN
		UPDATE @temp_statement_table SET dblBalance = dblPayment * -1 WHERE strTransactionType IN ('Customer Prepayment', 'Payment')
		UPDATE @temp_statement_table SET dblBalance = dblInvoiceTotal WHERE strTransactionType IN ('Invoice', 'Debit Memo') AND dblBalance <> 0
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
	, strFullAddress
	, strStatementFooterComment
	, strCompanyAddress
	, strCompanyName
)
SELECT DISTINCT
	  ISNULL(BALANCEFORWARD.intEntityCustomerId, STATEMENTFORWARD.intEntityCustomerId)
	, ISNULL(BALANCEFORWARD.strCustomerName, STATEMENTFORWARD.strCustomerName)
	, ISNULL(BALANCEFORWARD.strEntityNo, STATEMENTFORWARD.strCustomerNumber)
	, 'Balance Forward'
	, ISNULL(BALANCEFORWARD.dblCreditLimit, STATEMENTFORWARD.dblCreditLimit)
	, @dtmBalanceForwardDateLocal
	, '01/01/1900'
	, 1
	, ISNULL(BALANCEFORWARD.dblTotalAR, 0)
	, 0
	, STATEMENTFORWARD.strFullAddress
	, STATEMENTFORWARD.strStatementFooterComment
	, STATEMENTFORWARD.strCompanyAddress
	, STATEMENTFORWARD.strCompanyName
FROM @temp_statement_table STATEMENTFORWARD
    LEFT JOIN @temp_balanceforward_table BALANCEFORWARD ON STATEMENTFORWARD.intEntityCustomerId = BALANCEFORWARD.intEntityCustomerId    

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

IF @ysnPrintOnlyPastDueLocal = 1
    BEGIN
        DELETE FROM @temp_statement_table WHERE DATEDIFF(DAYOFYEAR, dtmDueDate, @dtmDateToLocal) > 0 AND strTransactionType <> 'Balance Forward'        
    END

IF @ysnPrintZeroBalanceLocal = 0
    BEGIN
        DELETE FROM @temp_statement_table WHERE ((((ABS(dblBalance) * 10000) - CONVERT(FLOAT, (ABS(dblBalance) * 10000))) <> 0) OR ISNULL(dblBalance, 0) = 0) AND ISNULL(strTransactionType, '') <> 'Balance Forward'
		DELETE FROM @temp_aging_table WHERE (((ABS(dblTotalAR) * 10000) - CONVERT(FLOAT, (ABS(dblTotalAR) * 10000))) <> 0) OR ISNULL(dblTotalAR, 0) = 0
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

DELETE FROM @temp_statement_table WHERE strTransactionType IS NULL

DELETE FROM @temp_statement_table
WHERE intInvoiceId IN (SELECT intInvoiceId FROM dbo.tblARInvoice WITH (NOLOCK) WHERE strType = 'CF Tran' AND strTransactionType NOT IN ('Debit Memo'))

IF @ysnPrintFromCFLocal = 1
	BEGIN
		DELETE FROM @temp_statement_table WHERE strTransactionType = 'Overpayment'
		DELETE FROM @temp_statement_table WHERE strTransactionType = 'Payment' AND dblPayment = 0
		UPDATE @temp_statement_table SET strTransactionType = 'Payment' WHERE strTransactionType = 'Customer Prepayment' AND strType <> 'CF Tran'
		UPDATE @temp_statement_table SET strTransactionType = 'Invoice' WHERE strTransactionType = 'Debit Memo' AND strType <> 'CF Tran'
		UPDATE @temp_statement_table SET strTransactionType = 'Service Charge' WHERE strType = 'Service Charge'
		DELETE FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserIdLocal AND ISNULL(strStatementFormat, 'Balance Forward') = 'Balance Forward'
	END
ELSE
	BEGIN
		DELETE FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserIdLocal AND strStatementFormat = 'Balance Forward'
	END
	
INSERT INTO tblARCustomerStatementStagingTable (
	  intEntityCustomerId
	, intInvoiceId
	, intPaymentId
	, intEntityUserId
	, dtmDate
	, dtmDueDate
	, dtmShipDate
	, dtmDatePaid
	, dtmAsOfDate
	, strCustomerNumber
	, strCustomerName
	, strInvoiceNumber		
	, strBOLNumber
	, strRecordNumber
	, strTransactionType
	, strPaymentInfo
	, strSalespersonName
	, strAccountStatusCode
	, strLocationName
	, strFullAddress
	, strComment
	, strStatementFooterComment
	, strCompanyName
	, strCompanyAddress
	, strStatementFormat
	, dblCreditLimit
	, dblInvoiceTotal
	, dblPayment
	, dblBalance
	, dblTotalAR
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
	, ysnStatementCreditLimit
	, blbLogo
	, strTicketNumbers
)
SELECT intEntityCustomerId		= MAINREPORT.intEntityCustomerId
	, intInvoiceId				= MAINREPORT.intInvoiceId
	, intPaymentId				= MAINREPORT.intPaymentId
	, intEntityUserId			= @intEntityUserId
	, dtmDate					= MAINREPORT.dtmDate
	, dtmDueDate				= MAINREPORT.dtmDueDate
	, dtmShipDate				= MAINREPORT.dtmShipDate
	, dtmDatePaid				= MAINREPORT.dtmDatePaid
	, dtmAsOfDate				= @dtmDateToLocal
	, strCustomerNumber			= MAINREPORT.strCustomerNumber
	, strCustomerName			= MAINREPORT.strCustomerName
	, strInvoiceNumber			= MAINREPORT.strInvoiceNumber
	, strBOLNumber				= MAINREPORT.strBOLNumber
	, strRecordNumber			= MAINREPORT.strRecordNumber
	, strTransactionType		= MAINREPORT.strTransactionType
	, strPaymentInfo			= MAINREPORT.strPaymentInfo
	, strSalespersonName		= MAINREPORT.strSalespersonName
	, strAccountStatusCode		= MAINREPORT.strAccountStatusCode
	, strLocationName			= MAINREPORT.strLocationName
	, strFullAddress			= MAINREPORT.strFullAddress
	, strComment				= MAINREPORT.strComment
	, strStatementFooterComment	= MAINREPORT.strStatementFooterComment
	, strCompanyName			= MAINREPORT.strCompanyName
	, strCompanyAddress			= MAINREPORT.strCompanyAddress
	, strStatementFormat		= 'Balance Forward'
	, dblCreditLimit			= MAINREPORT.dblCreditLimit
	, dblInvoiceTotal			= MAINREPORT.dblInvoiceTotal
	, dblPayment				= MAINREPORT.dblPayment
	, dblBalance				= MAINREPORT.dblBalance
	, dblTotalAR				= ISNULL(AGINGREPORT.dblTotalAR, 0)
	, dblCreditAvailable		= MAINREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)
	, dblFuture					= ISNULL(AGINGREPORT.dblFuture, 0)
	, dbl0Days					= ISNULL(AGINGREPORT.dbl0Days, 0)
	, dbl10Days					= ISNULL(AGINGREPORT.dbl10Days, 0)
	, dbl30Days					= ISNULL(AGINGREPORT.dbl30Days, 0)
	, dbl60Days					= ISNULL(AGINGREPORT.dbl60Days, 0)
	, dbl90Days					= ISNULL(AGINGREPORT.dbl90Days, 0)
	, dbl91Days					= ISNULL(AGINGREPORT.dbl91Days, 0)
	, dblCredits				= ISNULL(AGINGREPORT.dblCredits, 0)
	, dblPrepayments			= ISNULL(AGINGREPORT.dblPrepayments, 0)	
	, ysnStatementCreditLimit	= MAINREPORT.ysnStatementCreditLimit
	, blbLogo					= dbo.fnSMGetCompanyLogo('Header')
	, strTicketNumbers			= MAINREPORT.strTicketNumbers
FROM (
	--- Without CF Report
	SELECT intEntityCustomerId					= STATEMENTREPORT.intEntityCustomerId
		 , strCustomerNumber					= STATEMENTREPORT.strCustomerNumber
		 , strCustomerName						= STATEMENTREPORT.strCustomerName
		 , dblCreditLimit						= STATEMENTREPORT.dblCreditLimit
		 , intInvoiceId							= STATEMENTREPORT.intInvoiceId   
		 , strInvoiceNumber
		 , strBOLNumber
		 , dtmDate
		 , dtmDueDate
		 , dtmShipDate
		 , dblInvoiceTotal
		 , intPaymentId
		 , strRecordNumber
		 , strTransactionType					= STATEMENTREPORT.strTransactionType
		 , strPaymentInfo
		 , dtmDatePaid
		 , dblPayment
		 , dblBalance
		 , strSalespersonName					= STATEMENTREPORT.strSalespersonName
		 , strAccountStatusCode
		 , strLocationName
		 , strFullAddress
		 , strComment							= STATEMENTREPORT.strComment
		 , strStatementFooterComment			= STATEMENTREPORT.strStatementFooterComment
		 , strCompanyName
		 , strCompanyAddress
		 , ysnStatementCreditLimit
		 , strTicketNumbers		 
	FROM @temp_statement_table AS STATEMENTREPORT	
	WHERE STATEMENTREPORT.intInvoiceId NOT IN (SELECT intInvoiceId FROM @temp_cf_table)

	UNION ALL

	--- With CF Report
	SELECT intEntityCustomerId					= STATEMENTREPORT.intEntityCustomerId
		 , strCustomerNumber					= STATEMENTREPORT.strCustomerNumber
		 , strCustomerName						= STATEMENTREPORT.strCustomerName
		 , dblCreditLimit						= STATEMENTREPORT.dblCreditLimit
		 , intInvoiceId							= CFReportTable.intInvoiceId	 
		 , strInvoiceNumber						= CFReportTable.strInvoiceReportNumber
		 , strBOLNumber
		 , dtmDate								= CFReportTable.dtmInvoiceDate     
		 , dtmDueDate							= CFReportTable.dtmInvoiceDate  
		 , dtmShipDate
		 , dblInvoiceTotal
		 , intPaymentId
		 , strRecordNumber
		 , strTransactionType
		 , strPaymentInfo
		 , dtmDatePaid
		 , dblPayment
		 , dblBalance
		 , strSalespersonName					= STATEMENTREPORT.strSalespersonName
		 , strAccountStatusCode
		 , strLocationName   
		 , strFullAddress
		 , strComment							= STATEMENTREPORT.strComment
		 , strStatementFooterComment			= STATEMENTREPORT.strStatementFooterComment
		 , strCompanyName
		 , strCompanyAddress
		 , ysnStatementCreditLimit
		 , strTicketNumbers
	FROM @temp_statement_table AS STATEMENTREPORT
	INNER JOIN (SELECT intInvoiceId
					, strInvoiceNumber
					, strInvoiceReportNumber
					, dtmInvoiceDate 
				FROM @temp_cf_table
	) CFReportTable ON STATEMENTREPORT.intInvoiceId = CFReportTable.intInvoiceId
) MAINREPORT
LEFT JOIN @temp_aging_table AS AGINGREPORT
	ON MAINREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
INNER JOIN #CUSTOMERS CUSTOMER ON MAINREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId
ORDER BY MAINREPORT.dtmDate

IF @ysnPrintFromCFLocal = 0
	BEGIN
		UPDATE tblARCustomerStatementStagingTable
		SET strComment = dbo.fnEMEntityMessage(intEntityCustomerId, 'Statement')
		WHERE intEntityUserId = @intEntityUserIdLocal
		  AND strStatementFormat = 'Balance Forward'

		IF @ysnPrintZeroBalanceLocal = 0
			BEGIN
				DELETE ORIG
				FROM tblARCustomerStatementStagingTable ORIG
				INNER JOIN (
					SELECT DISTINCT intEntityCustomerId 
					FROM tblARCustomerStatementStagingTable 
					WHERE dblTotalAR = 0
					 AND intEntityUserId = @intEntityUserIdLocal
					 AND strStatementFormat = 'Balance Forward'
				) ZERO ON ORIG.intEntityCustomerId = ZERO.intEntityCustomerId
				AND intEntityUserId = @intEntityUserIdLocal
				AND strStatementFormat = 'Balance Forward'
			END
	END