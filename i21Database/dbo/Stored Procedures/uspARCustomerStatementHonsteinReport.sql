CREATE PROCEDURE [dbo].[uspARCustomerStatementHonsteinReport]
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
	, @strStatementFormat			AS NVARCHAR(MAX)	= 'Honstein Oil'
	, @strCustomerName				AS NVARCHAR(MAX)	= NULL
	, @strCustomerIds				AS NVARCHAR(MAX)	= NULL
	, @ysnEmailOnly					AS BIT				= NULL
	, @ysnIncludeWriteOffPayment    AS BIT 				= 0
	, @intEntityUserId				AS INT				= NULL
AS

SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @dtmDateToLocal						AS DATETIME			= NULL
	  , @dtmDateFromLocal					AS DATETIME			= NULL
	  , @ysnPrintZeroBalanceLocal			AS BIT				= 0
	  , @ysnPrintCreditBalanceLocal			AS BIT				= 1
	  , @ysnIncludeBudgetLocal				AS BIT				= 0
	  , @ysnPrintOnlyPastDueLocal			AS BIT				= 0
	  , @ysnActiveCustomersLocal			AS BIT				= 0
	  , @ysnIncludeWriteOffPaymentLocal		AS BIT				= 0
	  , @strCustomerNumberLocal				AS NVARCHAR(MAX)	= NULL
	  , @strLocationNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strAccountStatusCodeLocal			AS NVARCHAR(MAX)	= NULL
	  , @strStatementFormatLocal			AS NVARCHAR(MAX)	= 'Honstein Oil'
	  , @strCustomerNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCustomerIdsLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCompanyLocationIdsLocal			AS NVARCHAR(MAX)	= NULL
	  , @strDateTo							AS NVARCHAR(50)
	  , @strDateFrom						AS NVARCHAR(50)
	  , @strFinalQuery						AS NVARCHAR(MAX)	  
	  , @queryRunningBalance				AS NVARCHAR(MAX)	= ''	  
	  , @intWriteOffPaymentMethodId			AS INT				= NULL
	  , @intEntityUserIdLocal				AS INT				= NULL
	  , @ysnStretchLogo						AS BIT				= 0
	  , @strCompanyName						AS NVARCHAR(500)	= NULL
	  , @strCompanyAddress					AS NVARCHAR(500)	= NULL
	  , @dblTotalAR							NUMERIC(18,6)		= NULL

IF(OBJECT_ID('tempdb..#ADCUSTOMERS') IS NOT NULL) DROP TABLE #ADCUSTOMERS
IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL) DROP TABLE #CUSTOMERS
IF(OBJECT_ID('tempdb..#COMPANYLOCATIONS') IS NOT NULL) DROP TABLE #COMPANYLOCATIONS
IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL) DROP TABLE #INVOICES
IF(OBJECT_ID('tempdb..#PAYMENTS') IS NOT NULL) DROP TABLE #PAYMENTS
IF(OBJECT_ID('tempdb..#INVOICEPAYMENTS') IS NOT NULL) DROP TABLE #INVOICEPAYMENTS
IF(OBJECT_ID('tempdb..#STATEMENTREPORT') IS NOT NULL) DROP TABLE #STATEMENTREPORT
IF(OBJECT_ID('tempdb..#AGINGSUMMARY') IS NOT NULL) DROP TABLE #AGINGSUMMARY

--TEMP TABLES
CREATE TABLE #CUSTOMERS (
	  intEntityCustomerId		INT NOT NULL PRIMARY KEY	  
    , strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
	, strCustomerName			NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
	, strStatementFormat        NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, strFullAddress			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strStatementFooterComment	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS	NULL
	, strCheckPayeeName			NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
	, strComment				NVARCHAR(500) COLLATE Latin1_General_CI_AS	NULL
	, dblCreditLimit			NUMERIC(18,6) NULL DEFAULT 0	
	, dblARBalance				NUMERIC(18,6) NULL DEFAULT 0
	, ysnStatementCreditLimit	BIT NULL
)
CREATE TABLE #GLACCOUNTS (intAccountId	INT	NOT NULL PRIMARY KEY)
CREATE TABLE #COMPANYLOCATIONS (
	  intCompanyLocationId		INT NOT NULL PRIMARY KEY
	, strLocationName			NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
)
CREATE TABLE #INVOICES (
	   intInvoiceId				INT NOT NULL PRIMARY KEY
	 , intEntityCustomerId		INT NOT NULL
	 , intTermId				INT NOT NULL
	 , intCompanyLocationId		INT NOT NULL
	 , strTransactionType		NVARCHAR(25) COLLATE Latin1_General_CI_AS   NOT	NULL
	 , strType					NVARCHAR(25) COLLATE Latin1_General_CI_AS   NULL DEFAULT 'Standard' 
	 , strInvoiceNumber			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	 , strInvoiceOriginId		NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	 , strBOLNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	 , dblInvoiceTotal			NUMERIC(18, 6)	NULL DEFAULT 0
	 , dtmDate					DATETIME NOT NULL
	 , dtmPostDate				DATETIME NOT NULL
	 , dtmDueDate				DATETIME NOT NULL
	 , ysnImportedFromOrigin	BIT NULL
	 , strLocationName			NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	 , strPONumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
)
CREATE TABLE #PAYMENTS (
	  intPaymentId			INT NOT NULL PRIMARY KEY
	, strPaymentMethod		NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
)
CREATE TABLE #INVOICEPAYMENTS (
	  intInvoiceId			INT NOT NULL PRIMARY KEY
	, dblPayment			NUMERIC(18,6) NULL DEFAULT 0
)
CREATE TABLE #AGINGSUMMARY (
	   intEntityCustomerId	INT NOT NULL PRIMARY KEY
	 , dblTotalAR			NUMERIC(18,6) NULL DEFAULT 0
	 , dblFuture			NUMERIC(18,6) NULL DEFAULT 0
	 , dbl0Days				NUMERIC(18,6) NULL DEFAULT 0
	 , dbl10Days			NUMERIC(18,6) NULL DEFAULT 0
	 , dbl30Days			NUMERIC(18,6) NULL DEFAULT 0
	 , dbl60Days			NUMERIC(18,6) NULL DEFAULT 0
	 , dbl90Days			NUMERIC(18,6) NULL DEFAULT 0
	 , dbl91Days			NUMERIC(18,6) NULL DEFAULT 0
	 , dblCredits			NUMERIC(18,6) NULL DEFAULT 0
	 , dblPrepayments 		NUMERIC(18,6) NULL DEFAULT 0
)
CREATE TABLE #STATEMENTREPORT (
	   strReferenceNumber			NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	 , strTransactionType			NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	 , strPONumber					NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	 , intEntityCustomerId			INT NOT NULL
	 , dtmDueDate					DATETIME NULL
	 , dtmDate						DATETIME NULL
	 , intDaysDue					INT NULL DEFAULT 0
	 , dblTotalAmount				NUMERIC(18,6) NULL DEFAULT 0
	 , dblAmountPaid				NUMERIC(18,6) NULL DEFAULT 0
	 , dblAmountDue					NUMERIC(18,6) NULL DEFAULT 0
	 , dblPastDue					NUMERIC(18,6) NULL DEFAULT 0
	 , strCustomerNumber			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	 , strDisplayName				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	 , strName						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	 , strBOLNumber					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	 , dblCreditLimit				NUMERIC(18,6) NULL DEFAULT 0
	 , strLocationName				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	 , strFullAddress				NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
	 , strStatementFooterComment	NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
	 , dtmAsOfDate					DATETIME NULL
	 , intEntityUserId				INT NULL
	 , strStatementFormat			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	 , ysnStatementCreditLimit		BIT
)

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
SET @strStatementFormatLocal			= ISNULL(@strStatementFormat, 'Open Item')
SET @strCustomerNameLocal				= NULLIF(@strCustomerName, '')
SET @strCustomerIdsLocal				= NULLIF(@strCustomerIds, '')
SET @strDateTo							= ''''+ CONVERT(NVARCHAR(50),@dtmDateToLocal, 110) + ''''
SET @strDateFrom						= ''''+ CONVERT(NVARCHAR(50),@dtmDateFromLocal, 110) + ''''
SET @intEntityUserIdLocal				= NULLIF(@intEntityUserId, 0)

--VERSION COMPATIBILITY
IF (@@version NOT LIKE '%2008%')
	BEGIN
		SET @queryRunningBalance = ' ORDER BY STATEMENTREPORT.dtmDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW'		
	END

--GET COMPANY LOGO
SELECT TOP 1 @ysnStretchLogo = ysnStretchLogo FROM tblARCompanyPreference WITH (NOLOCK)

--GET COMPANY DETAILS
SELECT TOP 1 @strCompanyName = strCompanyName
		   , @strCompanyAddress = strAddress + CHAR(13) + char(10) + strCity + ', ' + strState + ', ' + strZip + ', ' + strCountry + CHAR(13) + CHAR(10) + strPhone
FROM dbo.tblSMCompanySetup WITH (NOLOCK)

--FILTER CUSTOMERS
IF @strCustomerNumberLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS WITH (TABLOCK) (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT TOP 1 intEntityCustomerId    	= C.intEntityId 
				   , strCustomerNumber      	= C.strCustomerNumber
				   , strCustomerName        	= EC.strName
				   , strStatementFormat			= 'Honstein Oil'
				   , dblCreditLimit         	= C.dblCreditLimit
				   , dblARBalance           	= C.dblARBalance
				   , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 )) OR @ysnActiveCustomersLocal = 0)
		  AND C.strStatementFormat = 'Honstein Oil'
		  AND EC.strEntityNo = @strCustomerNumberLocal
	END
ELSE IF @strCustomerIdsLocal IS NOT NULL
	BEGIN
		SELECT DISTINCT intEntityCustomerId = intID
		INTO #ADCUSTOMERS
		FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIdsLocal)

		INSERT INTO #CUSTOMERS WITH (TABLOCK) (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT intEntityCustomerId  	= C.intEntityId 
		     , strCustomerNumber    	= C.strCustomerNumber
		     , strCustomerName      	= EC.strName
		     , strStatementFormat		= 'Honstein Oil'
		     , dblCreditLimit       	= C.dblCreditLimit
		     , dblARBalance         	= C.dblARBalance
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN #ADCUSTOMERS CUSTOMERS ON C.intEntityId = CUSTOMERS.intEntityCustomerId
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
		 AND C.strStatementFormat = 'Honstein Oil'
	END
ELSE
	BEGIN
		INSERT INTO #CUSTOMERS WITH (TABLOCK) (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT intEntityCustomerId  	= C.intEntityId 
			 , strCustomerNumber		= C.strCustomerNumber
			 , strCustomerName      	= EC.strName
			 , strStatementFormat		= 'Honstein Oil'
			 , dblCreditLimit       	= C.dblCreditLimit
			 , dblARBalance         	= C.dblARBalance
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
		  AND C.strStatementFormat = 'Honstein Oil'
		  AND (@strCustomerNameLocal IS NULL OR EC.strName = @strCustomerNameLocal)
END

--FILTER CUSTOMER BY ACCOUNT STATUS
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

--FILTER CUSTOMER BY EMAIL SETUP
IF @ysnEmailOnly IS NOT NULL
	BEGIN
		DELETE C
		FROM #CUSTOMERS C
		OUTER APPLY (
			SELECT intEmailSetupCount = COUNT(*) 
			FROM tblARCustomer CC
			INNER JOIN tblEMEntityToContact CONT ON CC.intEntityId = CONT.intEntityId 
			INNER JOIN tblEMEntity E ON CONT.intEntityContactId = E.intEntityId 
			WHERE E.strEmail <> '' 
			  AND E.strEmail IS NOT NULL
			  AND E.strEmailDistributionOption LIKE '%Statements%'
		) EMAILSETUP
		WHERE CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END <> @ysnEmailOnly
	END

SELECT @strCustomerIdsLocal = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
FROM (
	SELECT DISTINCT CAST(intEntityCustomerId AS VARCHAR(MAX))  + ', '
	FROM #CUSTOMERS
	FOR XML PATH ('')
) C (intEntityCustomerId)

--FILTER LOCATIONS
INSERT INTO #COMPANYLOCATIONS
SELECT intCompanyLocationId
	 , strLocationName
FROM tblSMCompanyLocation

IF @strLocationNameLocal IS NOT NULL
	BEGIN 
		DELETE FROM #COMPANYLOCATIONS WHERE strLocationName <> @strLocationName

		SELECT @strCompanyLocationIdsLocal = LEFT(intCompanyLocationId, LEN(intCompanyLocationId) - 1)
		FROM (
			SELECT DISTINCT CAST(intCompanyLocationId AS VARCHAR(MAX))  + ', '
			FROM #COMPANYLOCATIONS
			FOR XML PATH ('')
		) C (intCompanyLocationId)
	END

--CUSTOMER_ADDRESS
UPDATE C
SET strFullAddress		= CASE WHEN C.strStatementFormat <> 'Running Balance' THEN EL.strLocationName ELSE '' END + CHAR(13) + CHAR(10) + EL.strAddress + CHAR(13) + char(10) + EL.strCity + ', ' + EL.strState + ', ' + EL.strZipCode + ', ' + EL.strCountry 
  , strCustomerName		= CASE WHEN C.strStatementFormat <> 'Running Balance' THEN C.strCustomerName ELSE ISNULL(NULLIF(EL.strCheckPayeeName, ''), C.strCustomerName) END
FROM #CUSTOMERS C
INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = C.intEntityCustomerId AND EL.ysnDefaultLocation = 1

--CUSTOMER_FOOTERCOMMENT
UPDATE C
SET strStatementFooterComment	= FOOTER.strMessage
FROM #CUSTOMERS C
CROSS APPLY (
	SELECT TOP 1 strMessage	= '<html>' + CAST(blbMessage AS NVARCHAR(MAX)) + '<html>'
	FROM tblSMDocumentMaintenanceMessage H
	INNER JOIN tblSMDocumentMaintenance M ON H.intDocumentMaintenanceId = M.intDocumentMaintenanceId
	WHERE H.strHeaderFooter = 'Footer'
	  AND M.strSource = 'Statement Report'
	  AND M.intEntityCustomerId = C.intEntityCustomerId
	  AND M.intEntityCustomerId IS NOT NULL
	ORDER BY M.intDocumentMaintenanceId DESC
		   , intEntityCustomerId DESC
) FOOTER

--CUSTOMER STATEMENT COMMENT
UPDATE C
SET strComment = strMessage
FROM #CUSTOMERS C
INNER JOIN tblEMEntityMessage EM ON C.intEntityCustomerId = EM.intEntityId
WHERE strMessageType = 'Statement'

--GL ACCOUNTS
INSERT INTO #GLACCOUNTS
SELECT DISTINCT intAccountId
FROM vyuGLAccountDetail
WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments')

--GET PAYMENTS
INSERT INTO #PAYMENTS WITH (TABLOCK) (
	   intPaymentId
	 , strPaymentMethod
)
SELECT intPaymentId
	 , strPaymentMethod
FROM tblARPayment P WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON P.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #COMPANYLOCATIONS CL ON P.intLocationId = CL.intCompanyLocationId
WHERE P.ysnPosted = 1
  AND ISNULL(P.ysnProcessedToNSF, 0) = 0
  AND P.dtmDatePaid <= @dtmDateToLocal
  AND P.ysnInvoicePrepayment = 0

--FILTER OUT WRITE OFF PAYMENTS
IF @ysnIncludeWriteOffPaymentLocal = 1
	BEGIN
		DELETE P
		FROM #PAYMENTS P
		WHERE strPaymentMethod = 'WRITE OFF'
	END

--GET INVOICE PAYMENT TOTALS
INSERT INTO #INVOICEPAYMENTS WITH (TABLOCK) (
	  intInvoiceId
	, dblPayment
)
SELECT intInvoiceId	= PD.intInvoiceId
	 , dblPayment	= SUM(dblPayment) + SUM(dblDiscount) + SUM(dblWriteOffAmount) - SUM(dblInterest)
FROM tblARPaymentDetail PD
INNER JOIN #PAYMENTS P ON PD.intPaymentId = P.intPaymentId
WHERE PD.intInvoiceId IS NOT NULL
GROUP BY PD.intInvoiceId

--AGING REPORT
EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateTo					= @dtmDateToLocal
										  , @intEntityUserId			= @intEntityUserIdLocal
										  , @strCustomerIds				= @strCustomerIdsLocal
										  , @strCompanyLocationIds		= @strCompanyLocationIdsLocal
										  , @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffPaymentLocal										  

INSERT INTO #AGINGSUMMARY WITH (TABLOCK) (
	   intEntityCustomerId
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
)
SELECT intEntityCustomerId
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
FROM dbo.tblARCustomerAgingStagingTable
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strAgingType = 'Summary'

--GET INVOICES
INSERT INTO #INVOICES WITH (TABLOCK) (
	   intInvoiceId
	 , intEntityCustomerId
	 , intTermId
	 , intCompanyLocationId
	 , strTransactionType
	 , strType
	 , strInvoiceNumber
	 , strInvoiceOriginId
	 , strBOLNumber
	 , dblInvoiceTotal
	 , dtmDate
	 , dtmPostDate
	 , dtmDueDate
	 , ysnImportedFromOrigin
	 , strLocationName
	 , strPONumber		
)
SELECT intInvoiceId				= I.intInvoiceId
	 , intEntityCustomerId		= I.intEntityCustomerId
	 , intTermId				= I.intTermId
	 , intCompanyLocationId		= I.intCompanyLocationId
	 , strTransactionType		= I.strTransactionType
	 , strType					= I.strType
	 , strInvoiceNumber			= I.strInvoiceNumber
	 , strInvoiceOriginId		= I.strInvoiceOriginId
	 , strBOLNumber				= I.strBOLNumber
	 , dblInvoiceTotal			= I.dblInvoiceTotal
	 , dtmDate					= I.dtmDate
	 , dtmPostDate				= I.dtmPostDate
	 , dtmDueDate				= I.dtmDueDate
	 , ysnImportedFromOrigin	= I.ysnImportedFromOrigin
	 , strLocationName			= CL.strLocationName
	 , strPONumber				= I.strPONumber
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON C.intEntityCustomerId = I.intEntityCustomerId
INNER JOIN #COMPANYLOCATIONS CL ON CL.intCompanyLocationId = I.intCompanyLocationId
INNER JOIN #GLACCOUNTS GL ON I.intAccountId = GL.intAccountId
WHERE I.ysnPosted  = 1		
  AND I.ysnCancelled = 0
  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
  AND I.dtmPostDate  BETWEEN @dtmDateFrom  AND @dtmDateTo 

--MAIN STATEMENT
INSERT INTO #STATEMENTREPORT WITH (TABLOCK) (
	   strReferenceNumber
	 , strTransactionType
	 , strPONumber
	 , intEntityCustomerId
	 , dtmDueDate
	 , dtmDate
	 , intDaysDue
	 , dblTotalAmount
	 , dblAmountPaid
	 , dblAmountDue
	 , dblPastDue
	 , strCustomerNumber
	 , strDisplayName
	 , strName
	 , strBOLNumber
	 , dblCreditLimit
	 , strLocationName
	 , strFullAddress
	 , strStatementFooterComment
	 , dtmAsOfDate
	 , intEntityUserId
	 , strStatementFormat
	 , ysnStatementCreditLimit
)
SELECT strReferenceNumber			= CASE WHEN ISNULL(I.ysnImportedFromOrigin, 0) = 0 THEN I.strInvoiceNumber ELSE ISNULL(I.strInvoiceOriginId, I.strInvoiceNumber) END
	 , strTransactionType			= CASE WHEN I.strType = 'Service Charge' THEN 'Service Charge'
	 									   WHEN I.strTransactionType = 'Customer Prepayment' THEN 'Prepayment' 
	 									   ELSE I.strTransactionType 
									  END
	 , strPONumber					= I.strPONumber
	 , intEntityCustomerId			= C.intEntityCustomerId
	 , dtmDueDate					= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Credit Memo', 'Debit Memo') THEN NULL ELSE I.dtmDueDate END
	 , dtmDate						= I.dtmDate
	 , intDaysDue					= DATEDIFF(DAY, I.[dtmDueDate], @dtmDateToLocal)
	 , dblTotalAmount				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
	 , dblAmountPaid				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN ISNULL(TOTALPAYMENT.dblPayment, 0) * -1 ELSE ISNULL(TOTALPAYMENT.dblPayment, 0) END
	 , dblAmountDue					= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END - ISNULL(TOTALPAYMENT.dblPayment, 0)
	 , dblPastDue					= CASE WHEN @dtmDateToLocal > I.[dtmDueDate] AND I.strTransactionType IN ('Invoice', 'Debit Memo')
	 										THEN I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0)
	 									ELSE 0
	 								END
	 , strCustomerNumber			= C.strCustomerNumber
	 , strDisplayName				= C.strCustomerName
	 , strName						= C.strCustomerName
	 , strBOLNumber					= I.strBOLNumber
	 , dblCreditLimit				= C.dblCreditLimit		 
	 , strLocationName				= I.strLocationName
	 , strFullAddress				= C.strFullAddress 
	 , strStatementFooterComment	= C.strStatementFooterComment
	 , dtmAsOfDate					= @dtmDateToLocal
	 , intEntityUserId				= @intEntityUserIdLocal
	 , strStatementFormat			= @strStatementFormatLocal
	 , ysnStatementCreditLimit		= C.ysnStatementCreditLimit
FROM #CUSTOMERS C WITH (NOLOCK)
LEFT JOIN #INVOICES I ON C.intEntityCustomerId = I.intEntityCustomerId
LEFT JOIN #INVOICEPAYMENTS TOTALPAYMENT ON TOTALPAYMENT.intInvoiceId = I.intInvoiceId

--FILTER OUT PAST DUE 
IF @ysnPrintOnlyPastDueLocal = 1
	BEGIN
		DELETE FROM #STATEMENTREPORT WHERE strTransactionType = 'Invoice' AND dblPastDue <= 0
		UPDATE #AGINGSUMMARY SET dbl0Days = 0
	END

SELECT @dblTotalAR = SUM(dblTotalAR) FROM tblARCustomerAgingStagingTable

--FILTER OUT ZERO BALANCE
IF @ysnPrintZeroBalanceLocal = 0
	BEGIN
		IF @dblTotalAR = 0 
		BEGIN
			DELETE FROM #STATEMENTREPORT WHERE ((((ABS(dblAmountDue) * 10000) - CONVERT(FLOAT, (ABS(dblAmountDue) * 10000))) <> 0) OR ISNULL(dblAmountDue, 0) <= 0) AND strTransactionType <> 'Customer Budget'
			DELETE FROM #AGINGSUMMARY WHERE ((((ABS(dblTotalAR) * 10000) - CONVERT(FLOAT, (ABS(dblTotalAR) * 10000))) <> 0) OR ISNULL(dblTotalAR, 0) <= 0)

			DELETE C
			FROM #CUSTOMERS C
			LEFT JOIN (
				SELECT DISTINCT intEntityCustomerId 
				FROM #AGINGSUMMARY 
			) AGING ON AGING.intEntityCustomerId = C.intEntityCustomerId
			WHERE AGING.intEntityCustomerId IS NULL	
		END
	END

DELETE FROM #STATEMENTREPORT
WHERE strReferenceNumber IN (SELECT strInvoiceNumber FROM dbo.tblARInvoice WITH (NOLOCK) WHERE strType = 'CF Tran' AND strTransactionType NOT IN ('Debit Memo'))

--UPDATE STATEMENT DATE GENERATED
MERGE INTO tblARStatementOfAccount AS Target
USING (SELECT strCustomerNumber, @dtmDateTo, SUM(ISNULL(dblAmountDue, 0))
FROM #STATEMENTREPORT GROUP BY strCustomerNumber
)
AS Source (strCustomerNumber, dtmLastStatementDate, dblLastStatement)
ON Target.strEntityNo = Source.strCustomerNumber
WHEN MATCHED THEN
UPDATE SET dtmLastStatementDate = Source.dtmLastStatementDate, dblLastStatement = Source.dblLastStatement
WHEN NOT MATCHED BY TARGET THEN
INSERT (strEntityNo, dtmLastStatementDate, dblLastStatement)
VALUES (strCustomerNumber, dtmLastStatementDate, dblLastStatement);

DELETE FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserIdLocal AND strStatementFormat = @strStatementFormatLocal

SET @strFinalQuery = CAST('' AS NVARCHAR(MAX)) + '
INSERT INTO tblARCustomerStatementStagingTable WITH (TABLOCK) (
	   strReferenceNumber
	 , strTransactionType
	 , strPONumber
	 , intEntityCustomerId
	 , dtmDueDate
	 , dtmDate
	 , intDaysDue
	 , dblTotalAmount
	 , dblAmountPaid
	 , dblAmountDue
	 , dblPastDue
	 , strCustomerNumber
	 , strDisplayName
	 , strCustomerName
	 , strBOLNumber
	 , dblCreditLimit
	 , strLocationName
	 , strFullAddress
	 , strStatementFooterComment
	 , dtmAsOfDate
	 , intEntityUserId
	 , strStatementFormat
	 , ysnStatementCreditLimit
	 , dblRunningBalance
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
)
SELECT STATEMENTREPORT.* 
	 , dblRunningBalance		= SUM(STATEMENTREPORT.dblAmountDue) OVER (PARTITION BY STATEMENTREPORT.intEntityCustomerId' + ISNULL(@queryRunningBalance, '') + ')
	 , dblCreditAvailable		= CASE WHEN (STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)) < 0 THEN 0 ELSE STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0) END
	 , dblFuture				= ISNULL(AGINGREPORT.dblFuture, 0)
	 , dbl0Days					= ISNULL(AGINGREPORT.dbl0Days, 0)
	 , dbl10Days				= ISNULL(AGINGREPORT.dbl10Days, 0)
	 , dbl30Days				= ISNULL(AGINGREPORT.dbl30Days, 0)
	 , dbl60Days				= ISNULL(AGINGREPORT.dbl60Days, 0)
	 , dbl90Days				= ISNULL(AGINGREPORT.dbl90Days, 0)
	 , dbl91Days				= ISNULL(AGINGREPORT.dbl91Days, 0)
	 , dblCredits				= ISNULL(AGINGREPORT.dblCredits, 0)
	 , dblPrepayments			= ISNULL(AGINGREPORT.dblPrepayments, 0)
FROM #STATEMENTREPORT STATEMENTREPORT
LEFT JOIN #AGINGSUMMARY AGINGREPORT ON STATEMENTREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId'

EXEC sp_executesql @strFinalQuery

UPDATE tblARCustomerStatementStagingTable
SET strCompanyName		= @strCompanyName
  , strCompanyAddress	= @strCompanyAddress
  , ysnStretchLogo 		= ISNULL(@ysnStretchLogo, 0)
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strStatementFormat = 'Honstein Oil'

IF @ysnPrintCreditBalanceLocal = 0
	BEGIN
		DELETE FROM tblARCustomerStatementStagingTable 
		WHERE intEntityUserId = @intEntityUserIdLocal 
		  AND strStatementFormat = 'Honstein Oil'
		  AND intEntityCustomerId IN (
			  SELECT DISTINCT intEntityCustomerId
			  FROM #AGINGSUMMARY AGINGREPORT
			  WHERE AGINGREPORT.dblTotalAR < 0
			    AND (AGINGREPORT.dblTotalAR IS NULL OR AGINGREPORT.dblTotalAR < 0)
		  )
	END