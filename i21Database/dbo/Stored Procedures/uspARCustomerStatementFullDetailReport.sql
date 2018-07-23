CREATE PROCEDURE [dbo].[uspARCustomerStatementFullDetailReport]
	  @dtmDateTo					AS DATETIME			= NULL
	, @dtmDateFrom					AS DATETIME			= NULL
	, @ysnPrintZeroBalance			AS BIT				= 0
	, @ysnPrintCreditBalance		AS BIT				= 1
	, @ysnIncludeBudget				AS BIT				= 0
	, @ysnPrintOnlyPastDue			AS BIT				= 0
	, @ysnActiveCustomers			AS BIT				= 0
	, @strCustomerNumber			AS NVARCHAR(MAX)	= NULL
	, @strAccountStatusCode			AS NVARCHAR(MAX)	= NULL
	, @strLocationName				AS NVARCHAR(MAX)	= NULL
	, @strCustomerName				AS NVARCHAR(MAX)	= NULL
	, @strCustomerIds				AS NVARCHAR(MAX)	= NULL
	, @ysnEmailOnly					AS BIT				= NULL
	, @ysnIncludeWriteOffPayment    AS BIT 				= 1
	, @intEntityUserId				AS INT				= NULL
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
	  , @intEntityUserIdLocal				AS INT				= NULL

SET @dtmDateToLocal						= ISNULL(@dtmDateTo, GETDATE())
SET	@dtmDateFromLocal					= ISNULL(@dtmDateFrom, CAST(-53690 AS DATETIME))
SET @ysnPrintZeroBalanceLocal			= ISNULL(@ysnPrintZeroBalance, 0)
SET @ysnPrintCreditBalanceLocal			= ISNULL(@ysnPrintCreditBalance, 1)
SET @ysnIncludeBudgetLocal				= ISNULL(@ysnIncludeBudget, 0)
SET @ysnPrintOnlyPastDueLocal			= ISNULL(@ysnPrintOnlyPastDue, 0)
SET @ysnActiveCustomersLocal			= ISNULL(@ysnActiveCustomers, 0)
SET @ysnIncludeWriteOffPaymentLocal		= ISNULL(@ysnIncludeWriteOffPayment, 1)
SET @strCustomerNumberLocal				= NULLIF(@strCustomerNumber, '')
SET @strAccountStatusCodeLocal			= NULLIF(@strAccountStatusCode, '')
SET @strLocationNameLocal				= NULLIF(@strLocationName, '')
SET @strCustomerNameLocal				= NULLIF(@strCustomerName, '')
SET @strCustomerIdsLocal				= NULLIF(@strCustomerIds, '')
SET @intEntityUserIdLocal				= NULLIF(@intEntityUserId, 0)

IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL)
BEGIN
    DROP TABLE #CUSTOMERS
END

IF(OBJECT_ID('tempdb..#BEGINNINGBALANCE') IS NOT NULL)
BEGIN
    DROP TABLE #BEGINNINGBALANCE
END

IF(OBJECT_ID('tempdb..#AGINGSUMMARY') IS NOT NULL)
BEGIN
    DROP TABLE #AGINGSUMMARY
END

IF(OBJECT_ID('tempdb..#STATEMENTREPORT') IS NOT NULL)
BEGIN
    DROP TABLE #STATEMENTREPORT
END

IF(OBJECT_ID('tempdb..#WRITEOFFSPAYMENTMETHODS') IS NOT NULL)
BEGIN
	DROP TABLE #WRITEOFFSPAYMENTMETHODS
END

IF(OBJECT_ID('tempdb..#COMPANYLOCATIONS') IS NOT NULL)
BEGIN
	DROP TABLE #COMPANYLOCATIONS
END

SELECT intEntityCustomerId	= intEntityId
INTO #CUSTOMERS
FROM tblARCustomer
WHERE 1 = 0

SELECT intPaymentMethodID
INTO #WRITEOFFSPAYMENTMETHODS 
FROM dbo.tblSMPaymentMethod WITH (NOLOCK) 
WHERE UPPER(strPaymentMethod) LIKE '%WRITE OFF%'

SELECT intCompanyLocationId
INTO #COMPANYLOCATIONS 
FROM dbo.tblSMCompanyLocation WITH (NOLOCK) 
WHERE @strLocationName IS NULL OR @strLocationName = strLocationName

IF @strCustomerNumberLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT TOP 1 intEntityCustomerId    = C.intEntityId 
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE strEntityNo = @strCustomerNumberLocal
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
			AND C.strStatementFormat = 'Full Details - No Card Lock'
	END
ELSE IF @strCustomerIdsLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT intEntityCustomerId  = C.intEntityId 
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intID
			FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIdsLocal)
		) CUSTOMERS ON C.intEntityId = CUSTOMERS.intID
		INNER JOIN (
			SELECT intEntityId
			FROM dbo.tblEMEntity WITH (NOLOCK)			
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
			AND C.strStatementFormat = 'Full Details - No Card Lock'
	END
ELSE
	BEGIN
		INSERT INTO #CUSTOMERS
		SELECT intEntityCustomerId  = C.intEntityId 
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE (@strCustomerNameLocal IS NULL OR strName = @strCustomerNameLocal)
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
			AND C.strStatementFormat = 'Full Details - No Card Lock'
END

IF @strAccountStatusCodeLocal IS NOT NULL
	BEGIN
		SELECT 1
		--OUTER APPLY (
		--	SELECT strAccountStatusCode = LEFT(strAccountStatusCode, LEN(strAccountStatusCode) - 1)
		--	FROM (
		--		SELECT CAST(ARAS.strAccountStatusCode AS VARCHAR(200))  + ', '
		--		FROM dbo.tblARCustomerAccountStatus CAS WITH(NOLOCK)
		--		INNER JOIN (
		--			SELECT intAccountStatusId
		--				 , strAccountStatusCode
		--			FROM dbo.tblARAccountStatus WITH (NOLOCK)
		--		) ARAS ON CAS.intAccountStatusId = ARAS.intAccountStatusId
		--		WHERE CAS.intEntityCustomerId = C.intEntityCustomerId
		--		FOR XML PATH ('')
		--	) SC (strAccountStatusCode)
		--) STATUSCODES
	END

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

IF ISNULL(@strCustomerIdsLocal, '') = ''
	BEGIN
		SELECT @strCustomerIdsLocal = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
		FROM (
			SELECT DISTINCT CAST(intEntityCustomerId AS VARCHAR(200))  + ', '
			FROM #CUSTOMERS WITH(NOLOCK)	
			FOR XML PATH ('')
		) C (intEntityCustomerId)
	END

--BEGINNING BALANCE
EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateTo = @dtmDateFromLocal 
										  , @strCompanyLocation = @strLocationNameLocal
										  , @strCustomerIds = @strCustomerIdsLocal
										  , @ysnIncludeWriteOffPayment = @ysnIncludeWriteOffPaymentLocal
										  , @intEntityUserId = @intEntityUserIdLocal

SELECT *
INTO #BEGINNINGBALANCE
FROM dbo.tblARCustomerAgingStagingTable
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strAgingType = 'Summary'

--AGING SUMMARY
EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateTo = @dtmDateToLocal 
										  , @strCompanyLocation = @strLocationNameLocal
										  , @strCustomerIds = @strCustomerIdsLocal
										  , @ysnIncludeWriteOffPayment = @ysnIncludeWriteOffPaymentLocal
										  , @intEntityUserId = @intEntityUserIdLocal

SELECT *
INTO #AGINGSUMMARY
FROM dbo.tblARCustomerAgingStagingTable
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strAgingType = 'Summary'

--STATEMENT TRANSACTIONS
SELECT intEntityCustomerId		= C.intEntityCustomerId
	 , intInvoiceId				= TRANSACTIONS.intInvoiceId
	 , intPaymentId				= TRANSACTIONS.intPaymentId
	 , intInvoiceDetailId		= TRANSACTIONS.intInvoiceDetailId
	 , strInvoiceNumber			= TRANSACTIONS.strTransactionNumber
	 , dtmDate					= TRANSACTIONS.dtmDate
	 , dblAmount				= TRANSACTIONS.dblAmount
	 , dblQuantity				= TRANSACTIONS.dblQuantity	     
	 , dblInvoiceDetailTotal	= TRANSACTIONS.dblInvoiceDetailTotal
	 , strTransactionType		= CAST(TRANSACTIONS.strTransactionType COLLATE Latin1_General_CI_AS AS NVARCHAR (200))
	 , strPONumber				= TRANSACTIONS.strPONumber
	 , strItemNo				= TRANSACTIONS.strItemNo
	 , strItemDescription		= TRANSACTIONS.strItemDescription	 
INTO #STATEMENTREPORT
FROM vyuARCustomerSearch C
INNER JOIN #CUSTOMERS CUST ON C.intEntityCustomerId = CUST.intEntityCustomerId
LEFT JOIN (		
	SELECT intInvoiceId				= I.intInvoiceId
		 , intPaymentId				= NULL
		 , intInvoiceDetailId		= DETAIL.intInvoiceDetailId
		 , intEntityCustomerId		= I.intEntityCustomerId
		 , strTransactionNumber		= I.strInvoiceNumber
		 , strPONumber				= NULL
		 , strTransactionType		= 'Invoice Detail'
		 , strItemNo				= ITEM.strItemNo
		 , strItemDescription		= DETAIL.strItemDescription
		 , dblAmount				= I.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
		 , dblQuantity				= DETAIL.dblQuantity * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
		 , dblInvoiceDetailTotal	= DETAIL.dblLineTotal * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
		 , dtmDate					= I.dtmDate
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	INNER JOIN #COMPANYLOCATIONS CL ON I.intCompanyLocationId = CL.intCompanyLocationId
	LEFT JOIN (
		SELECT intInvoiceId			= ID.intInvoiceId
			 , intInvoiceDetailId	= ID.intInvoiceDetailId
			 , intItemId			= ID.intItemId
			 , strItemDescription	= ID.strItemDescription
			 , dblQuantity			= ISNULL(dblQtyShipped, 0)
			 , dblLineTotal			= ISNULL(dblTotal, 0) + ISNULL(dblTotalTax, 0)
		FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
		WHERE ID.intItemId IS NULL OR ID.intItemId NOT IN (SELECT DISTINCT intARItemId FROM dbo.tblCFItem WITH (NOLOCK))

		UNION ALL

		SELECT intInvoiceId			= ID.intInvoiceId
			 , intInvoiceDetailId	= MAX(ID.intInvoiceDetailId)
			 , intItemId			= NULL
			 , strItemDescription	= 'CARD LOCK ITEMS'
			 , dblQuantity			= SUM(ISNULL(dblQtyShipped, 0))
			 , dblLineTotal			= SUM(ISNULL(dblTotal, 0)) + SUM(ISNULL(dblTotalTax, 0))
		FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
		WHERE ID.intItemId IN (SELECT DISTINCT intARItemId FROM dbo.tblCFItem WITH (NOLOCK))
		GROUP BY ID.intInvoiceId
	) DETAIL ON I.intInvoiceId = DETAIL.intInvoiceId
	LEFT JOIN (
		SELECT intItemId
			 , strItemNo
		FROM dbo.tblICItem WITH (NOLOCK)
	) ITEM ON DETAIL.intItemId = ITEM.intItemId
	WHERE I.ysnPosted = 1
	AND I.ysnCancelled = 0
	AND I.ysnRejected = 0
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	AND I.strTransactionType NOT IN ('Customer Prepayment', 'Overpayment')
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

	UNION ALL

	SELECT intInvoiceId				= I.intInvoiceId
		 , intPaymentId				= I.intPaymentId
		 , intInvoiceDetailId		= NULL
		 , intEntityCustomerId		= I.intEntityCustomerId
		 , strTransactionNumber		= I.strInvoiceNumber
		 , strPONumber				= I.strPONumber
		 , strTransactionType		= 'Invoices'
		 , strItemNo				= 'INVOICE TOTAL'
		 , strItemDescription		= NULL
		 , dblAmount				= I.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
		 , dblQuantity				= NULL
		 , dblInvoiceDetailTotal	= I.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
		 , dtmDate					= I.dtmDate
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	INNER JOIN #COMPANYLOCATIONS CL ON I.intCompanyLocationId = CL.intCompanyLocationId
	WHERE I.ysnPosted = 1
	AND I.ysnCancelled = 0
	AND I.ysnRejected = 0
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	
	UNION ALL

	SELECT intInvoiceId				= NULL
		 , intPaymentId				= P.intPaymentId
		 , intInvoiceDetailId		= NULL
		 , intEntityCustomerId		= P.intEntityCustomerId
		 , strTransactionNumber		= NULL
		 , strPONumber				= NULL
		 , strTransactionType		= 'Payment'
		 , strItemNo				= NULL
		 , strItemDescription		= 'PAYMENT (' + ISNULL(NULLIF(P.strPaymentInfo, ''), P.strRecordNumber) + ')'
		 , dblAmount				= (P.dblAmountPaid - ISNULL(PD.dblInterest, 0) + ISNULL(PD.dblDiscount, 0)) * -1
		 , dblQuantity				= NULL
		 , dblInvoiceDetailTotal	= (P.dblAmountPaid - ISNULL(PD.dblInterest, 0) + ISNULL(PD.dblDiscount, 0)) * -1
		 , dtmDate					= P.dtmDatePaid
	FROM dbo.tblARPayment P WITH (NOLOCK)
	LEFT JOIN (
		SELECT intPaymentId
			 , dblDiscount = SUM(ISNULL(dblDiscount, 0))
			 , dblInterest = SUM(ISNULL(dblInterest, 0))
		FROM dbo.tblARPaymentDetail WITH (NOLOCK)
		GROUP BY intPaymentId
	) PD ON P.intPaymentId = PD.intPaymentId
	INNER JOIN #COMPANYLOCATIONS CL ON P.intLocationId = CL.intCompanyLocationId
	WHERE P.ysnPosted = 1
	  AND P.ysnInvoicePrepayment = 0
	  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	  AND ((@ysnIncludeWriteOffPaymentLocal = 1 AND P.intPaymentId NOT IN (SELECT intPaymentMethodID FROM #WRITEOFFSPAYMENTMETHODS)) OR @ysnIncludeWriteOffPaymentLocal = 0)
	  AND P.intPaymentId NOT IN (SELECT I.intPaymentId FROM dbo.tblARInvoice I WITH (NOLOCK) WHERE I.strTransactionType = 'Customer Prepayment' AND I.intPaymentId IS NOT NULL AND I.ysnPosted = 1)

) TRANSACTIONS ON C.intEntityCustomerId = TRANSACTIONS.intEntityCustomerId

--INCLUDE BUDGET
IF @ysnIncludeBudgetLocal = 1
	BEGIN
		INSERT INTO #STATEMENTREPORT		
		SELECT intEntityCustomerId		= C.intEntityCustomerId
			 , intInvoiceId				= CB.intCustomerBudgetId
			 , intPaymentId				= NULL
			 , intInvoiceDetailId		= NULL
			 , strInvoiceNumber			= NULL
			 , dtmDate					= CB.dtmBudgetDate
			 , dblAmount				= CB.dblBudgetAmount - CB.dblAmountPaid
			 , dblQuantity				= 0.000000
			 , dblInvoiceDetailTotal	= CB.dblBudgetAmount - CB.dblAmountPaid
			 , strTransactionType		= 'Customer Budget'
			 , strPONumber				= NULL
			 , strItemNo				= NULL
			 , strItemDescription		= 'Budget for: ' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101)
		FROM tblARCustomerBudget CB
		INNER JOIN #CUSTOMERS C ON CB.intEntityCustomerId = C.intEntityCustomerId
		INNER JOIN (
			SELECT intEntityId
				 , strAccountNumber
			FROM dbo.tblARCustomer WITH (NOLOCK)
		) CUST ON C.intEntityCustomerId = CUST.intEntityId
		WHERE CB.dtmBudgetDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
        AND CB.dblAmountPaid < CB.dblBudgetAmount
	END

--INSERT BEGINNING BALANCE LINE ITEM
INSERT INTO #STATEMENTREPORT
SELECT intEntityCustomerId		= C.intEntityCustomerId
	 , intInvoiceId				= -999
	 , intPaymentId				= NULL
	 , intInvoiceDetailId		= NULL
	 , strInvoiceNumber			= NULL
	 , dtmDate					= @dtmDateFromLocal
	 , dblAmount				= ISNULL(BB.dblTotalAR, 0.000000)
	 , dblQuantity				= NULL
	 , dblInvoiceDetailTotal	= ISNULL(BB.dblTotalAR, 0.000000)
	 , strTransactionType		= 'Beginning Balance'
	 , strPONumber				= NULL
	 , strItemNo				= NULL
	 , strItemDescription		= 'BEGINNING BALANCE'
FROM #CUSTOMERS C
LEFT JOIN #BEGINNINGBALANCE BB ON C.intEntityCustomerId = BB.intEntityCustomerId

--FILTERS
IF @ysnPrintCreditBalanceLocal = 0
	BEGIN
		DELETE FROM #STATEMENTREPORT WHERE strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment')		
	END

--UPDATE PRINT STATEMENT
MERGE INTO tblARStatementOfAccount AS TARGET
USING (SELECT strCustomerNumber, @dtmDateToLocal, ISNULL(dblTotalAR, 0) FROM #AGINGSUMMARY)
AS SOURCE (strCustomerNumber, dtmLastStatementDate, dblLastStatement)
ON TARGET.strEntityNo = SOURCE.strCustomerNumber

WHEN MATCHED THEN
UPDATE SET dtmLastStatementDate = SOURCE.dtmLastStatementDate, dblLastStatement = SOURCE.dblLastStatement

WHEN NOT MATCHED BY TARGET THEN
INSERT (strEntityNo, dtmLastStatementDate, dblLastStatement)
VALUES (strCustomerNumber, dtmLastStatementDate, dblLastStatement);

--INSERT INTO STATEMENT STAGING
DELETE FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserIdLocal AND strStatementFormat = 'Full Details - No Card Lock' 
DELETE FROM #STATEMENTREPORT WHERE intInvoiceId IS NULL AND intPaymentId IS NULL
INSERT INTO tblARCustomerStatementStagingTable (
	  intRowId
	, intEntityCustomerId
	, intInvoiceId
	, intInvoiceDetailId
	, intPaymentId
	, intEntityUserId
	, dtmDate
	, dtmAsOfDate
	, strCustomerNumber
	, strCustomerName
	, strAccountNumber
	, strInvoiceNumber		
	, strPONumber
	, strItemNo
	, strItemDescription
	, strTransactionType
	, strFullAddress
	, strStatementFooterComment
	, strCompanyName
	, strCompanyAddress
	, strStatementFormat
	, dblQuantity
	, dblInvoiceDetailTotal
	, dblInvoiceTotal
	, dblRunningBalance
	, dblTotalAR
	, dblFuture
	, dbl0Days
	, dbl10Days
	, dbl30Days
	, dbl60Days
	, dbl90Days
	, dbl91Days
	, dblCredits
	, dblPrepayments
	, blbLogo
)
SELECT intRowId 				= CONVERT(INT, ROW_NUMBER() OVER (ORDER BY STATEMENTREPORT.dtmDate, ISNULL(STATEMENTREPORT.intInvoiceId, 99999999), STATEMENTREPORT.strTransactionType))
    , intEntityCustomerId		= STATEMENTREPORT.intEntityCustomerId
	, intInvoiceId				= STATEMENTREPORT.intInvoiceId
	, intInvoiceDetailId		= STATEMENTREPORT.intInvoiceDetailId
	, intPaymentId				= STATEMENTREPORT.intPaymentId
	, intEntityUserId			= @intEntityUserIdLocal
	, dtmDate					= STATEMENTREPORT.dtmDate
	, dtmAsOfDate				= @dtmDateToLocal
	, strCustomerNumber			= CUSTOMER.strCustomerNumber
	, strCustomerName			= CUSTOMER.strName
	, strAccountNumber			= CUSTOMER.strAccountNumber
	, strInvoiceNumber			= STATEMENTREPORT.strInvoiceNumber
	, strPONumber				= STATEMENTREPORT.strPONumber
	, strItemNo					= STATEMENTREPORT.strItemNo
	, strItemDescription		= STATEMENTREPORT.strItemDescription
	, strTransactionType		= STATEMENTREPORT.strTransactionType
	, strFullAddress			= CUSTOMER.strFullAddress
	, strStatementFooterComment = CUSTOMER.strStatementFooterComment
	, strCompanyName			= COMPANY.strCompanyName
	, strCompanyAddress			= COMPANY.strCompanyAddress
	, strStatementFormat		= 'Full Details - No Card Lock'
	, dblQuantity				= STATEMENTREPORT.dblQuantity
	, dblInvoiceDetailTotal		= STATEMENTREPORT.dblInvoiceDetailTotal
	, dblInvoiceTotal			= STATEMENTREPORT.dblAmount
	, dblRunningBalance			= SUM(CASE WHEN STATEMENTREPORT.strTransactionType = 'Invoices' AND STATEMENTREPORT.intPaymentId IS NULL THEN 0 ELSE STATEMENTREPORT.dblInvoiceDetailTotal END) OVER (PARTITION BY STATEMENTREPORT.intEntityCustomerId ORDER BY STATEMENTREPORT.dtmDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	, dblTotalAR				= ISNULL(AGING.dblTotalAR, 0.000000)
	, dblFuture					= ISNULL(AGING.dblFuture, 0.000000)
	, dbl0Days					= ISNULL(AGING.dbl0Days, 0.000000)
	, dbl10Days					= ISNULL(AGING.dbl10Days, 0.000000)
	, dbl30Days					= ISNULL(AGING.dbl30Days, 0.000000)
	, dbl60Days					= ISNULL(AGING.dbl60Days, 0.000000)
	, dbl90Days					= ISNULL(AGING.dbl90Days, 0.000000)
	, dbl91Days					= ISNULL(AGING.dbl91Days, 0.000000)
	, dblCredits				= ISNULL(AGING.dblCredits, 0.000000)
	, dblPrepayments			= ISNULL(AGING.dblPrepayments, 0.000000)
	, blbLogo					= dbo.fnSMGetCompanyLogo('Header')
FROM #STATEMENTREPORT STATEMENTREPORT
INNER JOIN (
	SELECT intEntityCustomerId
		 , strCustomerNumber
		 , strName
		 , strAccountNumber
		 , strFullAddress			= dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, strBillToAddress, strBillToCity, strBillToState, strBillToZipCode, strBillToCountry, NULL, NULL)
		 , strStatementFooterComment= dbo.fnARGetDefaultComment(NULL, intEntityCustomerId, 'Statement Report', NULL, 'Footer', NULL, 1)
	FROM vyuARCustomerSearch
) CUSTOMER ON STATEMENTREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId
LEFT JOIN #AGINGSUMMARY AGING ON STATEMENTREPORT.intEntityCustomerId = AGING.intEntityCustomerId
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](strPhone, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) 
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
ORDER BY STATEMENTREPORT.dtmDate