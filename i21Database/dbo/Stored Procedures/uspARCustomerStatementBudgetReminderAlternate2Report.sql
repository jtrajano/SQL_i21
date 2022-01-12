CREATE PROCEDURE [dbo].[uspARCustomerStatementBudgetReminderAlternate2Report]
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
	, @ysnIncludeWriteOffPayment    AS BIT 				= 0
	, @intEntityUserId				AS INT				= NULL
AS

SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @dtmDateToLocal						AS DATETIME			= ISNULL(@dtmDateTo, GETDATE())
	  , @dtmDateFromLocal					AS DATETIME			= ISNULL(@dtmDateFrom, CAST(-53690 AS DATETIME))
	  , @dtmBalanceForwardDateLocal			AS DATETIME			= ISNULL(@dtmDateFrom, CAST(-53690 AS DATETIME))
	  , @ysnPrintZeroBalanceLocal			AS BIT				= ISNULL(@ysnPrintZeroBalance, 0)
	  , @ysnPrintCreditBalanceLocal			AS BIT				= ISNULL(@ysnPrintCreditBalance, 1)
	  , @ysnIncludeBudgetLocal				AS BIT				= ISNULL(@ysnIncludeBudget, 0)
	  , @ysnPrintOnlyPastDueLocal			AS BIT				= ISNULL(@ysnPrintOnlyPastDue, 0)
	  , @ysnActiveCustomersLocal			AS BIT				= ISNULL(@ysnActiveCustomers, 0)
	  , @ysnIncludeWriteOffPaymentLocal		AS BIT				= ISNULL(@ysnIncludeWriteOffPayment, 0)
	  , @strCustomerNumberLocal				AS NVARCHAR(MAX)	= NULLIF(@strCustomerNumber, '')
	  , @strAccountStatusCodeLocal			AS NVARCHAR(MAX)	= NULLIF(@strAccountStatusCode, '')
	  , @strLocationNameLocal				AS NVARCHAR(MAX)	= NULLIF(@strLocationName, '')
	  , @strCustomerNameLocal				AS NVARCHAR(MAX)	= NULLIF(@strCustomerName, '')
	  , @strCustomerIdsLocal				AS NVARCHAR(MAX)	= NULLIF(@strCustomerIds, '')
	  , @strCompanyLocationIdsLocal			AS NVARCHAR(MAX)
	  , @strCompanyName						AS NVARCHAR(MAX)	= NULL
	  , @strCompanyAddress					AS NVARCHAR(MAX)	= NULL
	  , @intEntityUserIdLocal				AS INT				= NULLIF(@intEntityUserId, 0)
	  , @intCompanyLocationId				AS INT				= NULL
	  , @ARBalance							NUMERIC(18,6)		= 0.00
	  , @queryRunningBalance				AS NVARCHAR(MAX)	= NULL
	  , @orderRunningBalance				AS NVARCHAR(MAX)	= NULL
	  , @queryRowId							AS NVARCHAR(MAX)	= NULL
	  , @orderRowId							AS NVARCHAR(MAX)	= NULL
	  , @strEntityUserIdLocal				AS NVARCHAR(MAX)	= NULL

SET @dtmDateToLocal				= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDateToLocal)))
SET @dtmDateFromLocal			= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDateFromLocal)))
SET @dtmBalanceForwardDateLocal	= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmBalanceForwardDateLocal)))
SET @dtmDateFromLocal			= DATEADD(DAYOFYEAR, 1, @dtmBalanceForwardDateLocal)
SET @strEntityUserIdLocal		= CAST(@intEntityUserIdLocal AS NVARCHAR(MAX))

--GET COMPANY DETAILS
SELECT TOP 1 @strCompanyName	= strCompanyName
		   , @strCompanyAddress = strAddress + CHAR(13) + char(10) + strCity + ', ' + strState + ', ' + strZip + ', ' + strCountry + CHAR(13) + CHAR(10) + strPhone
FROM dbo.tblSMCompanySetup WITH (NOLOCK)

IF(OBJECT_ID('tempdb..#ADCUSTOMERS') IS NOT NULL) DROP TABLE #ADCUSTOMERS
IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL) DROP TABLE #CUSTOMERS
IF(OBJECT_ID('tempdb..#BALANCEFORWARDAGING') IS NOT NULL) DROP TABLE #BALANCEFORWARDAGING
IF(OBJECT_ID('tempdb..#POSTEDINVOICES') IS NOT NULL) DROP TABLE #POSTEDINVOICES
IF(OBJECT_ID('tempdb..#POSTEDARPAYMENTS') IS NOT NULL) DROP TABLE #POSTEDARPAYMENTS
IF(OBJECT_ID('tempdb..#PAYMENTDETAILS') IS NOT NULL) DROP TABLE #PAYMENTDETAILS
IF(OBJECT_ID('tempdb..#APPLIEDPPREPAYMENTS') IS NOT NULL) DROP TABLE #APPLIEDPPREPAYMENTS
IF(OBJECT_ID('tempdb..#GLACCOUNTS') IS NOT NULL) DROP TABLE #GLACCOUNTS
IF(OBJECT_ID('tempdb..#STATEMENTREPORT') IS NOT NULL) DROP TABLE #STATEMENTREPORT

--TEMP TABLES
CREATE TABLE #CUSTOMERS (
	  intEntityCustomerId			INT				NOT NULL PRIMARY KEY
	, strCustomerNumber				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	, strCustomerName				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	, strStatementFormat			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	, strFullAddress				NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	, strStatementFooterComment		NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	, dblCreditLimit				NUMERIC(18, 6)
	, dblCreditAvailable			NUMERIC(18, 6)
	, dblARBalance					NUMERIC(18, 6)
	, ysnStatementCreditLimit		BIT
	, strComment					NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
)
CREATE TABLE #STATEMENTREPORT (
	   intId						INT IDENTITY (2, 1) NOT NULL
	 , intEntityCustomerId			INT NULL
	 , intInvoiceId					INT NULL
	 , intPaymentId					INT NULL	 
	 , strCustomerNumber			NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strCustomerName				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strInvoiceNumber				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strBOLNumber					NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strRecordNumber				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strTransactionType			NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strType						NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strPaymentInfo				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strCompanyName				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strCompanyAddress			NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strFullAddress				NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	 , strStatementFooterComment	NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
     , dtmDate						DATETIME NULL
     , dtmDueDate					DATETIME NULL
	 , dtmDatePaid					DATETIME NULL
	 , dblPayment					NUMERIC(18, 6)
	 , dblAmountDue					NUMERIC(18, 6)
	 , dblCreditLimit				NUMERIC(18, 6)
	 , dblCreditAvailable			NUMERIC(18, 6)
	 , dblBalance					NUMERIC(18, 6)
	 , dblARBalance					NUMERIC(18, 6)
	 , dblMonthlyBudget				NUMERIC(18, 6)
	 , dblBudgetPastDue				NUMERIC(18, 6)
	 , dblBudgetNowDue				NUMERIC(18, 6)
	 , ysnStatementCreditLimit		BIT
	 , dtmDateCreated				DATETIME
	 , strComment					NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_#STATEMENTTABLE_BUDGETREMINDER2] ON [#STATEMENTREPORT]([intEntityCustomerId], [intInvoiceId], [strTransactionType], [strType])
CREATE TABLE #GLACCOUNTS (intAccountId	INT	NOT NULL PRIMARY KEY)
CREATE TABLE #BALANCEFORWARDAGING (
	  intEntityCustomerId	INT	NOT NULL PRIMARY KEY
	, dblTotalAR			NUMERIC(18, 6) NULL DEFAULT 0
)
CREATE TABLE #POSTEDARPAYMENTS (
	   intPaymentId				INT	NOT NULL PRIMARY KEY
	 , intEntityCustomerId		INT	NOT NULL
	 , strPaymentInfo			NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL
	 , strRecordNumber			NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL
	 , strNotes					NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL
	 , dtmDatePaid				DATETIME NOT NULL
	 , ysnInvoicePrepayment		BIT NULL
	 , intPaymentMethodId		INT	NOT NULL
	 , dblBalance				NUMERIC(18, 6) NULL DEFAULT 0
	 , dblTotalAR				NUMERIC(18, 6) NULL DEFAULT 0
	 , dblAmountPaid			NUMERIC(18, 6) NULL DEFAULT 0
	 , dtmDateCreated			DATETIME NULL
	 , strPaymentMethod			NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_#POSTEDARPAYMENTS_BUDGETREMINDER2] ON [#POSTEDARPAYMENTS]([intEntityCustomerId])
CREATE TABLE #PAYMENTDETAILS (
	   intPaymentId				INT	NOT NULL
	 , intInvoiceId				INT	NULL
	 , dblPayment				NUMERIC(18, 6) NULL DEFAULT 0
	 , dblDiscount				NUMERIC(18, 6) NULL DEFAULT 0
	 , dblWriteOffAmount		NUMERIC(18, 6) NULL DEFAULT 0
	 , dblInterest				NUMERIC(18, 6) NULL DEFAULT 0
	 , dtmDatePaid				DATETIME NOT NULL
	 , ysnInvoicePrepayment		BIT NULL
	 , dblAmountDue				NUMERIC(18, 6) NULL DEFAULT 0
	 , dblBalance				NUMERIC(18, 6) NULL DEFAULT 0
	 , dblTotalAR				NUMERIC(18, 6) NULL DEFAULT 0
)
CREATE NONCLUSTERED INDEX [NC_Index_#PAYMENTDETAILS_BUDGETREMINDER2] ON [#PAYMENTDETAILS]([intPaymentId])
CREATE TABLE #POSTEDINVOICES (
	   intInvoiceId					INT	NOT NULL PRIMARY KEY
	 , intPaymentId					INT	NULL
	 , intEntityCustomerId			INT	NOT NULL
	 , strInvoiceNumber				NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL
	 , strTransactionType			NVARCHAR(25)	COLLATE Latin1_General_CI_AS NOT NULL
	 , strType						NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL DEFAULT 'Standard'
	 , strInvoiceOriginId			NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL
	 , dtmDate						DATETIME NOT NULL
	 , dtmDueDate					DATETIME NOT NULL
	 , dblInvoiceTotal				NUMERIC(18, 6) NULL DEFAULT 0
	 , ysnImportedFromOrigin		BIT NULL
	 , ysnServiceChargeCredit		BIT NULL
	 , dtmDateCreated				DATETIME NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_#POSTEDINVOICES_BUDGETREMINDER2] ON [#POSTEDINVOICES]([intEntityCustomerId])
CREATE TABLE #APPLIEDPPREPAYMENTS (
	   intInvoiceId					INT	NULL
	 , intEntityCustomerId			INT	NULL
	 , strInvoiceNumber				NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL
	 , strPrepaymentInvoiceNumber	NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL
	 , strTransactionType			NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL
	 , strType						NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL
	 , dtmDate						DATETIME NULL
	 , dtmDueDate					DATETIME NULL
	 , dblInvoiceTotal				NUMERIC(18, 6) NULL DEFAULT 0
	 , dblPayment					NUMERIC(18, 6) NULL DEFAULT 0
	 , dtmDateCreated				DATETIME NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_#APPLIEDPPREPAYMENTS_BUDGETREMINDER2] ON [#APPLIEDPPREPAYMENTS]([intEntityCustomerId])

--FILTER CUSTOMER
IF @strCustomerNumberLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblCreditAvailable, dblARBalance, ysnStatementCreditLimit)
		SELECT TOP 1 intEntityCustomerId		= C.intEntityId 
			       , strCustomerNumber			= C.strCustomerNumber
				   , strCustomerName			= EC.strName
				   , strStatementFormat			= C.strStatementFormat
				   , dblCreditLimit				= C.dblCreditLimit
				   , dblCreditAvailable			= CASE WHEN ISNULL(C.dblCreditLimit, 0) = 0 THEN 0 ELSE C.dblCreditLimit - ISNULL(C.dblARBalance, 0) END
				   , dblARBalance				= C.dblARBalance
				   , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 )) OR @ysnActiveCustomersLocal = 0)
		  AND C.strStatementFormat = 'Budget Reminder Alternate 2'
		  AND EC.strEntityNo = @strCustomerNumberLocal
	END
ELSE IF @strCustomerIdsLocal IS NOT NULL
	BEGIN
		SELECT DISTINCT intEntityCustomerId = intID
		INTO #ADCUSTOMERS
		FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIdsLocal)

		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblCreditAvailable, dblARBalance, ysnStatementCreditLimit)
		SELECT intEntityCustomerId		= C.intEntityId 
			 , strCustomerNumber		= C.strCustomerNumber
			 , strCustomerName      	= EC.strName
			 , strStatementFormat		= C.strStatementFormat
			 , dblCreditLimit       	= C.dblCreditLimit
			 , dblCreditAvailable		= CASE WHEN ISNULL(C.dblCreditLimit, 0) = 0 THEN 0 ELSE C.dblCreditLimit - ISNULL(C.dblARBalance, 0) END
			 , dblARBalance				= C.dblARBalance        
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN #ADCUSTOMERS CUSTOMERS ON C.intEntityId = CUSTOMERS.intEntityCustomerId
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
			AND C.strStatementFormat = 'Budget Reminder Alternate 2'
	END
ELSE
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblCreditAvailable, dblARBalance, ysnStatementCreditLimit)
		SELECT intEntityCustomerId		= C.intEntityId 
			 , strCustomerNumber		= C.strCustomerNumber
			 , strCustomerName			= EC.strName
			 , strStatementFormat		= C.strStatementFormat
			 , dblCreditLimit			= C.dblCreditLimit
			 , dblCreditAvailable		= CASE WHEN ISNULL(C.dblCreditLimit, 0) = 0 THEN 0 ELSE C.dblCreditLimit - ISNULL(C.dblARBalance, 0) END
			 , dblARBalance				= C.dblARBalance
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 )) OR @ysnActiveCustomersLocal = 0)
		  AND C.strStatementFormat = 'Budget Reminder Alternate 2'
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

--LOCATION FILTER
IF @strLocationNameLocal IS NOT NULL
	BEGIN
		SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
		WHERE strLocationName = @strLocationNameLocal

		SELECT @strCompanyLocationIdsLocal = LEFT(intCompanyLocationId, LEN(intCompanyLocationId) - 1)
		FROM (
			SELECT DISTINCT CAST(intCompanyLocationId AS VARCHAR(MAX))  + ', '
			FROM tblSMCompanyLocation
			WHERE strLocationName = @strLocationNameLocal
			FOR XML PATH ('')
		) C (intCompanyLocationId)
	END

--CUSTOMER_ADDRESS
UPDATE C
SET strFullAddress		= EL.strAddress + CHAR(13) + CHAR(10) + EL.strCity + ', ' + EL.strState + ', ' + EL.strZipCode + ', ' + EL.strCountry 
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
	  AND (M.intEntityCustomerId IS NULL OR (M.intEntityCustomerId IS NOT NULL AND M.intEntityCustomerId = C.intEntityCustomerId))
	ORDER BY M.intDocumentMaintenanceId DESC
		   , intEntityCustomerId DESC
) FOOTER

--CUSTOMER STATEMENT COMMENT
UPDATE C
SET strComment = strMessage
FROM #CUSTOMERS C
INNER JOIN tblEMEntityMessage EM ON C.intEntityCustomerId = EM.intEntityId
WHERE strMessageType = 'Statement'

--BALANCE FORWARD AGING
SELECT @strCustomerIdsLocal = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
FROM (
	SELECT DISTINCT CAST(intEntityCustomerId AS VARCHAR(MAX))  + ', '
	FROM #CUSTOMERS
	FOR XML PATH ('')
) C (intEntityCustomerId)

EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateTo					= @dtmBalanceForwardDateLocal
										  , @intEntityUserId			= @intEntityUserIdLocal
										  , @strCustomerIds				= @strCustomerIdsLocal
										  , @strCompanyLocationIds		= @strCompanyLocationIdsLocal
										  , @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffPaymentLocal										  
										  , @ysnFromBalanceForward		= 1

--#BALANCEFORWARDAGING
INSERT INTO #BALANCEFORWARDAGING WITH (TABLOCK) (
	  intEntityCustomerId
	, dblTotalAR
)
SELECT intEntityCustomerId
	, dblTotalAR
FROM tblARCustomerAgingStagingTable
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strAgingType = 'Summary'

--#GLACCOUNTS
INSERT INTO #GLACCOUNTS
SELECT intAccountId
FROM dbo.vyuGLAccountDetail
WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments')

--#POSTEDARPAYMENTS
INSERT INTO #POSTEDARPAYMENTS WITH (TABLOCK) (
	   intPaymentId
	 , intEntityCustomerId
	 , strPaymentInfo
	 , strRecordNumber
	 , strNotes
	 , dtmDatePaid
	 , ysnInvoicePrepayment
	 , intPaymentMethodId
	 , dblBalance
	 , dblTotalAR
	 , dblAmountPaid
	 , dtmDateCreated
	 , strPaymentMethod
)
SELECT intPaymentId			= P.intPaymentId
	 , intEntityCustomerId	= P.intEntityCustomerId
	 , strPaymentInfo		= P.strPaymentInfo
	 , strRecordNumber		= P.strRecordNumber
	 , strNotes				= P.strNotes
	 , dtmDatePaid			= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid)))
	 , ysnInvoicePrepayment	= P.ysnInvoicePrepayment
	 , intPaymentMethodId	= P.intPaymentMethodId
	 , dblBalance			= P.dblBalance
	 , dblTotalAR			= P.dblTotalAR
	 , dblAmountPaid		= P.dblAmountPaid
	 , dtmDateCreated		= ISNULL(L.dtmDateCreated, P.dtmDatePaid)
	 , strPaymentMethod		= UPPER(PM.strPaymentMethod)
FROM dbo.tblARPayment P WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON P.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN tblSMPaymentMethod PM ON P.intPaymentMethodId = PM.intPaymentMethodID
OUTER APPLY(
	SELECT dtmDateCreated = MIN(SML.dtmDate)
	FROM tblSMTransaction SMT
	INNER JOIN tblSMScreen SMS ON SMT.intScreenId = SMS.intScreenId
	INNER JOIN tblSMLog SML ON SMT.intTransactionId = SML.intTransactionId
	WHERE SMT.intRecordId = P.intPaymentId
	AND SMS.strNamespace = 'AccountsReceivable.view.ReceivePaymentsDetail'
) L
WHERE P.ysnPosted = 1
  AND P.ysnProcessedToNSF = 0   
  AND (@intCompanyLocationId IS NULL OR P.intLocationId = @intCompanyLocationId)

--WRITE OFFS
IF @ysnIncludeWriteOffPaymentLocal = 1
	BEGIN
		DELETE P
		FROM #POSTEDARPAYMENTS P
		WHERE strPaymentMethod = 'WRITE OFF'
	END

--#PAYMENTDETAILS
INSERT INTO #PAYMENTDETAILS WITH (TABLOCK) (
	   intPaymentId
	 , intInvoiceId
	 , dblPayment
	 , dblDiscount
	 , dblWriteOffAmount
	 , dblInterest
	 , dtmDatePaid
	 , ysnInvoicePrepayment
	 , dblAmountDue
	 , dblBalance
	 , dblTotalAR
)
SELECT intPaymentId			= P.intPaymentId
	 , intInvoiceId			= PD.intInvoiceId
	 , dblPayment			= PD.dblPayment
	 , dblDiscount			= PD.dblDiscount
	 , dblWriteOffAmount	= PD.dblWriteOffAmount
	 , dblInterest			= PD.dblInterest
	 , dtmDatePaid			= P.dtmDatePaid
	 , ysnInvoicePrepayment	= P.ysnInvoicePrepayment
	 , dblAmountDue			= ISNULL(PD.dblAmountDue, 0)
	 , dblBalance			= P.dblBalance
	 , dblTotalAR			= P.dblTotalAR
FROM tblARPaymentDetail PD WITH (NOLOCK)
INNER JOIN #POSTEDARPAYMENTS P ON PD.intPaymentId = P.intPaymentId
WHERE P.dtmDatePaid <= @dtmDateToLocal

--#POSTEDINVOICES
INSERT INTO #POSTEDINVOICES WITH (TABLOCK) (
	   intInvoiceId
	 , intPaymentId
	 , intEntityCustomerId
	 , strInvoiceNumber
	 , strTransactionType
	 , strType
	 , strInvoiceOriginId
	 , dtmDate
	 , dtmDueDate
	 , dblInvoiceTotal
	 , ysnImportedFromOrigin
	 , dtmDateCreated
	 , ysnServiceChargeCredit
)
SELECT intInvoiceId				= I.intInvoiceId
	 , intPaymentId				= I.intPaymentId
	 , intEntityCustomerId		= I.intEntityCustomerId
	 , strInvoiceNumber			= I.strInvoiceNumber
	 , strTransactionType		= I.strTransactionType
	 , strType					= I.strType
	 , strInvoiceOriginId		= I.strInvoiceOriginId
	 , dtmDate					= I.dtmDate
	 , dtmDueDate				= I.dtmDueDate
	 , dblInvoiceTotal			= I.dblInvoiceTotal
	 , ysnImportedFromOrigin	= I.ysnImportedFromOrigin
	 , dtmDateCreated			= I.dtmDateCreated
	 , ysnServiceChargeCredit	= I.ysnServiceChargeCredit
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #GLACCOUNTS GL ON I.intAccountId = GL.intAccountId
WHERE I.ysnPosted = 1
  AND I.strType <> 'CF Tran'
  AND I.ysnCancelled = 0
  AND I.ysnProcessedToNSF = 0
  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))		
  AND (I.dtmPostDate BETWEEN @dtmDateFromLocal AND  @dtmDateToLocal
		AND ((I.ysnPaid = 0 OR I.intInvoiceId IN (SELECT intInvoiceId FROM #PAYMENTDETAILS WHERE dtmDatePaid <= @dtmDateToLocal))
		    OR (I.ysnPaid = 1 AND I.intInvoiceId IN (SELECT intInvoiceId FROM #PAYMENTDETAILS WHERE dtmDatePaid > @dtmDateTo)))
      )
  AND (@intCompanyLocationId IS NULL OR I.intCompanyLocationId = @intCompanyLocationId)

--#APPLIEDPPREPAYMENTS
INSERT INTO #APPLIEDPPREPAYMENTS WITH (TABLOCK) (
	   intInvoiceId
	 , intEntityCustomerId
	 , strInvoiceNumber
	 , strPrepaymentInvoiceNumber
	 , strTransactionType
	 , strType
	 , dtmDate
	 , dtmDueDate
	 , dblInvoiceTotal
	 , dblPayment
	 , dtmDateCreated
)
SELECT intInvoiceId					= ARI.intInvoiceId
	 , intEntityCustomerId			= ARI.intEntityCustomerId
	 , strInvoiceNumber				= ARI.strInvoiceNumber
	 , strPrepaymentInvoiceNumber	= ARICPP.strInvoiceNumber
	 , strTransactionType			= ARI.strTransactionType
	 , strType						= ARI.strType
	 , dtmDate						= ARI.dtmDate
	 , dtmDueDate					= ARI.dtmDueDate
	 , dblInvoiceTotal				= ARPAC.dblBaseAppliedInvoiceDetailAmount
	 , dblPayment					= ARPAC.dblAppliedInvoiceDetailAmount
	 , dtmDateCreated				= ARI.dtmDateCreated
FROM #POSTEDINVOICES ARI WITH (NOLOCK)
INNER JOIN tblARPrepaidAndCredit ARPAC ON ARI.intInvoiceId = ARPAC.intInvoiceId
OUTER APPLY (
	SELECT strInvoiceNumber
	FROM dbo.tblARInvoice
	WHERE intInvoiceId = ARPAC.intPrepaymentId
) ARICPP 

--#STATEMENTREPORT
INSERT INTO #STATEMENTREPORT WITH (TABLOCK) (
	   intEntityCustomerId
	 , intInvoiceId
	 , intPaymentId
	 , strCustomerNumber
	 , strCustomerName
	 , strInvoiceNumber
	 , strRecordNumber
	 , strTransactionType
	 , strType
	 , strPaymentInfo
	 , strFullAddress
	 , strStatementFooterComment
     , dtmDate
     , dtmDueDate
	 , dtmDatePaid
	 , dblPayment
	 , dblAmountDue
	 , dblCreditLimit	 
	 , dblCreditAvailable
	 , dblBalance
	 , dblARBalance
	 , ysnStatementCreditLimit
	 , dtmDateCreated
	 , strComment
)
SELECT intEntityCustomerId			= C.intEntityCustomerId
	 , intInvoiceId					= TRANSACTIONS.intInvoiceId
	 , intPaymentId					= TRANSACTIONS.intPaymentId
	 , strCustomerNumber			= C.strCustomerNumber
	 , strCustomerName				= C.strCustomerName
	 , strInvoiceNumber				= TRANSACTIONS.strInvoiceNumber
	 , strRecordNumber				= TRANSACTIONS.strRecordNumber
	 , strTransactionType			= CASE WHEN ISNULL(TRANSACTIONS.ysnServiceChargeCredit, 0) = 1 THEN 'Forgiven Service Charge' ELSE TRANSACTIONS.strTransactionType END
	 , strType						= TRANSACTIONS.strType
	 , strPaymentInfo				= TRANSACTIONS.strPaymentInfo
	 , strFullAddress				= C.strFullAddress
	 , strStatementFooterComment	= C.strStatementFooterComment
     , dtmDate						= TRANSACTIONS.dtmDate
     , dtmDueDate					= TRANSACTIONS.dtmDueDate
	 , dtmDatePaid					= ISNULL(TRANSACTIONS.dtmDatePaid, '01/02/1900')
	 , dblPayment					= ISNULL(TRANSACTIONS.dblPayment, 0)
	 , dblAmountDue					= TRANSACTIONS.dblAmountDue
	 , dblCreditLimit				= C.dblCreditLimit
	 , dblCreditAvailable			= C.dblCreditAvailable
	 , dblBalance					= TRANSACTIONS.dblBalance
	 , dblARBalance					= C.dblARBalance
	 , ysnStatementCreditLimit		= C.ysnStatementCreditLimit
	 , dtmDateCreated				= TRANSACTIONS.dtmDateCreated
	 , strComment					= C.strComment
FROM #CUSTOMERS C
LEFT JOIN (
	SELECT intInvoiceId			= I.intInvoiceId
		 , intEntityCustomerId	= I.intEntityCustomerId
		 , intPaymentId			= CREDITS.intPaymentId
		 , strInvoiceNumber		= CASE WHEN ISNULL(I.ysnImportedFromOrigin, 0) = 0 THEN I.strInvoiceNumber ELSE ISNULL(I.strInvoiceOriginId, I.strInvoiceNumber) END
		 , strRecordNumber		= CASE WHEN strTransactionType = 'Customer Prepayment' THEN CREDITS.strRecordNumber
								  ELSE CASE WHEN ISNULL(I.ysnImportedFromOrigin, 0) = 0 THEN I.strInvoiceNumber ELSE ISNULL(I.strInvoiceOriginId, I.strInvoiceNumber) END
								  END
		 , strPaymentInfo		= CREDITS.strPaymentInfo
		 , strTransactionType	= I.strTransactionType
		 , dblAmountDue			= CASE WHEN strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN 0
									   ELSE I.dblInvoiceTotal 
								  END
		 , dblBalance			= CASE WHEN strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN I.dblInvoiceTotal * -1
									   ELSE I.dblInvoiceTotal 
								  END
		 , dblPayment			= CASE WHEN strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN I.dblInvoiceTotal * -1
									   ELSE 0
								  END
		 , dtmDate				= I.dtmDate
		 , dtmDueDate			= I.dtmDueDate
		 , dtmDatePaid			= CREDITS.dtmDatePaid
		 , strType				= I.strType
		 , dtmDateCreated		= I.dtmDateCreated
		 , ysnServiceChargeCredit = I.ysnServiceChargeCredit
	FROM #POSTEDINVOICES I
	LEFT JOIN #POSTEDARPAYMENTS CREDITS ON I.intPaymentId = CREDITS.intPaymentId

	UNION ALL

	SELECT intInvoiceId			= CPP.intInvoiceId
		 , intEntityCustomerId	= CPP.intEntityCustomerId
		 , intPaymentId			= 0
		 , strInvoiceNumber		= CPP.strPrepaymentInvoiceNumber + ' - ' + CPP.strInvoiceNumber
		 , strRecordNumber		= CPP.strInvoiceNumber
		 , strPaymentInfo		= ''
		 , strTransactionType	= 'Applied Payment'
		 , dblAmountDue			= 0
		 , dblBalance			= CPP.dblPayment
		 , dblPayment			= CPP.dblPayment * -1
		 , dtmDate				= CPP.dtmDate
		 , dtmDueDate			= CPP.dtmDueDate
		 , dtmDatePaid			= CPP.dtmDate
		 , strType				= CPP.strType
		 , dtmDateCreated		= CPP.dtmDateCreated
		 , ysnServiceChargeCredit = NULL
	FROM #APPLIEDPPREPAYMENTS CPP

	UNION ALL

	SELECT intInvoiceId			= 0
		 , intEntityCustomerId	= P.intEntityCustomerId
		 , intPaymentId			= P.intPaymentId
		 , strInvoiceNumber		= P.strRecordNumber
		 , strRecordNumber		= P.strRecordNumber
		 , strPaymentInfo		= ''
		 , strTransactionType	= 'Payment'
		 , dblAmountDue			= 0
		 , dblBalance			= P.dblBalance
		 , dblPayment			= P.dblAmountPaid
		 , dtmDate				= P.dtmDatePaid
		 , dtmDueDate			= P.dtmDatePaid
		 , dtmDatePaid			= P.dtmDatePaid
		 , strType				= 'Payment'
		 , dtmDateCreated		= P.dtmDateCreated
		 , ysnServiceChargeCredit = NULL
	FROM #POSTEDARPAYMENTS P
	WHERE P.ysnInvoicePrepayment = 0
	  AND P.dtmDatePaid BETWEEN @dtmDateFrom AND @dtmDateTo
	  AND P.dblAmountPaid <> 0

	UNION ALL

	SELECT intInvoiceId			= NULL
		 , intEntityCustomerId	= P.intEntityCustomerId
		 , intPaymentId			= P.intPaymentId
		 , strInvoiceNumber		= P.strRecordNumber + ' - ' + ISNULL(DETAILS.strInvoiceNumber , '')
		 , strRecordNumber		= P.strRecordNumber
		 , strPaymentInfo		= 'PAYMENT REF: ' + ISNULL(P.strPaymentInfo, '')
		 , strTransactionType	= 'Applied Payment'
		 , dblAmountDue			= 0.00
		 , dblBalance			= 0.00
		 , dblPayment			= SUM(DETAILS.dblPayment)
		 , dtmDate				= P.dtmDatePaid
		 , dtmDueDate			= NULL
		 , dtmDatePaid			= P.dtmDatePaid
		 , strType				= 'Applied Payment'
		 , dtmDateCreated		= P.dtmDateCreated
		 , ysnServiceChargeCredit = NULL
	FROM #POSTEDARPAYMENTS P
	INNER JOIN (
		SELECT intPaymentId		= PD.intPaymentId
		     , intInvoiceId		= PD.intInvoiceId
			 , strInvoiceNumber	= I.strInvoiceNumber
			 , dblPayment		= SUM(PD.dblPayment) + SUM(PD.dblDiscount) + SUM(PD.dblWriteOffAmount) - SUM(PD.dblInterest) 
			 , dblAmountDue		= ABS(PD.dblAmountDue)
		FROM #PAYMENTDETAILS PD 
		INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
		WHERE I.strTransactionType NOT IN ('Customer Prepayment', 'Credit Memo')
		AND PD.dblBalance IS NOT NULL
		AND PD.dblTotalAR IS NOT NULL
		GROUP BY PD.intPaymentId, PD.intInvoiceId, I.strInvoiceNumber, I.dtmPostDate, PD.dblAmountDue
	) DETAILS ON DETAILS.intPaymentId = P.intPaymentId
	LEFT JOIN (
		SELECT intInvoiceId	
			 , dblPayment = SUM(dblPayment) + SUM(dblDiscount) + SUM(dblWriteOffAmount) - SUM(dblInterest)
		FROM #PAYMENTDETAILS
		WHERE dtmDatePaid <= @dtmDateTo
		GROUP BY intInvoiceId
	) TOTALPAYMENT ON DETAILS.intInvoiceId = TOTALPAYMENT.intInvoiceId
	WHERE P.ysnInvoicePrepayment = 0
	  AND P.dtmDatePaid BETWEEN @dtmDateFrom AND @dtmDateTo
	  AND  (DETAILS.dblAmountDue - ABS(ISNULL(TOTALPAYMENT.dblPayment, 0)) <> 0  OR  DETAILS.dblAmountDue - ABS(ISNULL(TOTALPAYMENT.dblPayment, 0)) = 0)
	GROUP BY P.intPaymentId, P.intEntityCustomerId, P.strRecordNumber, P.strPaymentInfo, P.dtmDatePaid, DETAILS.strInvoiceNumber, P.strNotes, DETAILS.dblAmountDue, P.dtmDateCreated
) TRANSACTIONS ON C.intEntityCustomerId = TRANSACTIONS.intEntityCustomerId

--#STATEMENTREPORT BUDGET
IF @ysnIncludeBudgetLocal = 1
	BEGIN
		INSERT INTO #STATEMENTREPORT WITH (TABLOCK) (
			   intEntityCustomerId
			 , intInvoiceId
			 , strCustomerNumber
			 , strCustomerName
			 , strInvoiceNumber
			 , strRecordNumber
			 , strTransactionType
			 , strType
			 , strFullAddress
			 , strStatementFooterComment
			 , dtmDate
			 , dtmDueDate
			 , dblPayment
			 , dblAmountDue
			 , dblCreditLimit	 
			 , dblCreditAvailable
			 , dblBalance
			 , dblARBalance
			 , ysnStatementCreditLimit
			 , dtmDateCreated
		)
		SELECT intEntityCustomerId			= C.intEntityCustomerId 
			 , intInvoiceId					= CB.intCustomerBudgetId
			 , strCustomerNumber			= C.strCustomerNumber
			 , strCustomerName				= C.strCustomerName
			 , strInvoiceNumber				= 'Budget due for: ' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101)
			 , strRecordNumber				= 'Budget due for: ' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101)
			 , strTransactionType			= 'Customer Budget'
			 , strType						= 'Customer Budget'
			 , strFullAddress				= C.strFullAddress
			 , strStatementFooterComment	= C.strStatementFooterComment
			 , dtmDate						= CB.dtmBudgetDate
			 , dtmDueDate					= DATEADD(DAY, -1, DATEADD(MONTH, 1, CB.dtmBudgetDate))
			 , dblPayment					= 0.00
			 , dblAmountDue					= CB.dblBudgetAmount - CB.dblAmountPaid
			 , dblCreditLimit				= C.dblCreditLimit
			 , dblCreditAvailable			= C.dblCreditAvailable
			 , dblBalance					= 0.00
			 , dblARBalance					= C.dblARBalance
			 , ysnStatementCreditLimit		= C.ysnStatementCreditLimit
			 , dtmDateCreated				= CB.dtmBudgetDate
        FROM tblARCustomerBudget CB
		INNER JOIN #CUSTOMERS C ON CB.intEntityCustomerId = C.intEntityCustomerId
        WHERE CB.dtmBudgetDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
          AND CB.dblAmountPaid < CB.dblBudgetAmount
	END

UPDATE #STATEMENTREPORT SET dblBalance = ABS(dblPayment) * -1 WHERE strTransactionType = 'Applied Payment'

UPDATE #STATEMENTREPORT SET dblBalance = dblAmountDue WHERE strTransactionType IN ('Invoice', 'Debit Memo') AND dblBalance <> 0

--#STATEMENTREPORT BALANCE FORWARD LINE ITEM
INSERT INTO #STATEMENTREPORT WITH (TABLOCK) (
	   intEntityCustomerId
	 , strCustomerNumber
	 , strCustomerName
	 , strTransactionType
	 , strFullAddress
	 , strStatementFooterComment
     , dtmDate
	 , dtmDatePaid
	 , intInvoiceId
	 , dblBalance
	 , dblPayment
	 , dblCreditLimit
	 , dblCreditAvailable
	 , dblARBalance
	 , ysnStatementCreditLimit
	 , dblAmountDue
)
SELECT intEntityCustomerId			= C.intEntityCustomerId
	 , strCustomerNumber			= C.strCustomerNumber
	 , strCustomerName				= C.strCustomerName
	 , strTransactionType			= 'Balance Forward'
	 , strFullAddress				= C.strFullAddress
	 , strStatementFooterComment	= C.strStatementFooterComment
	 , dtmDate						= @dtmDateFrom
	 , dtmDatePaid					= '01/01/1900'
	 , intInvoiceId					= 1
	 , dblBalance					= ISNULL(BFA.dblTotalAR, 0)
	 , dblPayment					= 0
	 , dblCreditLimit				= C.dblCreditLimit
	 , dblCreditAvailable			= C.dblCreditAvailable
	 , dblARBalance					= C.dblARBalance
	 , ysnStatementCreditLimit		= C.ysnStatementCreditLimit
	 , dblAmountDue					= ISNULL(BFA.dblTotalAR, 0)
FROM #CUSTOMERS C
LEFT JOIN #BALANCEFORWARDAGING BFA ON C.intEntityCustomerId = BFA.intEntityCustomerId

--COMPANY INFO
UPDATE #STATEMENTREPORT
SET strCompanyName = @strCompanyName
  , strCompanyAddress = @strCompanyAddress

--LOG STATEMENT HISTORY
MERGE INTO tblARStatementOfAccount AS Target
USING (SELECT strCustomerNumber, @dtmDateToLocal, SUM(ISNULL(dblBalance, 0))
FROM #STATEMENTREPORT GROUP BY strCustomerNumber
)
AS SOURCE (strCustomerNumber, dtmLastStatementDate, dblLastStatement)
ON Target.strEntityNo = SOURCE.strCustomerNumber
WHEN MATCHED THEN
UPDATE SET dtmLastStatementDate = SOURCE.dtmLastStatementDate, dblLastStatement = SOURCE.dblLastStatement
WHEN NOT MATCHED BY TARGET THEN
INSERT (strEntityNo, dtmLastStatementDate, dblLastStatement)
VALUES (strCustomerNumber, dtmLastStatementDate, dblLastStatement);

--ADDITIONAL FILTERS
IF @ysnPrintOnlyPastDueLocal = 1
	DELETE FROM #STATEMENTREPORT WHERE DATEDIFF(DAYOFYEAR, dtmDueDate, @dtmDateToLocal) <= 0 AND strTransactionType <> 'Balance Forward'        

SELECT @ARBalance = SUM(dblTotalAR) FROM #BALANCEFORWARDAGING

IF @ysnPrintZeroBalanceLocal = 0
	BEGIN
		IF @ARBalance = 0 
		BEGIN	

		DELETE FROM #STATEMENTREPORT WHERE ((((ABS(dblBalance) * 10000) - CONVERT(FLOAT, (ABS(dblBalance) * 10000))) <> 0) OR (ISNULL(dblBalance, 0) <= 0 OR ISNULL(dblARBalance,0) <=0)) AND ISNULL(strTransactionType, '') NOT IN ('Customer Budget')
		END
	END

DELETE FROM #STATEMENTREPORT WHERE strTransactionType IS NULL

DELETE SR
FROM #STATEMENTREPORT SR
INNER JOIN dbo.tblARInvoice I ON SR.intInvoiceId = I.intInvoiceId 
WHERE I.strType = 'CF Tran' 
  AND I.strTransactionType NOT IN ('Debit Memo')

--BUDGET AMOUNT
UPDATE SR
SET dblMonthlyBudget	= CUST.dblMonthlyBudget
  , dblBudgetNowDue		= ISNULL(BUDGETNOWDUE.dblAmountDue, 0)
  , dblBudgetPastDue	= ISNULL(BUDGETPASTDUE.dblAmountDue, 0)
FROM #STATEMENTREPORT SR
INNER JOIN #CUSTOMERS C ON SR.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN tblARCustomer CUST ON C.intEntityCustomerId = CUST.intEntityId
OUTER APPLY (
	SELECT dblAmountDue = SUM(dblBudgetAmount) - SUM(dblAmountPaid) 
	FROM dbo.tblARCustomerBudget WITH (NOLOCK)
	WHERE intEntityCustomerId = SR.intEntityCustomerId 
	  AND dtmBudgetDate < @dtmDateToLocal
) BUDGETPASTDUE
OUTER APPLY (
	SELECT dblAmountDue = SUM(dblBudgetAmount) - SUM(dblAmountPaid) 
	FROM dbo.tblARCustomerBudget BUDGET WITH (NOLOCK)
	CROSS APPLY (
		SELECT TOP 1 dtmBudgetDate = CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmBudgetDate)))		
		FROM tblARCustomerBudget B
		WHERE intEntityCustomerId = SR.intEntityCustomerId  
		AND @dtmDateToLocal <= dtmBudgetDate
	) NEAREST
	WHERE BUDGET.intEntityCustomerId = SR.intEntityCustomerId
	  AND BUDGET.dtmBudgetDate <= NEAREST.dtmBudgetDate
	  AND BUDGET.dtmBudgetDate <= @dtmDateToLocal
	  AND BUDGET.dtmBudgetDate >=@dtmDateFrom
) BUDGETNOWDUE

DELETE FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserIdLocal AND strStatementFormat = 'Budget Reminder Alternate 2'

INSERT INTO tblARCustomerStatementStagingTable (
	  intEntityCustomerId
	, intInvoiceId
	, intPaymentId
	, intEntityUserId
	, dtmDate
	, dtmDueDate
	, dtmDatePaid
	, dtmAsOfDate
	, strCustomerNumber
	, strCustomerName
	, strInvoiceNumber		
	, strBOLNumber
	, strRecordNumber
	, strTransactionType
	, strPaymentInfo
	, strFullAddress
	, strStatementFooterComment
	, strCompanyName
	, strCompanyAddress
	, strStatementFormat
	, dblCreditLimit
	, dblCreditAvailable
	, dblAmountDue
	, dblTotalAR
	, dblPayment
	, dblBalance
	, dblMonthlyBudget
	, dblBudgetNowDue
	, dblBudgetPastDue
	, ysnStatementCreditLimit
	, dblAmountPaid
	, dtmDateCreated
)
SELECT intEntityCustomerId		= SR.intEntityCustomerId	
	, intInvoiceId				= SR.intInvoiceId
	, intPaymentId				= SR.intPaymentId
	, intEntityUserId			= @intEntityUserIdLocal
	, dtmDate					= SR.dtmDate
	, dtmDueDate				= SR.dtmDueDate
	, dtmDatePaid				= SR.dtmDatePaid
	, dtmAsOfDate				= @dtmDateToLocal
	, strCustomerNumber			= SR.strCustomerNumber
	, strCustomerName			= SR.strCustomerName
	, strInvoiceNumber			= SR.strInvoiceNumber
	, strBOLNumber				= SR.strBOLNumber
	, strRecordNumber			= SR.strRecordNumber
	, strTransactionType		= SR.strTransactionType
	, strPaymentInfo			= SR.strPaymentInfo
	, strFullAddress			= SR.strFullAddress
	, strStatementFooterComment	= SR.strStatementFooterComment
	, strCompanyName			= SR.strCompanyName
	, strCompanyAddress			= SR.strCompanyAddress
	, strStatementFormat		= 'Budget Reminder Alternate 2'
	, dblCreditLimit			= SR.dblCreditLimit
	, dblCreditAvailable		= SR.dblCreditAvailable
	, dblAmountDue				= SR.dblAmountDue
	, dblTotalAR				= CASE WHEN SR.strTransactionType IN ('Invoice', 'Balance Forward') THEN  SR.dblAmountDue ELSE 0 END
	, dblPayment				= ABS(SR.dblPayment) * -1
	, dblBalance				= SR.dblBalance
	, dblMonthlyBudget			= SR.dblMonthlyBudget
	, dblBudgetNowDue			= SR.dblBudgetNowDue
	, dblBudgetPastDue			= SR.dblBudgetPastDue
	, ysnStatementCreditLimit	= SR.ysnStatementCreditLimit
	, dblAmountPaid				= CASE WHEN SR.strTransactionType IN ('Customer Prepayment', 'Credit Memo') THEN SR.dblPayment WHEN SR.strTransactionType = 'Payment' THEN ABS(SR.dblPayment) * -1 ELSE 0 END
	, dtmDateCreated			= CASE WHEN SR.strTransactionType = 'Applied Payment' THEN DATEADD(ss, 1, SR.dtmDateCreated) ELSE SR.dtmDateCreated END -- Add 1 second to applied payment. This is to ensure that payments and invoices are presented first before the applied payment.
FROM #STATEMENTREPORT SR

IF @ysnPrintCreditBalanceLocal = 0
	BEGIN
		DELETE FROM tblARCustomerStatementStagingTable 
		WHERE intEntityUserId = @intEntityUserIdLocal 
		  AND strStatementFormat = 'Budget Reminder Alternate 2'
		  AND intEntityCustomerId IN (
			SELECT intEntityCustomerId
			FROM tblARCustomerStatementStagingTable
			WHERE intEntityUserId = @intEntityUserIdLocal 
			  AND strStatementFormat = 'Budget Reminder Alternate 2'
			GROUP BY intEntityCustomerId 
			HAVING SUM(ISNULL(dblBalance, 0)) < 0 
		  )
	END

IF (@@version NOT LIKE '%2008%')
BEGIN
	SET @orderRowId = ' ORDER BY dtmDateCreated'
	SET @orderRunningBalance = ' ORDER BY intRowId'
END

SET @queryRowId = CAST('' AS NVARCHAR(MAX)) + '
UPDATE CSST
SET CSST.intRowId = CSST.intRowIdNew
FROM (
		SELECT intRowId, ROW_NUMBER() OVER(PARTITION BY intEntityCustomerId ' + ISNULL(@orderRowId, '') +') AS intRowIdNew
		FROM tblARCustomerStatementStagingTable CSST
		WHERE CSST.intEntityUserId = '+ @strEntityUserIdLocal +'
		AND CSST.strStatementFormat = ''Budget Reminder Alternate 2''
      ) CSST'

EXEC sp_executesql @queryRowId

SET @queryRunningBalance = CAST('' AS NVARCHAR(MAX)) + '
UPDATE CSST
SET  CSST.dblBalance = CSST_RUNNING_BALANCE.dblRunningBalance
	,CSST.dblTotalAmount = CASE WHEN strTransactionType = ''Balance Forward'' THEN dblBalance 
								WHEN strTransactionType = ''Invoice'' THEN dblAmountDue 
								WHEN strTransactionType IN (''Customer Prepayment'', ''Credit Memo'', ''Payment'') THEN dblAmountPaid
								ELSE 0 END
FROM tblARCustomerStatementStagingTable CSST
INNER JOIN (
	SELECT intRowId, intEntityCustomerId, dblRunningBalance = SUM(CASE WHEN strTransactionType = ''Balance Forward'' THEN dblBalance 
															  WHEN strTransactionType = ''Invoice'' THEN dblAmountDue 
															  WHEN strTransactionType IN (''Customer Prepayment'', ''Credit Memo'', ''Payment'') THEN dblAmountPaid
															  ELSE 0 END) OVER (PARTITION BY intEntityCustomerId, strStatementFormat' + ISNULL(@orderRunningBalance, '') +')
	FROM tblARCustomerStatementStagingTable
) CSST_RUNNING_BALANCE
ON CSST.intRowId = CSST_RUNNING_BALANCE.intRowId
AND CSST.intEntityCustomerId = CSST_RUNNING_BALANCE.intEntityCustomerId
WHERE CSST.intEntityUserId = '+ @strEntityUserIdLocal +'
  AND CSST.strStatementFormat = ''Budget Reminder Alternate 2'''

EXEC sp_executesql @queryRunningBalance