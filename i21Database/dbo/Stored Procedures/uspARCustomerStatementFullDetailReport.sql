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

SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

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

--COMPANY INFO
SELECT TOP 1 @strCompanyName	= strCompanyName
		   , @strCompanyAddress = strAddress + CHAR(13) + char(10) + strCity + ', ' + strState + ', ' + strZip + ', ' + strCountry
FROM dbo.tblSMCompanySetup WITH (NOLOCK)
ORDER BY intCompanySetupID DESC

IF (@@version NOT LIKE '%2008%')
	BEGIN
		SET @queryRunningBalance = ' ORDER BY STATEMENTREPORT.dtmDate, ISNULL(STATEMENTREPORT.intInvoiceId, 99999999), STATEMENTREPORT.strTransactionType ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW'
	END

IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL) DROP TABLE #CUSTOMERS
IF(OBJECT_ID('tempdb..#BEGINNINGBALANCE') IS NOT NULL) DROP TABLE #BEGINNINGBALANCE
IF(OBJECT_ID('tempdb..#AGINGSUMMARY') IS NOT NULL) DROP TABLE #AGINGSUMMARY
IF(OBJECT_ID('tempdb..#STATEMENTREPORT') IS NOT NULL) DROP TABLE #STATEMENTREPORT
IF(OBJECT_ID('tempdb..#WRITEOFFSPAYMENTMETHODS') IS NOT NULL) DROP TABLE #WRITEOFFSPAYMENTMETHODS
IF(OBJECT_ID('tempdb..#COMPANYLOCATIONS') IS NOT NULL) DROP TABLE #COMPANYLOCATIONS
IF(OBJECT_ID('tempdb..#SORTEDCUSTOMER') IS NOT NULL) DROP TABLE #SORTEDCUSTOMER
IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL) DROP TABLE #INVOICES
IF(OBJECT_ID('tempdb..#DELCUSTOMERS') IS NOT NULL) DROP TABLE #DELCUSTOMERS

CREATE TABLE #STATEMENTREPORT (
	  intEntityCustomerId		INT NOT NULL 
	, intInvoiceId				INT NULL
	, intPaymentId				INT NULL
	, intInvoiceDetailId		INT NULL
	, intEntityUserId			INT NULL
	, strInvoiceNumber			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, dtmDate					DATETIME NULL
	, dtmDueDate				DATETIME NULL
	, dtmAsOfDate				DATETIME NULL
	, dblAmount					NUMERIC(18,6) NULL DEFAULT 0
	, dblQuantity				NUMERIC(18,6) NULL DEFAULT 0
	, dblInvoiceDetailTotal		NUMERIC(18,6) NULL DEFAULT 0
	, strTransactionType		NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strInvoiceType			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strType					NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strPONumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	, strItemNo					NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	, strItemDescription		NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
	, strFullAddress			NVARCHAR(500) COLLATE Latin1_General_CI_AS	NULL
	, strStatementFooterComment	NVARCHAR(500) COLLATE Latin1_General_CI_AS	NULL
	, strPaymentMethod			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_#STATEMENTTABLE_A1] ON [#STATEMENTREPORT]([intEntityCustomerId], [intInvoiceId], [strTransactionType], [strType])
CREATE TABLE #CUSTOMERS (
	  intEntityCustomerId		INT NOT NULL PRIMARY KEY
	, strFullAddress			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strStatementFooterComment	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strCustomerName			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strAccountNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)
CREATE TABLE #BEGINNINGBALANCE (
	  intEntityCustomerId		INT	NOT NULL PRIMARY KEY
	, strCustomerName			NVARCHAR(200) COLLATE Latin1_General_CI_AS
    , strEntityNo				NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strCustomerInfo			NVARCHAR(200) COLLATE Latin1_General_CI_AS
    , dblCreditLimit			NUMERIC(18,6) NULL DEFAULT 0
    , dblTotalAR				NUMERIC(18,6) NULL DEFAULT 0
    , dblFuture					NUMERIC(18,6) NULL DEFAULT 0
    , dbl0Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl10Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl30Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl60Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl90Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl91Days					NUMERIC(18,6) NULL DEFAULT 0
    , dblTotalDue				NUMERIC(18,6) NULL DEFAULT 0
    , dblAmountPaid				NUMERIC(18,6) NULL DEFAULT 0
    , dblCredits				NUMERIC(18,6) NULL DEFAULT 0
	, dblPrepayments			NUMERIC(18,6) NULL DEFAULT 0
    , dblPrepaids				NUMERIC(18,6) NULL DEFAULT 0
	, dblTempFuture				NUMERIC(18,6) NULL DEFAULT 0
	, dblUnInvoiced				NUMERIC(18,6) NULL DEFAULT 0
    , dtmAsOfDate				DATETIME NULL
    , strSalespersonName		NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSourceTransaction		NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
CREATE TABLE #AGINGSUMMARY (
	  intEntityCustomerId		INT	NOT NULL PRIMARY KEY
	, strCustomerName			NVARCHAR(200) COLLATE Latin1_General_CI_AS
    , strEntityNo				NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strCustomerInfo			NVARCHAR(200) COLLATE Latin1_General_CI_AS
    , dblCreditLimit			NUMERIC(18,6) NULL DEFAULT 0
    , dblTotalAR				NUMERIC(18,6) NULL DEFAULT 0
    , dblFuture					NUMERIC(18,6) NULL DEFAULT 0
    , dbl0Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl10Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl30Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl60Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl90Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl91Days					NUMERIC(18,6) NULL DEFAULT 0
    , dblTotalDue				NUMERIC(18,6) NULL DEFAULT 0
    , dblAmountPaid				NUMERIC(18,6) NULL DEFAULT 0
    , dblCredits				NUMERIC(18,6) NULL DEFAULT 0
	, dblPrepayments			NUMERIC(18,6) NULL DEFAULT 0
    , dblPrepaids				NUMERIC(18,6) NULL DEFAULT 0
	, dblTempFuture				NUMERIC(18,6) NULL DEFAULT 0
	, dblUnInvoiced				NUMERIC(18,6) NULL DEFAULT 0
    , dtmAsOfDate				DATETIME NULL
    , strSalespersonName		NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSourceTransaction		NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
CREATE TABLE #WRITEOFFSPAYMENTMETHODS (intPaymentMethodID	INT	NOT NULL PRIMARY KEY)
CREATE TABLE #COMPANYLOCATIONS (intCompanyLocationId	INT	NOT NULL PRIMARY KEY)
CREATE TABLE #INVOICES (
	  intInvoiceId				INT NOT NULL PRIMARY KEY
	, intPaymentId				INT NULL
	, intEntityCustomerId		INT NOT NULL
	, strInvoiceNumber			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strPONumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	, strTransactionType		NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strType					NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL DEFAULT 'Standard' 
	, dblAmount					NUMERIC(18, 6)	NULL DEFAULT 0
	, dblMultiplier				NUMERIC(18, 6)	NULL DEFAULT 0
	, dtmDate					DATETIME NULL
	, dtmDueDate				DATETIME NULL
)
CREATE TABLE #DELCUSTOMERS (intEntityCustomerId	INT NOT NULL PRIMARY KEY)

INSERT INTO #WRITEOFFSPAYMENTMETHODS
SELECT intPaymentMethodID
FROM dbo.tblSMPaymentMethod WITH (NOLOCK) 
WHERE UPPER(strPaymentMethod) LIKE '%WRITE OFF%'

INSERT INTO #COMPANYLOCATIONS
SELECT intCompanyLocationId
FROM dbo.tblSMCompanyLocation WITH (NOLOCK) 
WHERE @strLocationName IS NULL OR @strLocationName = strLocationName

--CUSTOMER FILTERS
IF @strCustomerNumberLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId)
		SELECT TOP 1 intEntityCustomerId    = C.intEntityId 
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN dbo.tblEMEntity EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
			AND C.strStatementFormat = 'Full Details - No Card Lock'
			AND EC.strEntityNo = @strCustomerNumberLocal
	END
ELSE IF @strCustomerIdsLocal IS NOT NULL
	BEGIN
		INSERT INTO #DELCUSTOMERS
		SELECT DISTINCT intEntityCustomerId =  intID
		FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIdsLocal)	

		INSERT INTO #CUSTOMERS (intEntityCustomerId)
		SELECT intEntityCustomerId  = C.intEntityId 
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN #DELCUSTOMERS CUSTOMERS ON C.intEntityId = CUSTOMERS.intEntityCustomerId
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
			FROM tblARCustomer CC
			INNER JOIN tblEMEntityToContact CONT ON CC.intEntityId = CONT.intEntityId 
			INNER JOIN tblEMEntity E ON CONT.intEntityContactId = E.intEntityId 
			WHERE ISNULL(E.strEmail, '') <> '' 
			  AND E.strEmailDistributionOption LIKE '%Statements%'
		) EMAILSETUP
		WHERE CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END <> @ysnEmailOnly
	END

--CUSTOMER_DETAILS
UPDATE C
SET strCustomerName		= E.strName
  , strCustomerNumber	= CUST.strCustomerNumber
  , strAccountNumber	= CUST.strAccountNumber
FROM #CUSTOMERS C
INNER JOIN tblARCustomer CUST ON C.intEntityCustomerId = CUST.intEntityId
INNER JOIN tblEMEntity E ON C.intEntityCustomerId = E.intEntityId

--CUSTOMER_ADDRESS
UPDATE C
SET strFullAddress	= EL.strAddress + CHAR(13) + char(10) + EL.strCity + ', ' + EL.strState + ', ' + EL.strZipCode + ', ' + EL.strCountry 
FROM #CUSTOMERS C
INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = C.intEntityCustomerId AND EL.ysnDefaultLocation = 1

--CUSTOMER_FOOTERCOMMENT
UPDATE C
SET strStatementFooterComment	= FOOTER.strMessage
FROM #CUSTOMERS C
CROSS APPLY (
	SELECT TOP 1 strMessage	= '<html>' + CAST(blbMessage AS VARCHAR(MAX)) + '</html>'
	FROM tblSMDocumentMaintenanceMessage H
	INNER JOIN tblSMDocumentMaintenance M ON H.intDocumentMaintenanceId = M.intDocumentMaintenanceId
	WHERE H.strHeaderFooter = 'Footer'
	  AND M.strSource = 'Statement Report'
	  AND (M.intEntityCustomerId IS NULL OR (M.intEntityCustomerId IS NOT NULL AND M.intEntityCustomerId = C.intEntityCustomerId))
	ORDER BY M.[intDocumentMaintenanceId] DESC
		   , intEntityCustomerId DESC
) FOOTER

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

INSERT INTO #BEGINNINGBALANCE WITH (TABLOCK) (
	  intEntityCustomerId
	, strCustomerName
    , strEntityNo
	, strCustomerInfo
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
	, dblTempFuture
	, dblUnInvoiced
    , dtmAsOfDate
    , strSalespersonName
	, strSourceTransaction
)
SELECT intEntityCustomerId	= intEntityCustomerId
	, strCustomerName		= strCustomerName
    , strEntityNo           = strCustomerNumber
    , strCustomerInfo       = strCustomerInfo
    , dblCreditLimit        = dblCreditLimit
    , dblTotalAR            = dblTotalAR
    , dblFuture             = dblFuture
    , dbl0Days              = dbl0Days
    , dbl10Days             = dbl10Days
    , dbl30Days             = dbl30Days
    , dbl60Days             = dbl60Days
    , dbl90Days             = dbl90Days
    , dbl91Days             = dbl91Days
    , dblTotalDue           = dblTotalDue
    , dblAmountPaid         = dblAmountPaid
    , dblCredits            = dblCredits
    , dblPrepayments        = dblPrepayments
    , dblPrepaids           = dblPrepaids
    , dblTempFuture         = 0
    , dblUnInvoiced         = 0
    , dtmAsOfDate           = dtmAsOfDate
    , strSalespersonName    = strSalespersonName
    , strSourceTransaction  = strSourceTransaction
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

INSERT INTO #AGINGSUMMARY WITH (TABLOCK) (
	  intEntityCustomerId
	, strCustomerName
    , strEntityNo
	, strCustomerInfo
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
	, dblTempFuture
	, dblUnInvoiced
    , dtmAsOfDate
    , strSalespersonName
	, strSourceTransaction
)
SELECT intEntityCustomerId	= intEntityCustomerId
	, strCustomerName		= strCustomerName
    , strEntityNo           = strCustomerNumber
    , strCustomerInfo       = strCustomerInfo
    , dblCreditLimit        = dblCreditLimit
    , dblTotalAR            = dblTotalAR
    , dblFuture             = dblFuture
    , dbl0Days              = dbl0Days
    , dbl10Days             = dbl10Days
    , dbl30Days             = dbl30Days
    , dbl60Days             = dbl60Days
    , dbl90Days             = dbl90Days
    , dbl91Days             = dbl91Days
    , dblTotalDue           = dblTotalDue
    , dblAmountPaid         = dblAmountPaid
    , dblCredits            = dblCredits
    , dblPrepayments        = dblPrepayments
    , dblPrepaids           = dblPrepaids
    , dblTempFuture         = 0
    , dblUnInvoiced         = 0
    , dtmAsOfDate           = dtmAsOfDate
    , strSalespersonName    = strSalespersonName
    , strSourceTransaction  = strSourceTransaction
FROM dbo.tblARCustomerAgingStagingTable
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strAgingType = 'Summary'

UPDATE #AGINGSUMMARY
SET dblTotalAR = dblTotalAR - ISNULL(dblFuture, 0) 
  , dblFuture = 0.000000

--#INVOICES
INSERT INTO #INVOICES WITH (TABLOCK) (
	  intInvoiceId
	, intPaymentId
	, intEntityCustomerId
	, strInvoiceNumber
	, strPONumber
	, strTransactionType
	, strType
	, dblAmount
	, dblMultiplier
	, dtmDate
	, dtmDueDate
)
SELECT intInvoiceId				= I.intInvoiceId
	 , intPaymentId				= I.intPaymentId
	 , intEntityCustomerId		= I.intEntityCustomerId
	 , strInvoiceNumber			= I.strInvoiceNumber
	 , strPONumber				= I.strPONumber
	 , strTransactionType		= I.strTransactionType
	 , strType					= I.strType
	 , dblAmount				= I.dblInvoiceTotal * CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN -1.000000 ELSE 1.000000 END
	 , dblMultiplier			= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN -1.000000 ELSE 1.000000 END
	 , dtmDate					= I.dtmDate
	 , dtmDueDate				= I.dtmDueDate	 
FROM tblARInvoice I WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #COMPANYLOCATIONS CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
	AND I.ysnCancelled = 0
	AND I.ysnRejected = 0
	AND (I.strType <> 'Service Charge' OR (I.strType = 'Service Charge' AND (I.strInvoiceNumber IN (SELECT strInvoiceOriginId from tblARInvoice)  OR   I.ysnForgiven = 0  )))	
	AND I.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

--STATEMENT TRANSACTIONS
INSERT INTO #STATEMENTREPORT WITH (TABLOCK) (
	   intEntityCustomerId
	 , intInvoiceId
	 , intPaymentId
	 , intInvoiceDetailId
	 , intEntityUserId
	 , strInvoiceNumber
	 , dtmDate
	 , dtmDueDate
	 , dtmAsOfDate
	 , dblAmount
	 , dblQuantity
	 , dblInvoiceDetailTotal
	 , strTransactionType
	 , strInvoiceType
	 , strType
	 , strPONumber
	 , strItemNo
	 , strItemDescription
	 , strFullAddress
	 , strStatementFooterComment
	 , strPaymentMethod
)
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
	 , strFullAddress			= C.strFullAddress
	 , strStatementFooterComment= C.strStatementFooterComment
	 , strPaymentMethod			= TRANSACTIONS.strPaymentMethod
FROM #CUSTOMERS C
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
		 , dblAmount				= I.dblAmount
		 , dblQuantity				= DETAIL.dblQuantity * I.dblMultiplier
		 , dblInvoiceDetailTotal	= DETAIL.dblLineTotal * I.dblMultiplier
		 , dtmDate					= I.dtmDate
		 , dtmDueDate				= I.dtmDueDate
		 , strPaymentMethod			= NULL
	FROM #INVOICES I WITH (NOLOCK)
	LEFT JOIN (
		SELECT intInvoiceId			= ID.intInvoiceId
			 , intInvoiceDetailId	= ID.intInvoiceDetailId
			 , intItemId			= ID.intItemId
			 , strItemDescription	= ID.strItemDescription
			 , dblQuantity			= ISNULL(dblQtyShipped, 0)
			 , dblLineTotal			= ISNULL(dblTotal, 0) + ISNULL(dblTotalTax, 0)
		FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)		
	) DETAIL ON I.intInvoiceId = DETAIL.intInvoiceId
	LEFT JOIN tblICItem ITEM ON DETAIL.intItemId = ITEM.intItemId
	WHERE I.strTransactionType NOT IN ('Customer Prepayment', 'Overpayment', 'Cash')
	  AND I.strType NOT IN ('CF Tran', 'CF Invoice')

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
		 , dblAmount				= I.dblAmount
		 , dblQuantity				= NULL
		 , dblInvoiceDetailTotal	= I.dblAmount
		 , dtmDate					= I.dtmDate
		 , dtmDueDate				= I.dtmDueDate
		 , strPaymentMethod			= NULL
	FROM #INVOICES I WITH (NOLOCK)
	WHERE I.strTransactionType <> 'Cash'
	  AND I.strType <> 'CF Tran'
	
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
			 , dblWriteOffAmount 		= SUM(ISNULL(dblWriteOffAmount, 0))
		FROM dbo.tblARPaymentDetail WITH (NOLOCK)
		GROUP BY intPaymentId
	) PD ON P.intPaymentId = PD.intPaymentId
	INNER JOIN #COMPANYLOCATIONS CL ON P.intLocationId = CL.intCompanyLocationId
	WHERE P.ysnPosted = 1
	  AND P.ysnInvoicePrepayment = 0
	  AND P.dtmDatePaid BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	  AND ((@ysnIncludeWriteOffPaymentLocal = 1 AND P.intPaymentMethodId NOT IN (SELECT intPaymentMethodID FROM #WRITEOFFSPAYMENTMETHODS)) OR @ysnIncludeWriteOffPaymentLocal = 0)
	  AND P.intPaymentId NOT IN (SELECT I.intPaymentId FROM dbo.tblARInvoice I WITH (NOLOCK) WHERE I.strTransactionType = 'Customer Prepayment' AND I.intPaymentId IS NOT NULL AND I.ysnPosted = 1)
	  AND P.strPaymentInfo NOT LIKE 'CFSI-%'

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
	  AND P.dtmDatePaid BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	  AND ((@ysnIncludeWriteOffPaymentLocal = 1 AND P.intPaymentMethodId NOT IN (SELECT intPaymentMethodID FROM #WRITEOFFSPAYMENTMETHODS)) OR @ysnIncludeWriteOffPaymentLocal = 0)

) TRANSACTIONS ON C.intEntityCustomerId = TRANSACTIONS.intEntityCustomerId

--INCLUDE BUDGET
IF @ysnIncludeBudgetLocal = 1
	BEGIN
		INSERT INTO #STATEMENTREPORT WITH (TABLOCK) (
			   intEntityCustomerId
			 , intInvoiceId
			 , intEntityUserId
			 , dtmDate
			 , dtmDueDate
			 , dtmAsOfDate
			 , dblAmount
			 , dblInvoiceDetailTotal
			 , strTransactionType
			 , strInvoiceType
			 , strItemDescription
			 , strFullAddress
			 , strStatementFooterComment
		)
		SELECT intEntityCustomerId		= C.intEntityCustomerId
			 , intInvoiceId				= CB.intCustomerBudgetId
			 , intEntityUserId			= @intEntityUserIdLocal
			 , dtmDate					= CB.dtmBudgetDate
			 , dtmDueDate				= DATEADD(DAY, -1, DATEADD(MONTH, 1, CB.dtmBudgetDate))
			 , dtmAsOfDate				= @dtmDateToLocal
			 , dblAmount				= CB.dblBudgetAmount - CB.dblAmountPaid
			 , dblInvoiceDetailTotal	= CB.dblBudgetAmount - CB.dblAmountPaid
			 , strTransactionType		= 'Customer Budget'
			 , strInvoiceType			= 'Customer Budget'
			 , strItemDescription		= 'Budget due for: ' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101)
			 , strFullAddress			= C.strFullAddress
			 , strStatementFooterComment= C.strStatementFooterComment
			 , strPaymentMethod			= NULL
		FROM tblARCustomerBudget CB
		INNER JOIN #CUSTOMERS C ON CB.intEntityCustomerId = C.intEntityCustomerId
		INNER JOIN tblARCustomer CUST ON C.intEntityCustomerId = CUST.intEntityId
		WHERE CB.dtmBudgetDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
          AND CB.dblAmountPaid < CB.dblBudgetAmount
	END

--INSERT BEGINNING BALANCE LINE ITEM
INSERT INTO #STATEMENTREPORT WITH (TABLOCK) (
	   intEntityCustomerId
	 , intInvoiceId
	 , intEntityUserId
	 , dtmDate
	 , dtmDueDate
	 , dtmAsOfDate
	 , dblAmount
	 , dblInvoiceDetailTotal
	 , strTransactionType
	 , strInvoiceType
	 , strItemDescription
	 , strFullAddress
	 , strStatementFooterComment
)
SELECT intEntityCustomerId		= C.intEntityCustomerId
	 , intInvoiceId				= -999
	 , intEntityUserId			= @intEntityUserIdLocal
	 , dtmDate					= @dtmDateFromLocal
	 , dtmDueDate				= @dtmDateToLocal
	 , dtmAsOfDate				= @dtmDateToLocal
	 , dblAmount				= ISNULL(BB.dblTotalAR, 0.000000)
	 , dblInvoiceDetailTotal	= ISNULL(BB.dblTotalAR, 0.000000)
	 , strTransactionType		= 'Beginning Balance'
	 , strInvoiceType			= 'Beginning Balance'
	 , strItemDescription		= 'BEGINNING BALANCE'
	 , strFullAddress			= C.strFullAddress
	 , strStatementFooterComment= C.strStatementFooterComment
FROM #CUSTOMERS C
LEFT JOIN #BEGINNINGBALANCE BB ON C.intEntityCustomerId = BB.intEntityCustomerId

--UPDATE PRINT STATEMENT
MERGE INTO tblARStatementOfAccount AS TARGET
USING (SELECT strEntityNo, @dtmDateToLocal, ISNULL(dblTotalAR, 0) FROM #AGINGSUMMARY)
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
INSERT INTO tblARCustomerStatementStagingTable WITH (TABLOCK) (
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
	, strCustomerNumber			= CUST.strCustomerNumber
	, strCustomerName			= CUST.strCustomerName
	, strAccountNumber			= CUST.strAccountNumber
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
INNER JOIN #CUSTOMERS CUST ON STATEMENTREPORT.intEntityCustomerId = CUST.intEntityCustomerId	
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
SET strCompanyName		= @strCompanyName
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