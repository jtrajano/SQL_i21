﻿CREATE PROCEDURE [dbo].[uspARCustomerStatementBudgetReminderAlternate2Report]
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

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
	  , @blbLogo							AS VARBINARY(MAX)	= NULL
	  , @intEntityUserIdLocal				AS INT				= NULLIF(@intEntityUserId, 0)
	  , @intCompanyLocationId				AS INT				= NULL
	  , @ARBalance							NUMERIC(18,6)		= 0.00
	  , @query								AS NVARCHAR(MAX)	= NULL
	  , @queryRunningBalance				AS NVARCHAR(MAX)	= NULL
	  , @strEntityUserIdLocal				AS NVARCHAR(MAX)	= NULL

SET @dtmDateToLocal				= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDateToLocal)))
SET @dtmDateFromLocal			= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDateFromLocal)))
SET @dtmBalanceForwardDateLocal	= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmBalanceForwardDateLocal)))
SET @dtmDateFromLocal			= DATEADD(DAYOFYEAR, 1, @dtmBalanceForwardDateLocal)
SET @strEntityUserIdLocal		= CAST(@intEntityUserIdLocal AS NVARCHAR(MAX))

SELECT @blbLogo = dbo.fnSMGetCompanyLogo('Header')
SELECT TOP 1 @strCompanyName	= strCompanyName
		   , @strCompanyAddress = dbo.fnARFormatCustomerAddress(strPhone, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) 
FROM dbo.tblSMCompanySetup WITH (NOLOCK)

IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL)
BEGIN
    DROP TABLE #CUSTOMERS
END

IF(OBJECT_ID('tempdb..#WRITEOFFS') IS NOT NULL)
BEGIN
	DROP TABLE #WRITEOFFS
END

IF(OBJECT_ID('tempdb..#BALANCEFORWARDAGING') IS NOT NULL)
BEGIN
	DROP TABLE #BALANCEFORWARDAGING
END

IF(OBJECT_ID('tempdb..#POSTEDINVOICES') IS NOT NULL)
BEGIN
	DROP TABLE #POSTEDINVOICES
END

IF(OBJECT_ID('tempdb..#POSTEDARPAYMENTS') IS NOT NULL)
BEGIN
	DROP TABLE #POSTEDARPAYMENTS
END

IF(OBJECT_ID('tempdb..#PAYMENTDETAILS') IS NOT NULL)
BEGIN
	DROP TABLE #PAYMENTDETAILS
END

IF(OBJECT_ID('tempdb..#APPLIEDPPREPAYMENTS') IS NOT NULL)
BEGIN
	DROP TABLE #APPLIEDPPREPAYMENTS
END

IF(OBJECT_ID('tempdb..#GLACCOUNTS') IS NOT NULL)
BEGIN
	DROP TABLE #GLACCOUNTS
END

IF(OBJECT_ID('tempdb..#STATEMENTREPORT') IS NOT NULL)
BEGIN
	DROP TABLE #STATEMENTREPORT
END

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
	 , dtmCreated					DATETIME NULL
)

--CUSTOMER FILTER
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
		INNER JOIN (
			SELECT intEntityId
			     , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE strEntityNo = @strCustomerNumberLocal
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 )) OR @ysnActiveCustomersLocal = 0)
		  AND C.strStatementFormat = 'Budget Reminder Alternate 2'
	END
ELSE IF @strCustomerIdsLocal IS NOT NULL
	BEGIN
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
		INNER JOIN (
			SELECT intEntityId
				 , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE (@strCustomerNameLocal IS NULL OR strName = @strCustomerNameLocal)
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 )) OR @ysnActiveCustomersLocal = 0)
		  AND C.strStatementFormat = 'Budget Reminder Alternate 2'
	END

--ACCOUNT STATUS FILTER
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

--FOR EMAIL ONLY FILTER
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

--CUSTOMER ADDRESS AND FOOTER COMMENT
UPDATE C 
SET strStatementFooterComment	= dbo.fnARGetDefaultComment(NULL, C.intEntityCustomerId, 'Statement Report', NULL, 'Footer', NULL, 1)
  , strFullAddress				= dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, CS.strBillToAddress, CS.strBillToCity, CS.strBillToState, CS.strBillToZipCode, CS.strBillToCountry, NULL, NULL)
FROM #CUSTOMERS C
INNER JOIN vyuARCustomerSearch CS ON C.intEntityCustomerId = CS.intEntityCustomerId

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

SELECT *
INTO #BALANCEFORWARDAGING 
FROM tblARCustomerAgingStagingTable
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strAgingType = 'Summary'

--GL ACCOUNTS
SELECT intAccountId
INTO #GLACCOUNTS
FROM dbo.vyuGLAccountDetail
WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments')

--POSTED PAYMENTS
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
	 , strBatchId			= P.strBatchId
	 , dblAmountPaid		= P.dblAmountPaid
INTO #POSTEDARPAYMENTS
FROM dbo.tblARPayment P WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON P.intEntityCustomerId = C.intEntityCustomerId
WHERE P.ysnPosted = 1
   AND ISNULL(P.ysnProcessedToNSF, 0) = 0   
   AND (@intCompanyLocationId IS NULL OR P.intLocationId = @intCompanyLocationId)

--WRITE OFFS
IF @ysnIncludeWriteOffPaymentLocal = 1
	BEGIN
		SELECT intPaymentMethodID
		INTO #WRITEOFFS 
		FROM dbo.tblSMPaymentMethod WITH (NOLOCK) 
		WHERE UPPER(strPaymentMethod) LIKE '%WRITE OFF%'

		DELETE ARP
		FROM #POSTEDARPAYMENTS ARP 
		INNER JOIN #WRITEOFFS WO ON ARP.intPaymentMethodId = WO.intPaymentMethodID
	END

--PAYMENT DETAILS
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
	 , strBatchId			= P.strBatchId
INTO #PAYMENTDETAILS
FROM tblARPaymentDetail PD WITH (NOLOCK)
INNER JOIN #POSTEDARPAYMENTS P ON PD.intPaymentId = P.intPaymentId
WHERE P.dtmDatePaid <= @dtmDateToLocal

--POSTED INVOICES
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
	 , strBatchId				= I.strBatchId
INTO #POSTEDINVOICES
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #GLACCOUNTS GL ON I.intAccountId = GL.intAccountId
WHERE I.ysnPosted = 1
  AND I.strType <> 'CF Tran'
  AND I.ysnCancelled = 0
  AND I.ysnProcessedToNSF = 0
  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))		
  AND (CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND  @dtmDateToLocal
		AND ((I.ysnPaid = 0 OR I.intInvoiceId IN (SELECT intInvoiceId FROM #PAYMENTDETAILS WHERE dtmDatePaid <= @dtmDateToLocal))
		    OR (I.ysnPaid = 1 AND I.intInvoiceId IN (SELECT intInvoiceId FROM #PAYMENTDETAILS WHERE dtmDatePaid > @dtmDateTo)))
      )
  AND (@intCompanyLocationId IS NULL OR I.intCompanyLocationId = @intCompanyLocationId)

--APPLIED CUSTOMER PREPAYMENTS USING INVOICE SCREEN
SELECT intInvoiceId					= ARPAC.intInvoiceId
	 , intEntityCustomerId			= ARI.intEntityCustomerId
	 , strInvoiceNumber				= ARI.strInvoiceNumber
	 , strPrepaymentInvoiceNumber	= ARICPP.strInvoiceNumber
	 , strTransactionType			= ARI.strTransactionType
	 , strType						= ARI.strType
	 , dtmDate						= ARI.dtmDate
	 , dtmDueDate					= ARI.dtmDueDate
	 , dblInvoiceTotal				= ARPAC.dblBaseAppliedInvoiceDetailAmount
	 , dblPayment					= ARPAC.dblAppliedInvoiceDetailAmount
	 , strBatchId					= ARI.strBatchId
INTO #APPLIEDPPREPAYMENTS
FROM dbo.tblARPrepaidAndCredit ARPAC WITH (NOLOCK)
INNER JOIN dbo.tblARInvoice ARI ON ARPAC.intInvoiceId = ARI.intInvoiceId
OUTER APPLY (
	SELECT strInvoiceNumber
	FROM dbo.tblARInvoice
	WHERE intInvoiceId = ARPAC.intPrepaymentId
) ARICPP 
INNER JOIN #CUSTOMERS C ON ARI.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #GLACCOUNTS GL ON ARI.intAccountId = GL.intAccountId
WHERE ARPAC.ysnApplied = 1	
  AND (CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), ARI.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal)
  AND (@intCompanyLocationId IS NULL OR ARI.intCompanyLocationId = @intCompanyLocationId)


--STATEMENT REPORT
INSERT INTO #STATEMENTREPORT (
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
	 , dtmCreated
)
SELECT intEntityCustomerId			= C.intEntityCustomerId
	 , intInvoiceId					= TRANSACTIONS.intInvoiceId
	 , intPaymentId					= TRANSACTIONS.intPaymentId
	 , strCustomerNumber			= C.strCustomerNumber
	 , strCustomerName				= C.strCustomerName
	 , strInvoiceNumber				= TRANSACTIONS.strInvoiceNumber
	 , strRecordNumber				= TRANSACTIONS.strRecordNumber
	 , strTransactionType			= TRANSACTIONS.strTransactionType
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
	 , dtmCreated					= LOGDATETIME.dtmDateEntered
FROM #CUSTOMERS C
LEFT JOIN (
	SELECT intInvoiceId			= I.intInvoiceId
		 , intEntityCustomerId	= I.intEntityCustomerId
		 , intPaymentId			= CREDITS.intPaymentId
		 , strInvoiceNumber		= CASE WHEN ISNULL(I.ysnImportedFromOrigin, 0) = 0 THEN I.strInvoiceNumber ELSE ISNULL(I.strInvoiceOriginId, I.strInvoiceNumber) END
		 , strRecordNumber		= CREDITS.strRecordNumber
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
		 , strBatchId			= ISNULL(I.strBatchId, BATCHCPP.strBatchId)
	FROM #POSTEDINVOICES I
	LEFT JOIN #POSTEDARPAYMENTS CREDITS ON I.intPaymentId = CREDITS.intPaymentId
	OUTER APPLY (
		SELECT TOP 1 strBatchId
		FROM tblARPayment
		WHERE intPaymentId = I.intPaymentId
	) BATCHCPP

	UNION ALL

	SELECT intInvoiceId			= CPP.intInvoiceId
		 , intEntityCustomerId	= CPP.intEntityCustomerId
		 , intPaymentId			= 0
		 , strInvoiceNumber		= CPP.strPrepaymentInvoiceNumber + ' - ' + CPP.strInvoiceNumber
		 , strRecordNumber		= CPP.strPrepaymentInvoiceNumber + ' - ' + CPP.strInvoiceNumber
		 , strPaymentInfo		= ''
		 , strTransactionType	= 'Applied Payment'
		 , dblAmountDue			= 0
		 , dblBalance			= CPP.dblPayment
		 , dblPayment			= CPP.dblPayment * -1
		 , dtmDate				= CPP.dtmDate
		 , dtmDueDate			= CPP.dtmDueDate
		 , dtmDatePaid			= CPP.dtmDate
		 , strType				= CPP.strType
		 , strBatchId			= CPP.strBatchId
	FROM #APPLIEDPPREPAYMENTS CPP

	UNION ALL

	SELECT intInvoiceId			= 0
		 , intEntityCustomerId	= P.intEntityCustomerId
		 , intPaymentId			= P.intPaymentId
		 , strInvoiceNumber		= ''
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
		 , strBatchId			= P.strBatchId
	FROM #POSTEDARPAYMENTS P
	WHERE P.ysnInvoicePrepayment = 0
	  AND P.dtmDatePaid BETWEEN @dtmDateFrom AND @dtmDateTo
	  AND P.dblAmountPaid <> 0

	UNION ALL

	SELECT intInvoiceId			= NULL
		 , intEntityCustomerId	= P.intEntityCustomerId
		 , intPaymentId			= P.intPaymentId
		 , strInvoiceNumber		= NULL
		 , strRecordNumber		= P.strRecordNumber + ' - ' + ISNULL(DETAILS.strInvoiceNumber , '')
		 , strPaymentInfo		= 'PAYMENT REF: ' + ISNULL(P.strPaymentInfo, '')
		 , strTransactionType	= 'Applied Payment'
		 , dblAmountDue			= 0.00
		 , dblBalance			= 0.00
		 , dblPayment			= SUM(DETAILS.dblPayment) -- Add 1 second to applied payment. This is to ensure that payments and invoices are presented first before the applied payment.
		 , dtmDate				= DATEADD(ss, 1, P.dtmDatePaid)
		 , dtmDueDate			= NULL
		 , dtmDatePaid			= P.dtmDatePaid
		 , strType				= NULL
		 , strBatchId			= MAX(DETAILS.strBatchId)
	FROM #POSTEDARPAYMENTS P
	INNER JOIN (
		SELECT intPaymentId		= PD.intPaymentId
		     , intInvoiceId		= PD.intInvoiceId
			 , strInvoiceNumber	= I.strInvoiceNumber
			 , dblPayment		= SUM(PD.dblPayment) + SUM(PD.dblDiscount) + SUM(PD.dblWriteOffAmount) - SUM(PD.dblInterest) 
			 , dblAmountDue		= ABS(PD.dblAmountDue)
			 , strBatchId		= PD.strBatchId
		FROM #PAYMENTDETAILS PD 
		INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
		WHERE I.strTransactionType NOT IN ('Customer Prepayment', 'Credit Memo')
		AND PD.dblBalance IS NOT NULL
		AND PD.dblTotalAR IS NOT NULL
		GROUP BY PD.intPaymentId, PD.intInvoiceId, I.strInvoiceNumber, I.dtmPostDate, PD.dblAmountDue, PD.strBatchId
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
	GROUP BY P.intPaymentId, P.intEntityCustomerId, P.strRecordNumber, P.strPaymentInfo, P.dtmDatePaid, DETAILS.strInvoiceNumber, P.strNotes, DETAILS.dblAmountDue
) TRANSACTIONS ON C.intEntityCustomerId = TRANSACTIONS.intEntityCustomerId
OUTER APPLY (
	SELECT TOP 1 dtmDateEntered = CASE WHEN CAST(dtmDateEnteredMin AS DATE) <> CAST(dtmDate AS DATE) THEN CAST(dtmDate AS DATE)
									   ELSE dtmDateEntered 
							      END 
	FROM tblGLDetail
	WHERE strBatchId = TRANSACTIONS.strBatchId
) LOGDATETIME
ORDER BY TRANSACTIONS.dtmDate, LOGDATETIME.dtmDateEntered

--BUDGET
IF @ysnIncludeBudgetLocal = 1
	BEGIN
		INSERT INTO #STATEMENTREPORT (
			   intEntityCustomerId
			 , intInvoiceId
			 , strCustomerNumber
			 , strCustomerName
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
		)
		SELECT intEntityCustomerId			= C.intEntityCustomerId 
			 , intInvoiceId					= CB.intCustomerBudgetId
			 , strCustomerNumber			= C.strCustomerNumber
			 , strCustomerName				= C.strCustomerName
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
        FROM tblARCustomerBudget CB
		INNER JOIN #CUSTOMERS C ON CB.intEntityCustomerId = C.intEntityCustomerId
        WHERE CB.dtmBudgetDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
          AND CB.dblAmountPaid < CB.dblBudgetAmount
	END

UPDATE #STATEMENTREPORT SET dblBalance = ABS(dblPayment) * -1 WHERE strTransactionType = 'Applied Payment'

UPDATE #STATEMENTREPORT SET dblBalance = dblAmountDue WHERE strTransactionType IN ('Invoice', 'Debit Memo') AND dblBalance <> 0

--BALANCE FORWARD LINE ITEM
INSERT INTO #STATEMENTREPORT (
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
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), BUDGET.dtmBudgetDate))) <= NEAREST.dtmBudgetDate
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), BUDGET.dtmBudgetDate))) <= @dtmDateToLocal
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), BUDGET.dtmBudgetDate))) >=@dtmDateFrom
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
	, blbLogo
	, dblAmountPaid
	, intRowId
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
	, strInvoiceNumber			= CASE WHEN SR.strTransactionType IN ('Applied Payment', 'Customer Budget', 'Payment') THEN SR.strRecordNumber ELSE SR.strInvoiceNumber END
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
	, blbLogo					= @blbLogo
	, dblAmountPaid				= CASE WHEN SR.strTransactionType IN ('Customer Prepayment', 'Credit Memo') THEN SR.dblPayment WHEN SR.strTransactionType = 'Payment' THEN ABS(SR.dblPayment) * -1 ELSE 0 END
	, intRowId					= CASE WHEN SR.strTransactionType = 'Balance Forward' THEN 1 ELSE SR.intId END
FROM #STATEMENTREPORT SR

UPDATE tblARCustomerStatementStagingTable
SET strComment = dbo.fnEMEntityMessage(intEntityCustomerId, 'Statement')  
WHERE intEntityUserId = @intEntityUserIdLocal 
  AND strStatementFormat = 'Budget Reminder Alternate 2'

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
		SET @queryRunningBalance = ' ORDER BY intRowId'
	END

SET @query = CAST('' AS NVARCHAR(MAX)) + '
UPDATE CSST
SET  CSST.dblBalance = CSST_RUNNING_BALANCE.dblRunningBalance
	,CSST.dblTotalAmount = CASE WHEN strTransactionType = ''Balance Forward'' THEN dblBalance 
								WHEN strTransactionType = ''Invoice'' THEN dblAmountDue 
								WHEN strTransactionType IN (''Customer Prepayment'', ''Credit Memo'', ''Payment'') THEN dblAmountPaid
								ELSE 0 END
FROM tblARCustomerStatementStagingTable CSST
INNER JOIN (
	SELECT intRowId, dblRunningBalance = SUM(CASE WHEN strTransactionType = ''Balance Forward'' THEN dblBalance 
												  WHEN strTransactionType = ''Invoice'' THEN dblAmountDue 
												  WHEN strTransactionType IN (''Customer Prepayment'', ''Credit Memo'', ''Payment'') THEN dblAmountPaid
												  ELSE 0 END) OVER (PARTITION BY strStatementFormat' + ISNULL(@queryRunningBalance, '') +')
	FROM tblARCustomerStatementStagingTable
) CSST_RUNNING_BALANCE
ON CSST.intRowId = CSST_RUNNING_BALANCE.intRowId
WHERE CSST.intEntityUserId = '+ @strEntityUserIdLocal +'
  AND CSST.strStatementFormat = ''Budget Reminder Alternate 2'''

 EXEC sp_executesql @query