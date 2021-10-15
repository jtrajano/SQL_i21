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
	  , @dtmBalanceForwardDateLocal			AS DATETIME			= NULL
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
	  , @strCompanyLocationIdsLocal			AS NVARCHAR(MAX)	= NULL
	  , @intEntityUserIdLocal				AS INT				= NULL
	  , @query								AS NVARCHAR(MAX)	= NULL
	  , @queryRunningBalance				AS NVARCHAR(MAX)	= NULL
	  , @blbLogo							AS VARBINARY(MAX)	= NULL
	  , @strCompanyName						AS NVARCHAR(500)	= NULL
	  , @strCompanyAddress					AS NVARCHAR(500)	= NULL
	  , @dblTotalAR							AS NUMERIC(18,6)    = 0

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
SET @dtmBalanceForwardDateLocal			= DATEADD(DAYOFYEAR, -1, @dtmDateFromLocal)

SELECT @blbLogo = dbo.fnSMGetCompanyLogo('Header')
SELECT TOP 1 @strCompanyName = strCompanyName
		   , @strCompanyAddress = dbo.[fnARFormatCustomerAddress](strPhone, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) 
FROM dbo.tblSMCompanySetup WITH (NOLOCK)

IF (@@version NOT LIKE '%2008%')
	BEGIN
		SET @queryRunningBalance = ' ORDER BY STATEMENTREPORT.dtmDate, ISNULL(STATEMENTREPORT.intInvoiceId, 99999999), STATEMENTREPORT.strTransactionType ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW'
	END

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

IF(OBJECT_ID('tempdb..#SORTEDCUSTOMER') IS NOT NULL)
BEGIN
	DROP TABLE #SORTEDCUSTOMER
END

CREATE TABLE #CUSTOMERS (
	  intEntityCustomerId		INT NOT NULL	
	, strFullAddress			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strStatementFooterComment	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
)

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
		INSERT INTO #CUSTOMERS (intEntityCustomerId)
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
		INSERT INTO #CUSTOMERS (intEntityCustomerId)
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
		INSERT INTO #CUSTOMERS (intEntityCustomerId)
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
        DELETE FROM #CUSTOMERS
        WHERE intEntityCustomerId NOT IN (
            SELECT DISTINCT intEntityCustomerId
            FROM dbo.tblARCustomerAccountStatus CAS WITH (NOLOCK)
            INNER JOIN tblARAccountStatus AAS WITH (NOLOCK) ON CAS.intAccountStatusId = AAS.intAccountStatusId
            WHERE AAS.strAccountStatusCode = @strAccountStatusCodeLocal
        )
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

IF @strLocationNameLocal IS NOT NULL
	BEGIN
		SELECT @strCompanyLocationIdsLocal = LEFT(intCompanyLocationId, LEN(intCompanyLocationId) - 1)
		FROM (
			SELECT DISTINCT CAST(intCompanyLocationId AS VARCHAR(MAX))  + ', '
			FROM tblSMCompanyLocation
			WHERE strLocationName = @strLocationNameLocal
			FOR XML PATH ('')
		) C (intCompanyLocationId)
	END

--BEGINNING BALANCE
EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateTo					= @dtmBalanceForwardDateLocal 
										  , @intEntityUserId			= @intEntityUserIdLocal
										  , @strCustomerIds				= @strCustomerIdsLocal
										  , @strCompanyLocationIds		= @strCompanyLocationIdsLocal
										  , @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffPaymentLocal										  
										  , @ysnFromBalanceForward		= 1

SELECT *
INTO #BEGINNINGBALANCE
FROM dbo.tblARCustomerAgingStagingTable
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strAgingType = 'Summary'

UPDATE #BEGINNINGBALANCE
SET dblTotalAR = dblTotalAR - ISNULL(dblFuture, 0) 
  , dblFuture = 0.000000

--AGING SUMMARY
EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateTo					= @dtmDateToLocal 
										  , @dtmBalanceForwardDate		= @dtmBalanceForwardDateLocal
										  , @intEntityUserId			= @intEntityUserIdLocal
										  , @strCustomerIds				= @strCustomerIdsLocal
										  , @strCompanyLocationIds		= @strCompanyLocationIdsLocal
										  , @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffPaymentLocal
										  , @ysnFromBalanceForward		= 0								  

SELECT *
INTO #AGINGSUMMARY
FROM dbo.tblARCustomerAgingStagingTable
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strAgingType = 'Summary'

UPDATE #AGINGSUMMARY
SET dblTotalAR = dblTotalAR - ISNULL(dblFuture, 0) 
  , dblFuture = 0.000000

--UPDATE CUSTOMERS ADDRESS AND FOOTER COMMENT
UPDATE C
SET strFullAddress			= dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, strBillToAddress, strBillToCity, strBillToState, strBillToZipCode, strBillToCountry, NULL, NULL)
  , strStatementFooterComment= dbo.fnARGetDefaultComment(NULL, CS.intEntityCustomerId, 'Statement Report', NULL, 'Footer', NULL, 1)
FROM #CUSTOMERS C
INNER JOIN vyuARCustomerSearch CS ON C.intEntityCustomerId = CS.intEntityCustomerId

--STATEMENT TRANSACTIONS
SELECT intEntityCustomerId		= C.intEntityCustomerId
	 , intInvoiceId				= TRANSACTIONS.intInvoiceId
	 , intPaymentId				= TRANSACTIONS.intPaymentId
	 , intInvoiceDetailId		= TRANSACTIONS.intInvoiceDetailId
	 , intEntityUserId			= @intEntityUserIdLocal
	 , strInvoiceNumber			= TRANSACTIONS.strTransactionNumber
	 , dtmDate					= TRANSACTIONS.dtmDate
	 , dtmDueDate				= TRANSACTIONS.dtmDueDate
	 , dtmAsOfDate				= @dtmDateToLocal
	 , dblAmount				= TRANSACTIONS.dblAmount
	 , dblQuantity				= TRANSACTIONS.dblQuantity	     
	 , dblInvoiceDetailTotal	= TRANSACTIONS.dblInvoiceDetailTotal
	 , strTransactionType		= CAST(TRANSACTIONS.strTransactionType COLLATE Latin1_General_CI_AS AS NVARCHAR (200))
	 , strInvoiceType			= CAST(TRANSACTIONS.strInvoiceType COLLATE Latin1_General_CI_AS AS NVARCHAR (200))
	 , strType					= CAST(TRANSACTIONS.strType COLLATE Latin1_General_CI_AS AS NVARCHAR (200))
	 , strPONumber				= TRANSACTIONS.strPONumber
	 , strItemNo				= TRANSACTIONS.strItemNo
	 , strItemDescription		= TRANSACTIONS.strItemDescription
	 , strFullAddress			= CUST.strFullAddress
	 , strStatementFooterComment= CUST.strStatementFooterComment
	 , strPaymentMethod			= TRANSACTIONS.strPaymentMethod
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
		 , strInvoiceType			= 'Invoice Detail'
		 , strType					= I.strType
		 , strItemNo				= ITEM.strItemNo
		 , strItemDescription		= DETAIL.strItemDescription
		 , dblAmount				= I.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
		 , dblQuantity				= DETAIL.dblQuantity * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
		 , dblInvoiceDetailTotal	= DETAIL.dblLineTotal * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
		 , dtmDate					= I.dtmDate
		 , dtmDueDate				= I.dtmDueDate
		 , strPaymentMethod			= NULL
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
	) DETAIL ON I.intInvoiceId = DETAIL.intInvoiceId
	LEFT JOIN (
		SELECT intItemId
			 , strItemNo
		FROM dbo.tblICItem WITH (NOLOCK)
	) ITEM ON DETAIL.intItemId = ITEM.intItemId
	WHERE I.ysnPosted = 1
	AND I.ysnCancelled = 0
	AND I.ysnRejected = 0
	--AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	AND (I.strType <> 'Service Charge' OR (I.strType = 'Service Charge' AND (I.strInvoiceNumber IN (SELECT strInvoiceOriginId from tblARInvoice)  OR   I.ysnForgiven = 0  )))	
	AND I.strTransactionType NOT IN ('Customer Prepayment', 'Overpayment', 'Cash')
	AND I.strType NOT IN ('CF Tran', 'CF Invoice')
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

	UNION ALL

	SELECT intInvoiceId				= I.intInvoiceId
		 , intPaymentId				= I.intPaymentId
		 , intInvoiceDetailId		= NULL
		 , intEntityCustomerId		= I.intEntityCustomerId
		 , strTransactionNumber		= I.strInvoiceNumber
		 , strPONumber				= I.strPONumber
		 , strTransactionType		= 'Invoices'
		 , strInvoiceType			= I.strTransactionType
		 , strType					= I.strType
		 , strItemNo				= 'INVOICE TOTAL'
		 , strItemDescription		= NULL
		 , dblAmount				= I.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
		 , dblQuantity				= NULL
		 , dblInvoiceDetailTotal	= I.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
		 , dtmDate					= I.dtmDate
		 , dtmDueDate				= I.dtmDueDate
		 , strPaymentMethod			= NULL
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	INNER JOIN #COMPANYLOCATIONS CL ON I.intCompanyLocationId = CL.intCompanyLocationId
	WHERE I.ysnPosted = 1
	AND I.ysnCancelled = 0
	AND I.ysnRejected = 0
	--AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	AND (I.strType <> 'Service Charge' OR (I.strType = 'Service Charge' AND (I.strInvoiceNumber IN (SELECT strInvoiceOriginId from tblARInvoice)  OR   I.ysnForgiven = 0  )))	
	AND I.strTransactionType <> 'Cash'
	AND I.strType <> 'CF Tran'
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	
	UNION ALL

	SELECT intInvoiceId				= NULL
		 , intPaymentId				= P.intPaymentId
		 , intInvoiceDetailId		= NULL
		 , intEntityCustomerId		= P.intEntityCustomerId
		 , strTransactionNumber		= NULL
		 , strPONumber				= NULL
		 , strTransactionType		= 'Payment'
		 , strInvoiceType			= 'Payment'
		 , strType					= NULL
		 , strItemNo				= NULL
		 , strItemDescription		= 'PAYMENT (' + ISNULL(NULLIF(P.strPaymentInfo, ''), P.strRecordNumber) + ')'
		 , dblAmount				= (P.dblAmountPaid - ISNULL(PD.dblInterest, 0) + ISNULL(PD.dblDiscount, 0) + ISNULL(PD.dblWriteOffAmount, 0)) * -1
		 , dblQuantity				= NULL
		 , dblInvoiceDetailTotal	= (P.dblAmountPaid - ISNULL(PD.dblInterest, 0) + ISNULL(PD.dblDiscount, 0) + ISNULL(PD.dblWriteOffAmount, 0)) * -1
		 , dtmDate					= P.dtmDatePaid
		 , dtmDueDate				= P.dtmDatePaid
		 , strPaymentMethod			= P.strPaymentMethod
	FROM dbo.tblARPayment P WITH (NOLOCK)
	LEFT JOIN (
		SELECT intPaymentId
			 , dblDiscount 				= SUM(ISNULL(dblDiscount, 0))
			 , dblInterest 				= SUM(ISNULL(dblInterest, 0))
			 , dblWriteOffAmount 	= SUM(ISNULL(dblWriteOffAmount, 0))
		FROM dbo.tblARPaymentDetail WITH (NOLOCK)
		GROUP BY intPaymentId
	) PD ON P.intPaymentId = PD.intPaymentId
	INNER JOIN #COMPANYLOCATIONS CL ON P.intLocationId = CL.intCompanyLocationId
	WHERE P.ysnPosted = 1
	  AND P.ysnInvoicePrepayment = 0
	  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	  AND ((@ysnIncludeWriteOffPaymentLocal = 1 AND P.intPaymentMethodId NOT IN (SELECT intPaymentMethodID FROM #WRITEOFFSPAYMENTMETHODS)) OR @ysnIncludeWriteOffPaymentLocal = 0)
	  AND P.intPaymentId NOT IN (SELECT I.intPaymentId FROM dbo.tblARInvoice I WITH (NOLOCK) WHERE I.strTransactionType = 'Customer Prepayment' AND I.intPaymentId IS NOT NULL AND I.ysnPosted = 1)
	  AND ISNULL(NULLIF(P.strPaymentInfo, ''), '') NOT LIKE 'CFSI-%'

	UNION ALL

	SELECT intInvoiceId				= NULL
		 , intPaymentId				= P.intPaymentId
		 , intInvoiceDetailId		= NULL
		 , intEntityCustomerId		= P.intEntityVendorId
		 , strTransactionNumber		= NULL
		 , strPONumber				= NULL
		 , strTransactionType		= 'Payment'
		 , strInvoiceType			= 'Payment'
		 , strType					= NULL
		 , strItemNo				= NULL
		 , strItemDescription		= 'PAYMENT (' + ISNULL(NULLIF(P.strPaymentInfo, ''), P.strPaymentRecordNum) + ')'
		 , dblAmount				= ABS((ISNULL(PD.dblPayment, 0) - ISNULL(PD.dblInterest, 0) + ISNULL(PD.dblDiscount, 0))) * -1
		 , dblQuantity				= NULL
		 , dblInvoiceDetailTotal	= ABS((ISNULL(PD.dblPayment, 0) - ISNULL(PD.dblInterest, 0) + ISNULL(PD.dblDiscount, 0))) * -1
		 , dtmDate					= P.dtmDatePaid
		 , dtmDueDate				= P.dtmDatePaid
		 , strPaymentMethod			= NULL
	FROM dbo.tblAPPayment P WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
			 , dblPayment				= SUM(ISNULL(PD.dblPayment, 0))
			 , dblDiscount 				= SUM(ISNULL(PD.dblDiscount, 0))
			 , dblInterest 				= SUM(ISNULL(PD.dblInterest, 0))			 
		FROM dbo.tblAPPaymentDetail PD WITH (NOLOCK)
		WHERE PD.intInvoiceId IS NOT NULL
		GROUP BY PD.intPaymentId
	) PD ON P.intPaymentId = PD.intPaymentId
	INNER JOIN #COMPANYLOCATIONS CL ON P.intCompanyLocationId = CL.intCompanyLocationId
	WHERE P.ysnPosted = 1	  
	  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	  AND ((@ysnIncludeWriteOffPaymentLocal = 1 AND P.intPaymentMethodId NOT IN (SELECT intPaymentMethodID FROM #WRITEOFFSPAYMENTMETHODS)) OR @ysnIncludeWriteOffPaymentLocal = 0)

) TRANSACTIONS ON C.intEntityCustomerId = TRANSACTIONS.intEntityCustomerId

--INCLUDE BUDGET
IF @ysnIncludeBudgetLocal = 1
	BEGIN
		INSERT INTO #STATEMENTREPORT		
		SELECT intEntityCustomerId		= C.intEntityCustomerId
			 , intInvoiceId				= CB.intCustomerBudgetId
			 , intPaymentId				= NULL
			 , intInvoiceDetailId		= NULL
			 , intEntityUserId			= @intEntityUserIdLocal
			 , strInvoiceNumber			= NULL
			 , dtmDate					= CB.dtmBudgetDate
			 , dtmDueDate				= DATEADD(DAY, -1, DATEADD(MONTH, 1, CB.dtmBudgetDate))
			 , dtmAsOfDate				= @dtmDateToLocal
			 , dblAmount				= CB.dblBudgetAmount - CB.dblAmountPaid
			 , dblQuantity				= NULL
			 , dblInvoiceDetailTotal	= CB.dblBudgetAmount - CB.dblAmountPaid
			 , strTransactionType		= 'Customer Budget'
			 , strInvoiceType			= 'Customer Budget'
			 , strType					= NULL
			 , strPONumber				= NULL
			 , strItemNo				= NULL
			 , strItemDescription		= 'Budget due for: ' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101)
			 , strFullAddress			= C.strFullAddress
			 , strStatementFooterComment= C.strStatementFooterComment
			 , strPaymentMethod			= NULL
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
	 , intEntityUserId			= @intEntityUserIdLocal
	 , strInvoiceNumber			= NULL
	 , dtmDate					= @dtmDateFromLocal
	 , dtmAsOfDate				= NULL
	 , dtmDueDate				= @dtmDateToLocal
	 , dblAmount				= ISNULL(BB.dblTotalAR, 0.000000)
	 , dblQuantity				= NULL
	 , dblInvoiceDetailTotal	= ISNULL(BB.dblTotalAR, 0.000000)
	 , strTransactionType		= 'Beginning Balance'
	 , strInvoiceType			= 'Beginning Balance'
	 , strType					= NULL
	 , strPONumber				= NULL
	 , strItemNo				= NULL
	 , strItemDescription		= 'BEGINNING BALANCE'
	 , strFullAddress			= C.strFullAddress
	 , strStatementFooterComment= C.strStatementFooterComment
	 , strPaymentMethod			= NULL
FROM #CUSTOMERS C
LEFT JOIN #BEGINNINGBALANCE BB ON C.intEntityCustomerId = BB.intEntityCustomerId

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

--ADDITIONAL FILTERS
IF @ysnPrintOnlyPastDueLocal = 1
    BEGIN
        DELETE FROM #STATEMENTREPORT WHERE DATEDIFF(DAYOFYEAR, dtmDueDate, @dtmDateToLocal) <= 0 AND strTransactionType <> 'Beginning Balance'
		UPDATE #AGINGSUMMARY 
		SET dblFuture 	= 0
		  , dbl0Days 	= 0
		  , dblTotalAR 	= ISNULL(dblTotalAR, 0) - ISNULL(dbl0Days, 0) - ISNULL(dblFuture, 0)
    END

SELECT @dblTotalAR  =SUM(dblTotalAR)  from #AGINGSUMMARY

IF @ysnPrintZeroBalanceLocal = 0
    BEGIN
		IF  @dblTotalAR = 0 
		BEGIN
        DELETE FROM #STATEMENTREPORT WHERE ((((ABS(dblAmount) * 10000) - CONVERT(FLOAT, (ABS(dblAmount) * 10000))) <> 0) OR ISNULL(dblAmount, 0) <= 0) AND ISNULL(strTransactionType, '') NOT IN ('Beginning Balance', 'Customer Budget')
		DELETE FROM #AGINGSUMMARY WHERE (((ABS(dblTotalAR) * 10000) - CONVERT(FLOAT, (ABS(dblTotalAR) * 10000))) <> 0) OR ISNULL(dblTotalAR, 0) <= 0
		END
	END

--INSERT INTO STATEMENT STAGING
DELETE FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserIdLocal AND strStatementFormat = 'Full Details - No Card Lock' 
DELETE FROM #STATEMENTREPORT WHERE intInvoiceId IS NULL AND intPaymentId IS NULL

SET @query = CAST('' AS NVARCHAR(MAX)) + '
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
	, strPaymentMethod
)
SELECT intRowId 				= CONVERT(INT, ROW_NUMBER() OVER (ORDER BY STATEMENTREPORT.dtmDate, ISNULL(STATEMENTREPORT.intInvoiceId, 99999999), STATEMENTREPORT.strTransactionType))
    , intEntityCustomerId		= STATEMENTREPORT.intEntityCustomerId
	, intInvoiceId				= STATEMENTREPORT.intInvoiceId
	, intInvoiceDetailId		= STATEMENTREPORT.intInvoiceDetailId
	, intPaymentId				= STATEMENTREPORT.intPaymentId
	, intEntityUserId			= STATEMENTREPORT.intEntityUserId
	, dtmDate					= STATEMENTREPORT.dtmDate
	, dtmAsOfDate				= STATEMENTREPORT.dtmAsOfDate
	, strCustomerNumber			= CUSTOMER.strCustomerNumber
	, strCustomerName			= CUSTOMER.strName
	, strAccountNumber			= CUSTOMER.strAccountNumber
	, strInvoiceNumber			= STATEMENTREPORT.strInvoiceNumber
	, strPONumber				= STATEMENTREPORT.strPONumber
	, strItemNo					= STATEMENTREPORT.strItemNo
	, strItemDescription		= CASE WHEN ISNULL(STATEMENTREPORT.strType, '''') = ''Service Charge'' AND STATEMENTREPORT.strTransactionType = ''Invoice Detail''
										THEN ''Service Charge''  
										ELSE STATEMENTREPORT.strItemDescription
								  END
	, strTransactionType		= STATEMENTREPORT.strTransactionType
	, strFullAddress			= STATEMENTREPORT.strFullAddress
	, strStatementFooterComment = STATEMENTREPORT.strStatementFooterComment
	, strStatementFormat		= ''Full Details - No Card Lock''
	, dblQuantity				= STATEMENTREPORT.dblQuantity
	, dblInvoiceDetailTotal		= STATEMENTREPORT.dblInvoiceDetailTotal
	, dblInvoiceTotal			= STATEMENTREPORT.dblAmount
	, dblRunningBalance			= SUM(CASE WHEN (STATEMENTREPORT.strTransactionType IN (''Customer Budget'', ''Invoices'') 
											AND ISNULL(STATEMENTREPORT.strType, '''') <> ''CF Invoice'' 
											AND ((STATEMENTREPORT.intPaymentId IS NULL OR (STATEMENTREPORT.intPaymentId IS NOT NULL AND ISNULL(STATEMENTREPORT.strInvoiceType, '''') = ''Overpayment'')))) OR STATEMENTREPORT.strPaymentMethod = ''NSF''
									      THEN 0 
										  ELSE STATEMENTREPORT.dblInvoiceDetailTotal END
								) OVER (PARTITION BY STATEMENTREPORT.intEntityCustomerId' + ISNULL(@queryRunningBalance, '') +')
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
	, strPaymentMethod			= STATEMENTREPORT.strPaymentMethod
FROM #STATEMENTREPORT STATEMENTREPORT
INNER JOIN (
	SELECT intEntityCustomerId
		 , strCustomerNumber
		 , strName
		 , strAccountNumber		 
	FROM vyuARCustomerSearch
) CUSTOMER ON STATEMENTREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId
INNER JOIN #AGINGSUMMARY AGING ON STATEMENTREPORT.intEntityCustomerId = AGING.intEntityCustomerId	
ORDER BY STATEMENTREPORT.dtmDate'

EXEC sp_executesql @query

--SORTING BY CUSTOMER NUMBER
SELECT DISTINCT strCustomerNumber 
			  , strAlpha	= CASE WHEN PATINDEX('%[0-9]%', strCustomerNumber) > 0 THEN LEFT(strCustomerNumber, PATINDEX('%[0-9]%', strCustomerNumber)-1) ELSE strCustomerNumber END
			  , intNumeric	= CASE WHEN PATINDEX('%[0-9]%', strCustomerNumber) > 0 THEN CONVERT(INT, SUBSTRING(strCustomerNumber, PATINDEX('%[0-9]%', strCustomerNumber), LEN(strCustomerNumber))) ELSE 0 END
INTO #SORTEDCUSTOMER
FROM tblARCustomerStatementStagingTable
WHERE intEntityUserId = @intEntityUserIdLocal 
	AND strStatementFormat = 'Full Details - No Card Lock' 
ORDER BY CASE WHEN PATINDEX('%[0-9]%', strCustomerNumber) > 0 THEN LEFT(strCustomerNumber, PATINDEX('%[0-9]%', strCustomerNumber)-1) ELSE strCustomerNumber END
	   , CASE WHEN PATINDEX('%[0-9]%', strCustomerNumber) > 0 THEN CONVERT(INT, SUBSTRING(strCustomerNumber, PATINDEX('%[0-9]%', strCustomerNumber), LEN(strCustomerNumber))) ELSE 0 END

UPDATE STAGING
SET strCustomerNumberAlpha		= strAlpha
  , intCustomerNumberNumeric	= intNumeric
FROM tblARCustomerStatementStagingTable STAGING
INNER JOIN #SORTEDCUSTOMER SORTED ON STAGING.strCustomerNumber = SORTED.strCustomerNumber

--COMPANY DETAILS
UPDATE tblARCustomerStatementStagingTable
SET blbLogo				= @blbLogo
  , strCompanyName		= @strCompanyName
  , strCompanyAddress	= @strCompanyAddress
WHERE intEntityUserId = @intEntityUserIdLocal AND strStatementFormat = 'Full Details - No Card Lock' 

IF @ysnPrintCreditBalanceLocal = 0
	BEGIN
		DELETE FROM tblARCustomerStatementStagingTable 
		WHERE intEntityUserId = @intEntityUserIdLocal 
			AND strStatementFormat = 'Full Details - No Card Lock'
			AND intEntityCustomerId IN (
				SELECT DISTINCT intEntityCustomerId
				FROM tblARCustomerAgingStagingTable AGINGREPORT
				WHERE AGINGREPORT.intEntityUserId = @intEntityUserIdLocal
				AND AGINGREPORT.strAgingType = 'Summary'
				AND ISNULL(AGINGREPORT.dblTotalAR, 0) < 0
			)
	END